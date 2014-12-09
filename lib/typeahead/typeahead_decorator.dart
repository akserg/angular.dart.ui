part of angular.ui.typeahead;

@Decorator(
  selector : 'input[typeahead][ng-model]', 
  map: const {
    'typeahead': '@expression',
    'typeahead-template-url': '@templateUrl',
    'typeahead-min-length': '@minLength',
    'typeahead-append-to-body': '@appendToBody',
    'typeahead-input-formatter': '&inputFormatter',
    'typeahead-wait-ms': '@waitInMs',
    'typeahead-loading': '<=>isLoading',
    'typeahead-on-select': '&onSelectCallback',
    'typeahead-editable': '@isEditable'
  }
)
class TypeaheadDecorator extends TemplateBasedComponent implements AttachAware, ScopeAware {

  final TypeaheadParser _typeaheadParser;
  final NgModel _ngModel;
  Scope _scope;
  dom.InputElement _element;

  final FormatterMap _formatters;
  final Injector _injector;
  final Position _positionService;

  String templateUrl;
  int _minLength;
  int _waitInMs;
  bool _isEditable;
  bool _appendToBody;
  Function inputFormatter;
  bool _isInputFormatterEnabled;
  bool isLoading = false;
  Function onSelectCallback;

  String popupId;

  TypeaheadParseResult _typeaheadParserResult;

  var keyMappings;
  bool _hasFocus;

  StreamSubscription _clickSubscription;
  Timer _matchesLookupTimer;

  // Popup specific params;
  List matches = [];
  int _active = -1;
  Rect position;
  String query;

  TypeaheadDecorator(this._ngModel, this._injector, dom.Element element, this._typeaheadParser, this._formatters, ViewFactoryCache viewCache, this._positionService) : 
      super(viewCache) {
    this._element = element as dom.InputElement;
    keyMappings = {dom.KeyCode.ENTER : _onKeyPressEnter, dom.KeyCode.TAB : _onKeyPressEnter, dom.KeyCode.DOWN : _onKeyPressDown, dom.KeyCode.UP : _onKeyPressUp, dom.KeyCode.ESC : _onKeyPressEsc};

    _isInputFormatterEnabled = _element.getAttribute('typeahead-input-formatter') != null;

    active = -1;
  }
  
  void set scope(Scope scope) {
    _scope = scope;
    popupId = 'typeahead-${_scope.id}-${new Random().nextInt(10000)}';
    _element.attributes.addAll({'aria-autocomplete': 'list', 'aria-expanded': 'false', 'aria-owns': popupId});
  }

  set expression(value) {
    assert(value != null);

    _typeaheadParserResult = _typeaheadParser.parse(value);
    var formatterFunc = (modelValue) {

      if(_isInputFormatterEnabled) {
        return inputFormatter({r'$model' : modelValue});
      } else {
        try {
          var locals = {
              _typeaheadParserResult.itemName : modelValue
          };
          return eval(_typeaheadParserResult.viewMapper, locals);
        } catch(e, s) {
          return modelValue;
        }
      }
    };
    _ngModel.converter = new TypeaheadConverter(formatterFunc);
  }

  set minLength(value) => _minLength =  (value == null) ? 1 : toInt(value);
  set waitInMs(value) => _waitInMs =  (value == null) ? 0 : toInt(value);
  set isEditable(value) => _isEditable =  (value == null) ? true : toBool(value);
  set appendToBody(value) => _appendToBody =  (value == null) ? false : toBool(value);

  int get active => _active;
  set active(int value) {
    _active = value;
    if (value < 0) {
      _element.attributes.remove('aria-activedescendant');
    } else {
      _element.attributes['aria-activedescendant'] =  _getMatchItemId(value);
    }
  }

  void select(int index) {

    var item = matches[index]['model'];
    var locals = {_typeaheadParserResult.itemName : item};
    var model = eval(_typeaheadParserResult.modelMapper, locals);
    _scope.apply((){
      _ngModel.setter(model);
      _ngModel.removeError('ng-editable');
      _resetMatches();
    });

    onSelectCallback({r'$item' : item, r'$model' : model, r'$label': eval(_typeaheadParserResult.viewMapper,locals)});

    new Future.microtask(()=> _element.focus());
  }

  void attach() {
    _element
      ..onChange.listen(_onValueChanged)
      ..onCut.listen(_onValueChanged)
      ..onPaste.listen(_onValueChanged)
      ..onInput.listen(_onValueChanged);

    _element.onKeyDown.listen(_onKeyPress);

    _element.onBlur.listen((event) => _hasFocus = false);

    _clickSubscription = dom.document.onClick.listen((event){
      if(_element != event.target) {
        _scope.apply(()=> _resetMatches());
      }
    });
  }

  void detach() {
    _clickSubscription.cancel();
    super.detach();
  }

  eval(expression, locals) => expression.eval(new ContextLocals(_scope.context, locals), _formatters);

  _scheduleSearchWithTimeout(inputValue) {
    _matchesLookupTimer = new Timer(new Duration(milliseconds : _waitInMs), ()=>_getMatchesAsync(inputValue));
  }

  _cancelPreviousTimeout() {
    if(_matchesLookupTimer != null) {
      _matchesLookupTimer.cancel();
    }
    _matchesLookupTimer = null;
  }

  void _onValueChanged(dom.Event event) {

    _hasFocus = true;

    String inputValue = _element.value;

    if(inputValue != null || inputValue.length >= _minLength) {
      if(_waitInMs != 0) {
        _cancelPreviousTimeout();
        _scheduleSearchWithTimeout(inputValue);
      } else {
        _getMatchesAsync(inputValue);
      }
    } else {
      _scope.apply(() {
        isLoading = false;
        _cancelPreviousTimeout();
        _resetMatches();
      });
    }

    if(!_isEditable) {
      if(inputValue == null || inputValue.isEmpty) {
        _ngModel.removeError('ng-editable');
      } else {
        _ngModel.addError('ng-editable');
      }
    }
  }

  void _onKeyPress(dom.KeyboardEvent event) {

    if(matches.length == 0 || !keyMappings.containsKey(event.keyCode)) {
      return;
    }

    event.preventDefault();

    keyMappings[event.keyCode](event);
  }

  void _onKeyPressEnter(dom.KeyboardEvent event) {
    select(active);
  }

  void _onKeyPressDown(dom.KeyboardEvent event) {
    _scope.apply(() => active = (active + 1) % matches.length);
  }

  void _onKeyPressUp(dom.KeyboardEvent event) {
    _scope.apply(() => active = (active ==0? matches.length : active) - 1);
  }

  void _onKeyPressEsc(dom.KeyboardEvent event) {
    event.stopPropagation();
    _scope.apply(() => _resetMatches());
  }

  String _getMatchItemId(int index) => '${popupId}-option-$index';

  void _getMatchesAsync(String inputValue) {
    isLoading = true;

    var func = () { 
      return eval(_typeaheadParserResult.source, {r'$viewValue': inputValue});
    };
    
    new Future(func).then((matches){
      var onCurrentRequest = (inputValue == _ngModel.viewValue);
      if(onCurrentRequest && _hasFocus) {
        if (matches.length > 0) {
          //_scope.apply(() => _updatePopup(inputValue, matches));
          _updatePopup(inputValue, matches);
        } else {
          //_scope.apply(() => _resetMatches());
          _resetMatches();
        }
      }
      if(onCurrentRequest)
        isLoading = false;
    }).catchError((error){
      _resetMatches();
      isLoading = false;
    });
  }

  void _updatePopup(String inputValue, Iterable values) {

    if(_view == null) {
      loadView(_appendToBody? dom.document.body :_element.parent, _injector, _scope, 'packages/angular_ui/typeahead/typeahead.html', this);
    }

    active = 0;
    query = inputValue;

    matches.clear();
    for(var index = 0; index < values.length; ++index) {
      var item = values.elementAt(index);
      matches.add({'id':_getMatchItemId(index), 'label':eval(_typeaheadParserResult.viewMapper, {_typeaheadParserResult.itemName: item}), 'model':item});
    }

    //position pop-up with matches - we need to re-calculate its position each time we are opening a window
    //with matches as a pop-up might be absolute-positioned and position of an input might have changed on a page
    //due to other elements being rendered
    position = _appendToBody? _positionService.offset(_element) : _positionService.position(_element);
    position.top += _element.offsetHeight;

    _element.attributes['aria-expanded'] = 'true';
  }

  void _resetMatches() {
    matches.clear();
    active = -1;
    _element.attributes['aria-expanded'] = 'false';
  }

}

typedef FormatterFunc(value);

@Injectable()
class TypeaheadConverter extends NgModelConverter {
  final name = 'typeahead';
  final FormatterFunc _formatter;

  TypeaheadConverter(this._formatter);

  format(value) => _formatter(value);
}