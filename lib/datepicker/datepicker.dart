// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.datepicker;

import 'dart:html' as dom;
import "package:angular/angular.dart";

/**
 * Alert Module.
 */
class AlertModule extends Module {
  AlertModule() {
    //type(Alert);
    value(DatepickerConfig, new DatepickerConfig());
    value(DatepickerPopupConfig, new DatepickerPopupConfig());
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
  bool closeOnDateSelection = false;
  bool appendToBody = false;
  bool showButtonBar = false;
  
  @NgAttr('datepicker-popup')
  void set datepickerPopup(String value) {
    dateFormat = value != null ? value : datepickerPopupConfig.dateFormat;
    ngModel.render();
  }
  
  Scope scope;
  dom.Element element;
  NodeAttrs attrs;
  NgModel ngModel;
  
  DatepickerConfig datepickerConfig;
  DatepickerPopupConfig datepickerPopupConfig;
  
  DatepickerPopup(Scope originalScope, this.element, this.attrs, this.ngModel, this.datepickerPopupConfig, this.datepickerConfig) {
    // create a child scope so we are not polluting original one
    scope = originalScope.$new();
    closeOnDateSelection = attrs.containsKey('close-on-date-selection') ? originalScope.$eval(attrs['close-on-date-selection']) : datepickerPopupConfig.closeOnDateSelection;
    appendToBody = attrs.containsKey('datepicker-append-to-body') ? originalScope.$eval(attrs['datepicker-append-to-body']) : datepickerPopupConfig.appendToBody;
    showButtonBar = attrs.containsKey('show-button-bar') ? originalScope.$eval(attrs['show-button-bar']) : datepickerPopupConfig.appendToBody;
    
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