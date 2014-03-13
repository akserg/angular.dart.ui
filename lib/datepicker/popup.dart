// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.datepicker;

/**
 * Datepicker popup configuration.
 */
class DatepickerPopupConfig {
  String dateFormat = 'yyyy-MM-dd';
  String currentText = 'Today';
  String toggleWeeksText = 'Weeks';
  String clearText = 'Clear';
  String closeText = 'Done';
  bool closeOnDateSelection = true;
  bool appendToBody = false;
  bool showButtonBar = true;
}

@NgComponent(selector: 'datepicker-popup-wrap', publishAs: 'd',
    applyAuthorStyles: true, 
    templateUrl: 'packages/angular_ui/datepicker/popup.html')
@NgComponent(selector: '[datepicker-popup-wrap]', publishAs: 'd', 
    applyAuthorStyles: true, 
    templateUrl: 'packages/angular_ui/datepicker/popup.html')
class DatepickerPopupWrap {
  
  @NgTwoWay('is-open')
  bool isOpen = false;
  
  @NgOneWay('position')
  Rect position = new Rect();
  
  @NgOneWay('show-button-bar')
  bool showButtonBar = false;
  
  @NgCallback('today')
  var today;
  
  @NgTwoWay('show-weeks')
  bool showWeeks = false;
  
  @NgOneWay('current-text')
  String currentText;
  
  @NgOneWay('toggle-weeks-text')
  String toggleWeeksText;
  
  @NgCallback('clear-date')
  var clearDate;
  
  @NgOneWay('close-text')
  String closeText;
  
  @NgOneWay('clear-text')
  String clearText;
  
  String get display => isOpen ? 'block' : 'none';
  
  String get top {
    return position != null && position.top != null ?  '${position.top}px' : '0px'; 
  }
  
  String get left => position != null && position.left != null ?  '${position.left}px' : '0px';
  
  DatepickerPopupWrap(dom.Element element) {
    element.onClick.listen((dom.Event event) {
      event.preventDefault();
      event.stopPropagation();
    });
  }
}


/**
 * Datapicker Popup directive.
 */

@NgDirective(selector: 'datepicker-popup[ng-model]')
@NgDirective(selector: '[datepicker-popup][ng-model]')
class DatepickerPopup  {

  String _dateFormat;
  @NgAttr('datepicker-popup')
  void set datepickerPopup(String value) {
    _dateFormat = value != null ? value : _datepickerPopupConfig.dateFormat;
    _ngModel.dirty = true;
  }
  String get datepickerPopup => _dateFormat;

  bool _showButtonBar = false;
  @NgOneWay('show-button-bar')
  void set showButtonBar(bool value) {
    _scope.showButtonBar = _showButtonBar = value != null ? value :
        _datepickerPopupConfig.showButtonBar;
  }
//  bool get showButtonBar => _showButtonBar;

//  String _currentText;
//  @NgAttr('current-text')
//  void set currentText(String value) {
//    _currentText = value != null ? value : _datepickerPopupConfig.currentText;
//  }
//  String get currentText => _currentText;
  @NgAttr('current-text')
  String currentText;

//  String _toggleWeeksText;
//  @NgAttr('toggle-weeks-text')
//  void set toggleWeeksText(String value) {
//    _toggleWeeksText = value != null ? value :
//        _datepickerPopupConfig.toggleWeeksText;
//  }
//  String get toggleWeeksText => _toggleWeeksText;

//  String _clearText;
//  @NgAttr('clear-text')
//  void set clearText(String value) {
//    _clearText = value != null ? value : _datepickerPopupConfig.clearText;
//  }
//  String get clearText => _clearText;

//  String _closeText;
//  @NgAttr('close-text')
//  void set closeText(String value) {
//    _closeText = value != null ? value : _datepickerPopupConfig.closeText;
//  }
//  String get closeText => _closeText;

  bool isOpen = false;
  @NgTwoWay('is-open')
  set setIsOpen(bool value) {
    if (value) {
      _updatePosition();
      dom.document.addEventListener('click', documentClickBind);
      if(_elementFocusInitialized) {
        _element.removeEventListener('focus', elementFocusBind);
      }
      _element.focus();
      _documentBindingInitialized = true;
      isOpen = true;
    } else {
      if(_documentBindingInitialized) {
        dom.document.removeEventListener('click', documentClickBind);
      }
      _element.addEventListener('focus', elementFocusBind);
      _elementFocusInitialized = true;
      isOpen = false;
    }
    _scope.isOpen = isOpen;
  }
  bool get setIsOpen => isOpen;
  

  @NgOneWay('datepicker-options')
  Map datepickerOptions = {};

  DateTime minDate;
  @NgOneWay('min')
  void set min(value) {
    minDate = null;
    if (value != null) {
      if (value is String) {
        minDate = DateTime.parse(value);
      } else if (value is int) {
        minDate = new DateTime.fromMillisecondsSinceEpoch(value);
      } else {
        minDate = value as DateTime;
      }
    }
  }
  
  DateTime maxDate;
  @NgOneWay('max')
  void set max(value) {
    maxDate = null;
    if (value != null) {
      if (value is String) {
        maxDate = DateTime.parse(value);
      } else if (value is int) {
        maxDate = new DateTime.fromMillisecondsSinceEpoch(value);
      } else {
        maxDate = value as DateTime;
      }
    }
  }
  
  bool _showWeeks = false;
  @NgOneWay('show-weeks')
  set showWeeks(bool value) {
    _showWeeks = value;
  }
  bool get showWeeks => _showWeeks;
  
  @NgCallback('date-disabled')
  var dateDisabled;
  
  @NgOneWay('append-to-body')
  bool appendToBody = false;

  bool _closeOnDateSelection = false;
//  DateTime date;
//  Rect position;
  bool _documentBindingInitialized = false; 
  bool _elementFocusInitialized = false;
  dom.Element _popup;
  dom.Element _datepicker;

  dom.Element _element;
  Position _position;
  DateFilter _dateFilter;
  DatepickerPopupConfig _datepickerPopupConfig;
  DatepickerConfig _datepickerConfig;
  NgModel _ngModel;
  NgModel get ngModel => _ngModel;
  NodeAttrs _attrs;
  
  Scope _originalScope;
  Scope _scope;
  TemplateCache _templateCache;
  Compiler _compiler;
  Http _http;
  DirectiveMap _directiveMap;
  Injector _injector;
  
  DatepickerPopup(this._element, this._position, this._dateFilter, this._datepickerPopupConfig, this._datepickerConfig, this._ngModel, this._attrs, this._originalScope,
      this._templateCache, this._compiler, this._http, this._directiveMap, this._injector) {
    
    _scope = _originalScope.$new(isolate:true);
    
    _closeOnDateSelection = _attrs.containsKey('close-on-date-selection') ? _scope.$eval(_attrs['close-on-date-selection']) : _datepickerPopupConfig.closeOnDateSelection;
    appendToBody = _attrs.containsKey('datepicker-append-to-body') ? _scope.$eval(_attrs['datepicker-append-to-body']) : _datepickerPopupConfig.appendToBody;
    //_showButtonBar = _attrs.containsKey('show-button-bar') ? _scope.$eval(_attrs['show-button-bar']) : _datepickerPopupConfig.showButtonBar;
    showButtonBar = _datepickerPopupConfig.showButtonBar;

    _originalScope.$on('destroy', (event) {
      if (_popup != null && _popup.parent != null)
      _popup.remove();
      _scope.$destroy();
    });
    
    _attrs.observe('current-text', (text) {
      _scope.currentText = text != null ? text : _datepickerPopupConfig.currentText;
    });
    
    _attrs.observe('toggle-weeks-text', (text) {
      _scope.toggleWeeksText = text != null ? text : _datepickerPopupConfig.toggleWeeksText;
    });
    
    _attrs.observe('clear-text', (text) {
      _scope.clearText = text != null ? text : _datepickerPopupConfig.clearText;
    });
    
    _attrs.observe('close-text', (text) {
      _scope.closeText = text != null ? text : _datepickerPopupConfig.closeText;
    });
    
    _scope.dateSelection = _dateSelection;
    
    _scope.today = () {
      _dateSelection(new DateTime.now());
    };
      
    _scope.clearDate = () {
      _dateSelection(null);
    };

    
    _element.onInput.listen(_inputChanged);
    _element.onChange.listen(_inputChanged);
    _element.onKeyUp.listen(_inputChanged);
    
    // Outter change
    _ngModel.render = (value) {
      String d = _ngModel.viewValue != null ? _dateFilter(_ngModel.viewValue, _dateFormat) : '';
      (_element as dynamic).value = d;
      _scope.date = _ngModel.modelValue;
    };
    
    var injector = _injector.createChild([new Module()..value(Scope, _scope)]);
    
    // popup element used to display calendar
    String html = """<div datepicker-popup-wrap 
      ng-model='date' ng-change='dateSelection()'
      is-open='isOpen' position='position' 
      show-button-bar='showButtonBar' today='today()' 
      show-weeks='showWeeks' clear-date='clearDate()'
      current-text='currentText' toggle-weeks-text='toggleWeeksText'
      close-text='closeText' clear-text='clearText'>
      
      <div datepicker datepicker-options='datepickerOptions' 
        min='minDate' max='maxDate' ng-model='date'
        show-weeks='showWeeks'></div>
    </div>""";
    
    if (_attrs.containsKey('date-disabled')) {
      _element.attributes['date-disabled'] = _attrs['dateDisabled'];
    }
    
    // Convert to html
    List<dom.Element> rootElements = toNodeList(html);

    _popup = rootElements.first;
    _datepicker = _popup.querySelector('[datepicker]');
    //
    _compiler(rootElements, _directiveMap)(injector, rootElements);
    //
    if (appendToBody) {
      dom.document.body.append(_popup);
    } else {
      _element.parent.append(_popup);
    }
    
    Map<String, String> datepickerOptions = {};
    if (_attrs.containsKey('datepicker-options')) {
      datepickerOptions = _originalScope.$eval(_attrs['datepicker-options']);
      datepickerOptions.forEach((key, value) {
        if (value != null) {
          _datepicker.setAttribute(key, value.toString());
        }
      });
    }

    addWatchableAttribute(_attrs['min'], 'min');
    addWatchableAttribute(_attrs['max'], 'max');
    
    if (_attrs.containsKey('show-weeks')) {
      addWatchableAttribute('show-weeks', 'showWeeks', 'show-weeks');
    } else {
      _scope.showWeeks = datepickerOptions.containsKey('show-weeks') ? datepickerOptions['show-weeks'] : _datepickerConfig.showWeeks;
      _datepicker.setAttribute('show-weeks', 'showWeeks');
    }

    if (_attrs.containsKey('date-disabled')) {
      _datepicker.setAttribute('date-disabled', _attrs['date-disabled']);
    }
  }

  void _dateSelection(DateTime dt) {
    _ngModel.viewValue = _scope.date = dt;

    if (_closeOnDateSelection) {
      isOpen = false;
    }
  }
  
  void _inputChanged(dom.Event event) {
    _scope.$apply(() => _scope.date = _ngModel.modelValue);
  }

  void addWatchableAttribute(String attribute, String scopeProperty, [String datepickerAttribute = null]) {
    if (attribute != null) {
      _originalScope.$watch(attribute, (value){
        _scope[scopeProperty] = value;
      });
      _datepicker.setAttribute(datepickerAttribute != null ? datepickerAttribute : scopeProperty, scopeProperty);
    }
  }
  
  void documentClickBind(dom.Event event) {
    if (isOpen && event.target != _element) {
      _scope.$apply(() => isOpen = false);
    }
  }

  void elementFocusBind(dom.Event event) {
    _scope.$apply(() => isOpen = true);
  }
  
  void _updatePosition() {
    _scope.position = appendToBody ? _position.offset(_element) : _position.position(_element);
    _scope.position.top = _scope.position.top + _element.offsetHeight;
  }
}