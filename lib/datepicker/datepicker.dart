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
    value(DatepickerPopupConfig, new DatepickerPopupConfig());
    type(Datepicker);
    type(DatepickerPopupWrap);
    type(DatepickerPopup);
  }
}

/**
 * Datepicker configuration.
 */
class DatepickerConfig {
  String dayFormat = 'dd';
  String monthFormat = 'MMMM';
  String yearFormat = 'yyyy';
  String dayHeaderFormat = 'EEE';
  String dayTitleFormat = 'MMMM yyyy';
  String monthTitleFormat = 'yyyy';
  bool showWeeks = true;
  int startingDay = 0;
  int yearRange = 20;
  String minDate = null;
  String maxDate = null;
}

/**
 * List of visible dates.
 */
class VisibleDates {
  List objects = [];
  String title = '';
  List labels = [];
}

/**
 * Date format to show.
 */
class Format {
  String day;
  String month;
  String year;
  String dayHeader;
  String dayTitle;
  String monthTitle;
}

/**
 * Date Value Object
 */
class DateVO {
  DateTime date;
  String label = '';
  bool selected = false;
  bool secondary = false;
  bool disabled = false;
}

typedef VisibleDates GetVisibleDates(DateTime date, DateTime selected);

/**
 * Datepicker mode.
 */
class Mode {
  String name;
  GetVisibleDates getVisibleDates;
  int split;
  Function compare;
  Map step;
}

/**
 * Datepicker.
 */
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
  var format, startingDay, yearRange;
  List<Mode> modes;

//  @NgOneWay('date-disabled')
//  bool dateDisabled = false;

  bool _showWeeks = false;
  @NgOneWay('show-weeks')
  set showWeeks(bool value) {
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

  void refill([bool updateSelected = false]) {
    DateTime date;
    bool valid = true;
    
      if (_ngModel.modelValue != null) {
        try {
          if (_ngModel.modelValue is String) {
            date = DateTime.parse(_ngModel.modelValue);
          } else if (_ngModel.modelValue is int) {
            date = new DateTime.fromMillisecondsSinceEpoch(_ngModel.modelValue);
          } else {
            date = _ngModel.modelValue as DateTime;
          }
        } on Exception catch(e) {
          print(e);
        }
  
        if (date == null) {
          valid = false;
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
    if (mode == 0) {
      DateTime dt;

      if (_ngModel.modelValue == null) {
        dt = new DateTime(0, 0, 0);
      } else {
        if (_ngModel.modelValue is String) {
          dt = DateTime.parse(_ngModel.modelValue);
        } else if (_ngModel.modelValue is int) {
          dt = new DateTime.fromMillisecondsSinceEpoch(_ngModel.modelValue);
        } else {
          dt = _ngModel.modelValue as DateTime;
        }
      }

      //dt = new DateTime(date.year, date.month, date.day);
      _ngModel.viewValue = dt;
      refill(true);
    } else {
      selected = date;
      setMode(mode - 1);
    }
  }

  void move(int direction) {
    var step = modes[mode].step;
    int month = selected.month + direction * (step.containsKey('months') ?
        step['months'] : 0);
        // selected.setMonth( selected.getMonth() + direction * (step.months || 0) );
    int year = selected.year + direction * (step.containsKey('years') ?
        step['years'] : 0);
        // selected.setFullYear( selected.getFullYear() + direction * (step.years || 0) );
    selected = new DateTime(year, month, selected.day, selected.hour,
        selected.minute, selected.second, selected.millisecond);
    refill();
  }

  void toggleMode() {
    setMode((mode + 1) % modes.length);
  }

  int getWeekNumber(List row) {
    return (mode == 0 && showWeekNumbers && row.length == 7) ?
        getISO8601WeekNumber(row[0].date) : null;
  }

  int getISO8601WeekNumber(DateTime date) {
    var checkDate = new DateTime(date.year, date.month, date.day + 4 - date.day
        % 7);
    var time = new DateTime(checkDate.year, 1, 1);
        // Compare with Jan 1 the same year
    return ((((checkDate.millisecondsSinceEpoch - time.millisecondsSinceEpoch) /
        86400000).round() / 7) + 1).floor();
  }

  void init() {
    format = new Format()
        ..day = getValue(_attrs['day-format'], _datepickerConfig.dayFormat)
        ..month = getValue(_attrs['month-format'], _datepickerConfig.monthFormat
            )
        ..year = getValue(_attrs['year-format'], _datepickerConfig.yearFormat)
        ..dayHeader = getValue(_attrs['day-header-format'],
            _datepickerConfig.dayHeaderFormat)
        ..dayTitle = getValue(_attrs['day-title-format'],
            _datepickerConfig.dayTitleFormat)
        ..monthTitle = getValue(_attrs['month-title-format'],
            _datepickerConfig.monthTitleFormat);

    startingDay = getValue(_attrs['starting-day'], _datepickerConfig.startingDay
        );
    yearRange = getValue(_attrs['year-rRange'], _datepickerConfig.yearRange);

    minDate = _datepickerConfig.minDate != null ? DateTime.parse(
        _datepickerConfig.minDate) : null;
    maxDate = _datepickerConfig.maxDate != null ? DateTime.parse(
        _datepickerConfig.maxDate) : null;

    modes = [
        new Mode()
          ..name = 'day'
          ..getVisibleDates = (DateTime date, DateTime selected) {
            var year = date.year, 
                month = date.month, 
                firstDayOfMonth = new DateTime(year, month, 1);
            var difference = startingDay - firstDayOfMonth.day,
                numDisplayedFromPreviousMonth = (difference > 0) ? 7 - difference : -difference,
                firstDate = new DateTime.fromMillisecondsSinceEpoch(firstDayOfMonth.millisecondsSinceEpoch), 
                numDates = 0;

            if (numDisplayedFromPreviousMonth > 0) {
              firstDate = firstDate.add(new Duration(days: -numDisplayedFromPreviousMonth + 1));
              numDates += numDisplayedFromPreviousMonth; // Previous
            }
            numDates += getDaysInMonth(year, month + 1); // Current
            numDates += (7 - numDates % 7) % 7; // Next

            var days = getDates(firstDate, numDates), 
                labels = new List(7);
            for (var i = 0; i < numDates; i++) {
              DateTime dt = days[i];
              days[i] = makeDate(dt, format.day, selected != null &&
                  selected.day == dt.day && selected.month == dt.month && 
                  selected.year == dt.year, dt.month != month);
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
            return new DateTime(date1.year, date1.month, date1.day).compareTo(
                new DateTime(date2.year, date2.month, date2.day));
          }
          ..split = 7
          ..step = {
            'months': 1
          }, 
        new Mode()
          ..name = 'month'
          ..getVisibleDates = (DateTime date, DateTime selected) {
            var months = new List(), 
                year = date.year;
            for (var i = 1; i <= 12; i++) {
              var dt = new DateTime(year, i, 1);
              months.add(makeDate(dt, format.month, 
                  (selected != null && selected.month == i && selected.year == year)));
            }
            return new VisibleDates()
                ..objects = months
                ..title = _dateFilter(date, format.monthTitle);
          }
          ..compare = (DateTime date1, DateTime date2) {
            return new DateTime(date1.year, date1.month).compareTo(new DateTime(
                date2.year, date2.month));
          }
          ..split = 3
          ..step = {
            'years': 1
          }, new Mode()
          ..name = 'year'
          ..getVisibleDates = (DateTime date, DateTime selected) {
            var years = new List(), 
                year = date.year, 
                startYear = (((year - 1) / yearRange) * yearRange + 1).toInt();
            for (var i = 0; i < yearRange; i++) {
              var dt = new DateTime(startYear + i, 1, 1);
              years.add(makeDate(dt, format.year, 
                  (selected != null && selected.year == dt.year)));
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
          }];

  }


  dynamic getValue(value, defaultValue) {
    var val = _scope.$eval(value);
    return val != null ? val : defaultValue;
  }

  int getDaysInMonth(year, month) {
    return new DateTime(year, month, 0).day;
  }

  List getDates(DateTime startDate, int n) {
    var dates = new List();
    var current = startDate, i = 0;
    while (i++ < n) {
      dates.add(new DateTime.fromMillisecondsSinceEpoch(
          current.millisecondsSinceEpoch));
      current = current.add(new Duration(days: 1));
          // setDate( current.getDate() + 1 );
    }
    return dates;
  }

  DateVO makeDate(DateTime date, String format, bool isSelected, [bool
      isSecondary = false]) {
    return new DateVO()
        ..date = date
        ..label = _dateFilter(date, format)
        ..selected = !!isSelected
        ..secondary = !!isSecondary;
  }


  bool isDisabled(DateTime date, [int mode = 0]) {
    var currentMode = modes[mode];
    return ((minDate != null && currentMode.compare(date, minDate) < 0) ||
        (maxDate != null && currentMode.compare(date, this.maxDate) > 0));
        //|| dateDisabled);
        //(dateDisabled && dateDisabled({'date': date, 'mode': currentMode.name})));
  }
}



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
  
//  @NgOneWay('date-disabled')
//  bool dateDisabled = false;
  
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
    //  date-disabled='dateDisabled'
    
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