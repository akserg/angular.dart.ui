// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.datepicker;

import 'dart:html' as dom;
import "package:angular/angular.dart";
import "package:angular_ui/utils/position.dart";
import 'package:angular_ui/utils/utils.dart';

/**
 * Datepicker Module.
 */
class DatepickerModule extends Module {
  DatepickerModule() {
    install(new PositionModule());
    value(DatepickerConfig, new DatepickerConfig());
    type(Datepicker);
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
  String minDate= null;
  String maxDate= null;
}

class VisibleDates {
  List objects = []; 
  String title = ''; 
  List labels = []; 
}

class Format {
  String day;
  String month;
  String year;
  String dayHeader;
  String dayTitle;
  String monthTitle;
}

class DateVO {
  DateTime date; 
  String label = ''; 
  bool selected = false; 
  bool secondary = false; 
  bool disabled = false;
}

typedef VisibleDates GetVisibleDates(DateTime date, DateTime selected);

class Mode {
  String name;
  GetVisibleDates getVisibleDates;
  int split;
  Function compare;
  Map step;
}

@NgComponent(selector: 'datepicker[ng-model]', publishAs: 'd', 
    applyAuthorStyles: true, 
    templateUrl: 'packages/angular_ui/datepicker/datepicker.html')
@NgComponent(selector: '[datepicker][ng-model]', publishAs: 'd', 
    applyAuthorStyles: true, 
    templateUrl: 'packages/angular_ui/datepicker/datepicker.html')
class Datepicker {
  
  int mode = 0;
  DateTime selected = new DateTime.now();
  bool showWeekNumbers = false;
  List rows;
  List labels;
  String title;
  
  @NgOneWay('date-disabled')
  bool dateDisabled = false;

  bool _showWeeks = false;
  @NgOneWay('show-weeks')
  set showWeeks(bool value){
    _showWeeks = value;
    updateShowWeekNumbers();
  }
  bool get showWeeks => _showWeeks;
  
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
    refill();
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
    refill();
  }
  
  dom.Element _element;
  DatepickerConfig _datepickerConfig;
  NodeAttrs _attrs;
  NgModel _ngModel;
  Scope _scope;
  DateFilter _dateFilter;
  
  Datepicker(this._element, this._datepickerConfig, this._attrs, this._ngModel, this._scope, this._dateFilter) {
    showWeeks = _datepickerConfig.showWeeks;
    
    _ngModel.render = (value) {
      refill(true);
    };
    
    init();
  }
  
  
  void updateShowWeekNumbers() {
    showWeekNumbers = mode == 0 && showWeeks;
  }
  
  // split
  
  void refill([bool updateSelected = false]) {
    DateTime date;
    bool valid = true;

    if (_ngModel.modelValue != null) {
      if (_ngModel.modelValue is String) {
        date = DateTime.parse(_ngModel.modelValue);
      } else if (_ngModel.modelValue is int) {
        date = new DateTime.fromMillisecondsSinceEpoch(_ngModel.modelValue);
      } else {
        date = _ngModel.modelValue as DateTime;
      }

      if (date == null) {
        valid = false;
        //$log.error('Datepicker directive: "ng-model" value must be a Date object, a number of milliseconds since 01.01.1970 or a string representing an RFC2822 or ISO 8601 date.');
      } else if (updateSelected) {
        selected = date;
      }
    }
    _ngModel.setValidity('date', valid);

    var currentMode = modes[mode];
    var data = currentMode.getVisibleDates(selected, date);
    data.objects.forEach((DateVO obj) {
      obj.disabled = isDisabled(obj.date, mode);
    });

    _ngModel.setValidity('date-disabled', (date == null || !isDisabled(date)));

    rows = split(data.objects, currentMode.split);
    labels = data.labels;
    title = data.title;
  }
  
  // Split array into smaller arrays
  List split(List arr, int size) {
    var arrays = [];
    while (arr.length > 0) {
      arrays.add(arr.getRange(0, size).toList());
      arr.removeRange(0, size);
    }
    return arrays;
  }
  
  void setMode(value) {
    mode = value;
    updateShowWeekNumbers();
    refill();
  }
  
  void select(DateTime date) {
    if (mode == 0 ) {
      DateTime dt;
      
      if (_ngModel.modelValue == null) {
        dt = new DateTime(0, 0, 0, 0, 0, 0, 0);
      } else {
        if (_ngModel.modelValue is String) {
          dt = DateTime.parse(_ngModel.modelValue);
        } else if (_ngModel.modelValue is int) {
          dt = new DateTime.fromMillisecondsSinceEpoch(_ngModel.modelValue);
        } else {
          dt = _ngModel.modelValue as DateTime;
        }
      }      
      
      dt = new DateTime(date.year, date.month, date.day, dt.hour, dt.minute, dt.second, dt.millisecond);
      _ngModel.viewValue = dt;
      refill(true);
    } else {
      selected = date;
      setMode(mode - 1);
    }
  }
  
  void move(int direction) {
    var step = modes[mode].step;
    int month = selected.month + direction * (step.containsKey('months') ? step['months'] : 0); // selected.setMonth( selected.getMonth() + direction * (step.months || 0) );
    int year = selected.year + direction * (step.containsKey('years') ? step['years'] : 0); // selected.setFullYear( selected.getFullYear() + direction * (step.years || 0) );
    selected = new DateTime(year, month, selected.day, selected.hour, selected.minute, selected.second, selected.millisecond);
    refill();
  }
  
  void toggleMode() {
    setMode( (mode + 1) % modes.length );
  }
  
  int getWeekNumber(List row) {
    return ( mode == 0 && showWeekNumbers && row.length == 7 ) ? getISO8601WeekNumber(row[0].date) : null;
  }
  
  int getISO8601WeekNumber(DateTime date) {
    var checkDate = new DateTime(date.year, date.month, date.day + 4 - date.day % 7);
    var time = new DateTime(checkDate.year, 1, 1); // Compare with Jan 1 the same year
    return ((((checkDate.millisecondsSinceEpoch - time.millisecondsSinceEpoch) / 86400000).round() / 7) + 1).floor();
  }
  
  /******/
  var format, 
      startingDay, 
      yearRange;
  List<Mode> modes;

  void init() {
    format = new Format()
      ..day = getValue(_attrs['day-format'], _datepickerConfig.dayFormat)
      ..month = getValue(_attrs['month-format'], _datepickerConfig.monthFormat)
      ..year = getValue(_attrs['year-format'], _datepickerConfig.yearFormat)
      ..dayHeader = getValue(_attrs['day-header-format'], _datepickerConfig.dayHeaderFormat)
      ..dayTitle = getValue(_attrs['day-title-format'], _datepickerConfig.dayTitleFormat)
      ..monthTitle = getValue(_attrs['month-title-format'], _datepickerConfig.monthTitleFormat);
    
    startingDay = getValue(_attrs['starting-day'], _datepickerConfig.startingDay);
    yearRange =   getValue(_attrs['year-rRange'], _datepickerConfig.yearRange);
  
    minDate = _datepickerConfig.minDate != null ? DateTime.parse(_datepickerConfig.minDate) : null;
    maxDate = _datepickerConfig.maxDate != null ? DateTime.parse(_datepickerConfig.maxDate) : null;

    modes = [
      new Mode()
        ..name = 'day'
        ..getVisibleDates = (DateTime date, DateTime selected) {
          var year = date.year, 
              month = date.month, 
              firstDayOfMonth = new DateTime(year, month, 1);
          var difference = startingDay - firstDayOfMonth.day,
              numDisplayedFromPreviousMonth = (difference > 0) ? 7 - difference : - difference,
              firstDate = new DateTime.fromMillisecondsSinceEpoch(firstDayOfMonth.millisecondsSinceEpoch), 
              numDates = 0;
  
          if (numDisplayedFromPreviousMonth > 0 ) {
            firstDate = firstDate.add(new Duration(days:- numDisplayedFromPreviousMonth + 1)); // firstDate.setDate( - numDisplayedFromPreviousMonth + 1 );
            numDates += numDisplayedFromPreviousMonth; // Previous
          }
          numDates += getDaysInMonth(year, month + 1); // Current
          numDates += (7 - numDates % 7) % 7; // Next
  
          var days = getDates(firstDate, numDates), 
              labels = new List(7);
          for (var i = 0; i < numDates; i ++) {
            DateTime dt = days[i];
            days[i] = makeDate(dt, format.day, selected != null && selected.day == dt.day && selected.month == dt.month && selected.year == dt.year, dt.month != month);
          }
          for (var j = 0; j < 7; j++) {
            labels[j] = _dateFilter(days[j].date, format.dayHeader);
          }
          return new VisibleDates() 
            ..objects = days 
            ..title = _dateFilter(date, format.dayTitle) 
            ..labels = labels; 
        }
        ..compare = (DateTime date1, DateTime date2) {
          return new DateTime(date1.year, date1.month, date1.day).compareTo(new DateTime(date2.year, date2.month, date2.day));
        }
        ..split = 7
        ..step = { 
           'months': 1 
         },
      new Mode()
        ..name = 'month'
        ..getVisibleDates = (DateTime date, DateTime selected) {
          var months = new List(12), 
              year = date.year; //getFullYear();
          for ( var i = 0; i < 12; i++ ) {
            var dt = new DateTime(year, i, 1);
            months[i] = makeDate(dt, format.month, (selected != null && selected.month == i && selected.year == year));
          }
          return new VisibleDates() 
          ..objects = months 
          ..title = _dateFilter(date, format.monthTitle);
        }
        ..compare = (DateTime date1, DateTime date2) {
          return new DateTime(date1.year, date1.month).compareTo(new DateTime(date2.year, date2.month));
        }
        ..split = 3
        ..step = { 
         'years': 1 
        },
      new Mode()
        ..name = 'year'
        ..getVisibleDates = (DateTime date, DateTime selected) {
          var years = new List(yearRange), 
              year = date.year, 
              startYear = ((year - 1) / yearRange) * yearRange + 1;
          for ( var i = 0; i < yearRange; i++ ) {
            var dt = new DateTime(startYear + i, 0, 1);
            years[i] = makeDate(dt, format.year, (selected != null && selected.year == dt.year));
          }
          return new VisibleDates() 
            ..objects = years 
            ..title = [years[0].label, years[yearRange - 1].label].join(' - ');
        }
        ..compare = (DateTime date1, DateTime date2) {
          return date1.year - date2.year;
        }
        ..split = 5
        ..step = { 
         'years': yearRange 
        }
    ];

  }
  
  
  dynamic getValue(value, defaultValue) {
    var val = _scope.$eval(value);
    return val != null ? val : defaultValue;
  }

  int getDaysInMonth( year, month ) {
    return new DateTime(year, month, 0).day;
  }

  List getDates(DateTime startDate, int n) {
    var dates = new List();
    var current = startDate, 
        i = 0;
    while (i++ < n) {
      dates.add(new DateTime.fromMillisecondsSinceEpoch(current.millisecondsSinceEpoch));
      current = current.add(new Duration(days:1)); // setDate( current.getDate() + 1 );
    }
    return dates;
  }

  DateVO makeDate(DateTime date, String format, bool isSelected, [bool isSecondary = false]) {
    return new DateVO() 
      ..date = date 
      ..label = _dateFilter(date, format) 
      ..selected = !!isSelected
      ..secondary = !!isSecondary; 
  }


  bool isDisabled(DateTime date, [int mode = 0]) {
    var currentMode = modes[mode];
    return (
        (minDate != null && currentMode.compare(date, minDate) < 0) || 
        (maxDate != null && currentMode.compare(date, this.maxDate) > 0) ||
        dateDisabled); //(dateDisabled && dateDisabled({'date': date, 'mode': currentMode.name})));
  }
}


/*
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
    String html = '<div datepicker-popup-wrap><div datepicker></div></div>';
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
      var date = ngModel.viewValue != null ? _dateFilter(ngModel.viewValue, dateFormat) : '';
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
      
      scope.clearDate = () {
        scope.dateSelection(null);
      };

      List<dom.Element> rootElements = toNodeList(html);
      
      dom.Element popup = compiler(html)(scope);
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
  
  // TODO: reverse from _dateFilter string to Date object
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
*/