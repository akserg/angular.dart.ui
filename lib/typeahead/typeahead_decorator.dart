part of angular.ui.typeahead;

@Decorator(selector : '[typeahead]', map: const {
    'typeahead': '@expression',
    'typeahead-template-url': '@templateUrl'
})
class TypeaheadDecorator extends TemplateBasedComponent implements AttachAware {

  final TypeaheadParser _typeaheadParser;
  final NgModel _ngModel;
  final Scope _scope;
  final dom.Element _element;

  final FormatterMap _formatters;
  final Injector _injector;
  final Position _positionService;

  String templateUrl;

  TypeaheadParseResult _typeaheadParserResult;

  // Popup specific params;
  List<TypeaheadMatchItem> matches = [];
  int active = -1;
  Rect position;
  String query;


  TypeaheadDecorator(this._ngModel, this._injector, this._scope, this._element, this._typeaheadParser, this._formatters, ViewCache viewCache, this._positionService) : super(viewCache);

  set expression(value) {
    assert(value != null);

    _typeaheadParserResult = _typeaheadParser.parse(value);
    var formatterFunc = (modelValue) {
      try {
        var locals = {
            _typeaheadParserResult.itemName : modelValue
        };
        return eval(_typeaheadParserResult.viewMapper, locals);
      } catch(e, s) {
        return modelValue;
      }
    };
    _ngModel.converter = new TypeaheadConverter(formatterFunc);
  }

  void select(int index) {

    _scope.apply((){
      _ngModel.setter(eval(_typeaheadParserResult.modelMapper, {_typeaheadParserResult.itemName : matches[index].model}));
      _ngModel.validateLater();
      _resetMatches();
    });

    _element.focus();
  }

  void attach() {
    loadView(_element.parent, _injector, _scope, 'packages/angular_ui/typeahead/typeahead.html', {'ctrl' : this});
    _element
      ..onChange.listen(_onValueChanged)
      ..onCut.listen(_onValueChanged)
      ..onPaste.listen(_onValueChanged)
      ..onInput.listen(_onValueChanged);

    _element.onKeyPress.listen(_onKeyPress);
  }

  eval(expression, locals) => expression.eval(new ScopeLocals(_scope.context, locals), _formatters);


  void _onValueChanged(dom.Event event) {
    if(_element.value == null || _element.value.length == 0) {
      _scope.apply(() => _resetMatches());
    } else {
      _getMatchesAsync(_element.value);
    }
  }

  void _onKeyPress(dom.KeyEvent event) {

    if(matches.length == 0 || event.keyCode != dom.KeyCode.ENTER) {
      return;
    }

    event.preventDefault();

    select(active);
  }


  String _getMatchItemId(int index) => '-option-$index';

  void _getMatchesAsync(String inputValue) {
    new Future(() => eval(_typeaheadParserResult.source, {r'$viewValue': inputValue})).then((matches){
      if(matches.length == 0) {
        _resetMatches();
      } else {
        _scope.apply(() => _updatePopup(inputValue, matches));
      }
    });
  }

  void _updatePopup(String inputValue, Iterable values) {
    active = 0;
    query = inputValue;

    matches.clear();
    for(var index = 0; index < values.length; ++index) {
      var item = values.elementAt(index);
      matches.add(new TypeaheadMatchItem(_getMatchItemId(index), eval(_typeaheadParserResult.viewMapper, {_typeaheadParserResult.itemName: item}), item));
    }

    position = _positionService.offset(_element);
    position.top += _element.offsetHeight;
  }

  void _resetMatches() {
    matches.clear();
    active = -1;
  }

}

typedef FormatterFunc(value);

class TypeaheadConverter extends NgModelConverter {
  final name = 'typeahead';
  final FormatterFunc _formatter;

  TypeaheadConverter(this._formatter);

  format(value) => _formatter(value);
}