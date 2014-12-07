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

/**
 * Datapicker Popup directive.
 */

@Decorator(selector: 'datepicker-popup[ng-model]')
@Decorator(selector: '[datepicker-popup][ng-model]')
class DatepickerPopup implements ScopeAware {

  String _dateFormat;
  bool _closeOnDateSelection = false;
  bool _appendToBody = false;
  
  var getIsOpen, setIsOpen;
  var popupEl, datepickerEl;
  
  Scope _originalScope;
  Scope _scope;
  dom.Element _element;
  Date _dateFilter;
  NodeAttrs _attrs;
  NgModel _ngModel;
  Parser _parser;
  Compiler _compiler;
  DirectiveMap _directiveMap;
  Injector _injector;
  DatepickerConfig _datepickerConfig;
  DatepickerPopupConfig _datepickerPopupConfig;
  Position _position;
  
  DatepickerPopup(Scope _originalScope, this._element, this._dateFilter, this._attrs, this._ngModel, this._position,
      this._parser, this._compiler, this._directiveMap, this._injector, this._datepickerConfig, this._datepickerPopupConfig);
  
  void set scope(Scope originalScope) {
    this._originalScope = originalScope;
    // create a child scope so we are not polluting original one
    _scope = _originalScope.createChild(new PrototypeMap(_originalScope.context)); 
    
    _closeOnDateSelection = _attrs.containsKey('close-on-date-selection') ? _originalScope.eval(_attrs['close-on-date-selection']) : _datepickerPopupConfig.closeOnDateSelection;
    _appendToBody = _attrs.containsKey('datepicker-append-to-body') ? _originalScope.eval(_attrs['datepicker-append-to-body']) : _datepickerPopupConfig.appendToBody;
    
    _attrs.observe('datepicker-popup', (value) {
        _dateFormat = value != null ? value : _datepickerPopupConfig.dateFormat;
        _ngModel.render(null);
    });
    
    _scope.context['showButtonBar'] = _attrs.containsKey('show-button-bar') ? _originalScope.eval(_attrs['show-button-bar']) : _datepickerPopupConfig.showButtonBar;
    
    _originalScope.on(r'$destroy').listen((evt) {
      popupEl.remove();
      _scope.destroy();
    });
    
    _attrs.observe('current-text', (text) {
      _scope.context['currentText'] = text != null ? text : _datepickerPopupConfig.currentText;
    });
    
    _attrs.observe('toggle-wWeeks-text', (text) {
      _scope.context['toggleWeeksText'] = text != null ? text : _datepickerPopupConfig.toggleWeeksText;
    });
    
    _attrs.observe('clear-text', (text) {
      _scope.context['clearText'] = text != null ? text : _datepickerPopupConfig.clearText;
    });
    
    _attrs.observe('close-text', (text) {
      _scope.context['closeText'] = text != null ? text : _datepickerPopupConfig.closeText;
    });
    
    if (_attrs.containsKey('is-open')) {
      getIsOpen = _parser(_attrs['is-open']);
      setIsOpen = getIsOpen.assign;

      _originalScope.watch(getIsOpen, (value, prev) {
        _scope.context['isOpen'] = !! value;
      });
    }
    _scope.context['isOpen'] = getIsOpen != null ? getIsOpen(_originalScope) : false; // Initial state
    
    ///////////////
    String html = '<div datepicker-popup-wrap><div datepicker></div></div>';
    // Convert to html

    popupEl = compile(html, _injector, _compiler, scope:_scope, directives: _directiveMap);
    datepickerEl = popupEl.querySelector('[datepicker]');
    //
    popupEl.attributes['ng-model'] = 'date';
    popupEl.attributes['ng-change'] = 'dateSelection()';
    datepickerEl.attributes['ng-model'] = 'date';
    //
    Map<String, String> datepickerOptions = {};
    if (_attrs.containsKey('datepicker-options')) {
      datepickerOptions = _originalScope.eval(_attrs['datepicker-options']);
      datepickerOptions.forEach((key, value) {
        datepickerEl.setAttribute(key, value.toString());
      });
    }
    
    // Inner change
    _scope.context['dateSelection'] = (dt) {
      if (dt != null) {
        _scope.context['date'] = dt;
      }
      _ngModel.viewValue = _parseDate(_scope.context['date']);
      _ngModel.render(null);

      if (_closeOnDateSelection != null) {
        setOpen(false);
      }
    };
    
    _element.onInput.listen(_inputChanged);
    _element.onChange.listen(_inputChanged);
    _element.onKeyUp.listen(_inputChanged);
    
    // Outter change
    _ngModel.render = (value) {
      var date = _ngModel.viewValue != null ? _dateFilter(_ngModel.viewValue, _dateFormat) : '';
      (_element as dynamic).value = date;
      _scope.context['date'] = _ngModel.modelValue;
    };

    addWatchableAttribute(_attrs['min'], 'min');
    addWatchableAttribute(_attrs['max'], 'max');
    
    if (_attrs.containsKey('show-weeks')) {
      addWatchableAttribute(_attrs['show-weeks'], 'showWeeks', 'show-weeks');
    } else {
      _scope.context['showWeeks'] = datepickerOptions.containsKey('show-weeks') ? datepickerOptions['show-weeks'] : _datepickerConfig.showWeeks;
      datepickerEl.attributes['show-weeks'] = 'showWeeks';
    }
    
    if (_attrs.containsKey('date-disabled')) {
      datepickerEl.attributes['date-disabled'] = _attrs['date-disabled'];
    }
    
    var documentBindingInitialized = false, elementFocusInitialized = false;
    _scope.watch('isOpen', (value, prev) {
      if (value != null) {
        updatePosition();
        dom.document.addEventListener('click', _documentClickBind);
        if(elementFocusInitialized) {
          _element.removeEventListener('focus', _elementFocusBind);
        }
        _element.focus(); // element[0]
        documentBindingInitialized = true;
      } else {
        if(documentBindingInitialized) {
          dom.document.removeEventListener('click', _documentClickBind);
        }
        _element.addEventListener('focus', _elementFocusBind);
        elementFocusInitialized = true;
      }

      if (setIsOpen != null) {
        setIsOpen(_originalScope, value);
      }
    });
    
    _scope.context['today'] = () {
      _scope.context['dateSelection'](new DateTime.now());
    };
    _scope.context['clear'] = () {
      _scope.context['dateSelection'](null);
    };
    
    if (_appendToBody) {
      dom.document.body.append(popupEl);
    } else {
      _element.parent.append(popupEl); // after
    }
  }

  void setOpen( value ) {
    if (setIsOpen) {
      setIsOpen(_originalScope, !!value);
    } else {
      _scope.context['isOpen'] = !!value;
    }
  }

  void _documentClickBind(dom.Event event) {
    if (_scope.context['isOpen'] && event.target != _element) {
     _scope.apply(() {
        setOpen(false);
      });
    }
  }
  
  void _elementFocusBind(dom.Event evt) {
    _scope.apply(() {
      setOpen(true);
    });
  }
  
  DateTime _parseDate(viewValue) {
    if (viewValue == null) {
//      _ngModel.setValidity('date', true);
      return null;
    } else if (viewValue is DateTime) {
//      _ngModel.setValidity('date', true);
      return viewValue;
    } else if (viewValue is String) {
      var date = DateTime.parse(viewValue);
      if (date == null) {
//        _ngModel.setValidity('date', false);
        return null;
      } else {
//        _ngModel.setValidity('date', true);
        return date;
      }
    } else {
//      _ngModel.setValidity('date', false);
      return null;
    }
  }
  
  void _inputChanged(dom.Event event) {
    _scope.apply(() => _scope.context['date'] = _ngModel.modelValue);
  }
  
  void addWatchableAttribute(attribute, scopeProperty, [datepickerAttribute = null]) {
    if (attribute != null) {
      _originalScope.watch(attribute, (value, prev) {
        _scope.context[scopeProperty] = value;
      });
      datepickerEl.attributes[datepickerAttribute != null ? datepickerAttribute : scopeProperty] = scopeProperty;
    }
  }
  
  void updatePosition() {
    _scope.context['position'] = _appendToBody ? _position.offset(_element) : _position.position(_element);
    _scope.context['position'].top = _scope.context['position'].top + _element.offsetHeight;
  }
}

@Component(
    selector: 'datepicker-popup-wrap',
    useShadowDom: false,
    template: '''
<ul class="dropdown-menu" ng-style="{'display':d.display, 'top':top, 'left':left}">
  <li><content></content></li>
  <li ng-show="showButtonBar" style="padding:10px 9px 2px">
    <span class="btn-group">
      <button type="button" class="btn btn-sm btn-info" ng-click="today()">{{currentText}}</button>
      <button type="button" class="btn btn-sm btn-default" ng-click="showWeeks = ! showWeeks" ng-class="{active: showWeeks}">{{toggleWeeksText}}</button>
      <button type="button" class="btn btn-sm btn-danger" ng-click="clear()">{{clearText}}</button>
    </span>
    <button type="button" class="btn btn-sm btn-success pull-right" ng-click="isOpen = false">{{closeText}}</button>
  </li>
</ul>'''
    //templateUrl: 'packages/angular_ui/datepicker/popup.html'
)
//@Component(selector: '[datepicker-popup-wrap]', publishAs: 'd', 
//    useShadowDom: false, 
//    templateUrl: 'packages/angular_ui/datepicker/popup.html')
class DatepickerPopupWrap implements ScopeAware {

  Scope scope;
  
  String get display {
    return scope.context['isOpen'] != null && scope.context['isOpen'] ? 'block' : 'none';
  }
  
  DatepickerPopupWrap(dom.Element element) {
    element.onClick.listen((dom.Event event) {
      event.preventDefault();
      event.stopPropagation();
    });
  }
}