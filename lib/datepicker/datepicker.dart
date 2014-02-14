// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.datepicker;

import 'dart:html' as dom;
import "package:angular/angular.dart";
import "package:angular_ui/utils/position.dart";

/**
 * Alert Module.
 */
class AlertModule extends Module {
  AlertModule() {
    install(new PositionModule());
    value(DatepickerConfig, new DatepickerConfig());
    value(DatepickerPopupConfig, new DatepickerPopupConfig());
    type(DatepickerPopup);
  }
}

class DatepickerConfig {
  String dayFormat = 'dd';
  String monthFormat= 'MMMM';
  String yearFormat= 'yyyy';
  String dayHeaderFormat= 'EEE';
  String dayTitleFormat= 'MMMM yyyy';
  String monthTitleFormat= 'yyyy';
  bool showWeeks= true;
  int startingDay= 0;
  int yearRange= 20;
  var minDate= null;
  var maxDate= null;
}

// DatepickerController
// datepicker
// datepickerPopupConfig

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
 * Datapicker  component.
 */
@NgDirective(selector:'datepicker-popup')
@NgDirective(selector:'[datepicker-popup]')
class DatepickerPopup {
  
  String dateFormat;
  String _currentText;
  String _toggleWeeksText;
  String _clearText;
  String _closeText;
  bool _closeOnDateSelection = false;
  bool _appendToBody = false;
  bool _showButtonBar = false;
  bool isOpen = false;
  
  @NgOneWay('close-on-date-selection')
  void set closeOnDateSelection(bool value) {
    _closeOnDateSelection = value != null ? value : datepickerPopupConfig.closeOnDateSelection;
  }
  
  @NgOneWay('datepicker-append-to-body')
  void set appendToBody(bool value) {
    _appendToBody = value != null ? value : datepickerPopupConfig.appendToBody;
  }
  
  @NgOneWay('show-button-bar')
  void set showButtonBar(bool value) {
    _showButtonBar = value != null ? value : datepickerPopupConfig.showButtonBar;
  }
  
  @NgAttr('datepicker-popup')
  void set datepickerPopup(String value) {
    dateFormat = value != null ? value : datepickerPopupConfig.dateFormat;
    ngModel.render();
  }
  
  @NgAttr('current-text')
  void set currentText(String value) {
    _currentText = value != null ? value : datepickerPopupConfig.currentText;
  }
  
  @NgAttr('toggle-weeks-text')
  void set toggleWeeksText(String value) {
    _toggleWeeksText = value != null ? value : datepickerPopupConfig.toggleWeeksText;
  }
  
  @NgAttr('clear-text')
  void set clearText(String value) {
    _clearText = value != null ? value : datepickerPopupConfig.clearText;
  }
  
  @NgAttr('close-text')
  void set closeText(String value) {
    _closeText = value != null ? value : datepickerPopupConfig.closeText;
  }
  
  dom.Element popupEl;
  dom.Element datepickerEl;
  
  Scope originalScope;
  Scope scope;
  dom.Element element;
  NodeAttrs attrs;
  NgModel ngModel;
  Compiler compiler;
  
  Position position;
  bool documentBindingInitialized = false; 
  bool elementFocusInitialized = false;
  
  DatepickerConfig datepickerConfig;
  DatepickerPopupConfig datepickerPopupConfig;
  
  DatepickerPopup(this.originalScope, this.element, this.attrs, this.ngModel, this.datepickerPopupConfig, this.datepickerConfig, this.position, this.compiler) {
    // create a child scope so we are not polluting original one
    scope = originalScope.$new();
    //closeOnDateSelection = attrs.containsKey('close-on-date-selection') ? originalScope.$eval(attrs['close-on-date-selection']) : datepickerPopupConfig.closeOnDateSelection;
    _closeOnDateSelection = datepickerPopupConfig.closeOnDateSelection;
    //appendToBody = attrs.containsKey('datepicker-append-to-body') ? originalScope.$eval(attrs['datepicker-append-to-body']) : datepickerPopupConfig.appendToBody;
    _appendToBody = datepickerPopupConfig.appendToBody;
    //showButtonBar = attrs.containsKey('show-button-bar') ? originalScope.$eval(attrs['show-button-bar']) : datepickerPopupConfig.appendToBody;
    _showButtonBar = datepickerPopupConfig.appendToBody;
    
    dom.Element popup;
    
    originalScope.$on('\$destroy', () {
      popup.remove();
      scope.$destroy();
    });
    
    // popup element used to display calendar
//    var popupEl = angular.element('<div datepicker-popup-wrap><div datepicker></div></div>');
//    popupEl.attr({
//      'ng-model': 'date',
//      'ng-change': 'dateSelection()'
//    });
//    var datepickerEl = angular.element(popupEl.children()[0]),
//        datepickerOptions = {};
//    if (attrs.datepickerOptions) {
//      datepickerOptions = originalScope.$eval(attrs.datepickerOptions);
//      datepickerEl.attr(angular.extend({}, datepickerOptions));
//    }
    
//    ngModel.$parsers.unshift(parseDate);
    
    element.onInput.listen((dom.Event event) {
      scope.$apply(() {
        scope.date = ngModel.modelValue;
      });
    });
    
    element.onChange.listen((dom.Event event) {
      scope.$apply(() {
        scope.date = ngModel.modelValue;
      });
    });
    
    element.onKeyUp.listen((dom.Event event) {
      scope.$apply(() {
        scope.date = ngModel.modelValue;
      });
    });
    
    // Outter change
    ngModel.render = () {
      var date = ngModel.viewValue != null ? dateFilter(ngModel.viewValue, dateFormat) : '';
      element.val(date);
      scope.date = ngModel.modelValue;
    };
    
//    addWatchableAttribute(attrs.min, 'min');
//    addWatchableAttribute(attrs.max, 'max');
//    if (attrs.showWeeks) {
//      addWatchableAttribute(attrs.showWeeks, 'showWeeks', 'show-weeks');
//    } else {
//      scope.showWeeks = 'show-weeks' in datepickerOptions ? datepickerOptions['show-weeks'] : datepickerConfig.showWeeks;
//      datepickerEl.attr('show-weeks', 'showWeeks');
//    }
//    if (attrs.dateDisabled) {
//      datepickerEl.attr('date-disabled', attrs.dateDisabled);
//    }
    
    scope.$watch('isOpen', (value) {
      if (value != null) {
        updatePosition();
        dom.document.onClick.listen(documentClickBind);
        if(elementFocusInitialized) {
          element.removeEventListener('focus', elementFocusBind);
        }
        element.focus();
        documentBindingInitialized = true;
      } else {
        if(documentBindingInitialized) {
          dom.document.removeEventListener('click', documentClickBind);
        }
        element.onFocus.listen(elementFocusBind);
        elementFocusInitialized = true;
      }

//      if ( setIsOpen ) {
//        setIsOpen(originalScope, value);
//      }
      
      scope.today = () {
        scope.dateSelection(new DateTime.now());
      };
      
      scope.clear = () {
        scope.dateSelection(null);
      };

      dom.Element popup = compiler(popupEl)(scope);
      if (_appendToBody ) {
        dom.document.body.append(popup);
      } else {
        element.insertAdjacentElement('after', popup);
      }
    });
  }
  
  
//    var getIsOpen, setIsOpen;
//    if ( attrs.isOpen ) {
//      getIsOpen = $parse(attrs.isOpen);
//      setIsOpen = getIsOpen.assign;
//
//      originalScope.$watch(getIsOpen, function updateOpen(value) {
//        scope.isOpen = !! value;
//      });
//    }
//    scope.isOpen = getIsOpen ? getIsOpen(originalScope) : false; // Initial state
  
//  void setOpen( value ) {
//    if (setIsOpen) {
//      setIsOpen(originalScope, !!value);
//    } else {
//      scope.isOpen = !!value;
//    }
//  }
  
  void documentClickBind(dom.Event event) {
    if (isOpen && event.target != element) {
      scope.$apply(() {
        //setOpen(false);
        isOpen = false;
      });
    }
  }
  
  void elementFocusBind(dom.Event event) {
    scope.$apply(() {
      //setOpen( true );
      isOpen = true;
    });
  }
  
  // TODO: reverse from dateFilter string to Date object
  DateTime parseDate(viewValue) {
    if (viewValue == null) {
      ngModel.setValidity('date', true);
      return null;
    } else if (viewValue is DateTime) {
      ngModel.setValidity('date', true);
      return viewValue;
    } else if (viewValue is String) {
      try {
        var date = DateTime.parse(viewValue);
        ngModel.setValidity('date', true);
        return date;
      } on FormatException catch(e) {
        ngModel.setValidity('date', false);
        return null;
      }
    } else {
      ngModel.setValidity('date', false);
      return null;
    }
  }

  // Inner change
  void dateSelection(dt) {
    if (dt != null) {
      // TODO: Is it scope
      scope.date = dt;
    }
    // TODO: Is it scope
    ngModel.viewValue = scope.date;
    ngModel.render();

    if (_closeOnDateSelection) {
      //setOpen( false );
      isOpen = false;
    }
  }
  
  void addWatchableAttribute(attribute, scopeProperty, datepickerAttribute) {
    if (attribute != null) {
      originalScope.$watch($parse(attribute), (value){
        scope[scopeProperty] = value;
      });
      datepickerEl.attributes[datepickerAttribute != null ? datepickerAttribute : scopeProperty] = scopeProperty;
    }
  }
  
  void updatePosition() {
    scope.position = _appendToBody ? position.offset(element) : position.position(element);
    scope.position.top = scope.position.top + element.offsetHeight;
  }
}



@NgComponent(selector: 'datepicker-popup-wrap', publishAs: 'd', 
    applyAuthorStyles: true, 
    templateUrl: 'packages/angular_ui/datepicker/popup.html')
@NgComponent(selector: '[datepicker-popup-wrap]', publishAs: 'd', 
    applyAuthorStyles: true, 
    templateUrl: 'packages/angular_ui/datepicker/popup.html')
class SatepickerPopupWrap {
  SatepickerPopupWrap(dom.Element element) {
    element.onClick.listen((dom.Event event) {
      event.preventDefault();
      event.stopPropagation();
    });
  }
}