// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.datepicker;

import 'dart:html' as dom;
import "package:angular/angular.dart";
import "package:angular/core_dom/module_internal.dart";
import "package:angular_ui/utils/position.dart";
import 'package:angular_ui/utils/utils.dart';

part 'popup.dart';

/**
 * Datepicker Module.
 */
class DatepickerModule extends Module {
  DatepickerModule() {
    install(new PositionModule());
    bind(DatepickerConfig, toValue:new DatepickerConfig());
    bind(DatepickerPopupConfig, toValue:new DatepickerPopupConfig());
    bind(Datepicker);
    bind(DatepickerPopupWrap);
    bind(DatepickerPopup);
    bind(WeekNumberFilter);
  }
}

typedef VisibleDates _GetVisibleDates(DateTime date, DateTime selected);

/**
 * Datepicker configuration.
 */
@Injectable()
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
@Injectable()
class VisibleDates {
  List objects = [];
  String title = '';
  List labels = [];
}

/**
 * Date format to show.
 */
@Injectable()
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
@Injectable()
class DateVO {
  DateTime date;
  String label = '';
  bool selected = false;
  bool secondary = false;
  bool disabled = false;
}

/**
 * Datepicker mode.
 */
@Injectable()
class Mode {
  String name;
  _GetVisibleDates getVisibleDates;
  int split;
  Function compare;
  Map step;
}

/**
 * Datepicker.
 */
@Component(
    selector: 'datepicker[ng-model]',
    useShadowDom: false,
    template: '''
<table>
  <thead>
    <tr>
      <th><button type="button" class="btn btn-default btn-sm pull-left" ng-click="move(-1)"><i class="glyphicon glyphicon-chevron-left"></i></button></th>
      <th id="title"><button type="button" class="btn btn-default btn-sm btn-block" ng-click="toggleMode()"></button></th>
      <th><button type="button" class="btn btn-default btn-sm pull-right" ng-click="move(1)"><i class="glyphicon glyphicon-chevron-right"></i></button></th>
    </tr>
    <tr id="labels" class="h6">
    </tr>
  </thead>
  <tbody id="rows">
  </tbody>
</table>'''
    //templateUrl: 'packages/angular_ui/datepicker/datepicker.html'
)
//@Component(selector: '[datepicker][ng-model]', publishAs: 'd', 
//    useShadowDom: false, 
//    templateUrl: 'packages/angular_ui/datepicker/datepicker.html')
class Datepicker implements ShadowRootAware, ScopeAware {

  int mode = 0;
  DateTime selected = new DateTime.now();
  bool showWeekNumbers = false;

  var _lastModelValue;
  bool _modelValueChanged = false;
  bool get modelValueChanged {
    var res = _modelValueChanged;
    _modelValueChanged = false;
    return res;
  }

  Mode get currentMode {
    return modes[mode];
  }
  
  var format;
  List<Mode> modes;
  
  @NgOneWay('day-format')
  void set dayFormat(String value) {
    format.day = value != null ? value : _datepickerConfig.dayFormat;
  }
  
  @NgOneWay('month-format')
  void set monthFormat(String value) {
    format.month = value != null ? value : _datepickerConfig.monthFormat;
  }
  
  @NgOneWay('year-format')
  void set yearFormat(String value) {
    format.year = value != null ? value : _datepickerConfig.yearFormat;
  }
   
  @NgOneWay('day-header-format')
  void set dayHeaderFormat(String value) {
    format.dayHeader = value != null ? value : _datepickerConfig.dayHeaderFormat;
  }
  
  @NgOneWay('day-title-format')
  void set dayTitleFormat(String value) {
    format.dayTitle = value != null ? value : _datepickerConfig.dayTitleFormat;
  }
   
  @NgOneWay('month-title-format')
  void set monthTitleFormat(String value) {
    format.monthTitle = value != null ? value : _datepickerConfig.monthTitleFormat;
  }
  
  int _startingDay;
  @NgOneWay('starting-day')
  void set startingDay(int value) {
    _startingDay = value != null ? value : _datepickerConfig.startingDay;
  }
  int get startingDay => _startingDay;
  
  int _yearRange;
  @NgOneWay('year-range')
  void set yearRange(int value) {
    _yearRange = value != null ? value : _datepickerConfig.yearRange;
  }
  int get yearRange => _yearRange;
  
  var _dateDisabled = null;
  @NgCallback('date-disabled')
  void set dateDisabled(value) {
    _dateDisabled = null;
  }
  get dateDisabled => _dateDisabled;
  
  bool _showWeeks = false;
  @NgOneWay('show-weeks')
  set showWeeks(bool value) {
    if (value == null) {
      value = false;
    }
    _showWeeks = value;
    updateShowWeekNumbers();
  }
  bool get showWeeks => _showWeeks;

  DateTime minDate;
  @NgOneWay('min')
  void set min(value) {
    minDate = parseDate(value);
    refill();
  }

  DateTime maxDate;
  @NgOneWay('max')
  void set max(value) {
    maxDate = parseDate(value);
    refill();
  }

  dom.Element _element;
  DatepickerConfig _datepickerConfig;
  NodeAttrs _attrs;
  NgModel _ngModel;
  Scope _scope;
  Date _dateFilter;
  
  List rows;
  List labels;
  
  Datepicker(this._element, this._datepickerConfig, this._attrs, this._ngModel, this._dateFilter);
  
  void set scope(Scope scope) {
    this._scope = scope;
    init();

    showWeeks = _datepickerConfig.showWeeks;
    
    _ngModel.render = (value) {
      refill(true);
    };
  }

  /**
   * Redraw component first time because ShadowRoot are available now.
   */
  @override
  void onShadowRoot(shadowRoot) {
    refill(true);
  }
  
  Datepicker.forTests(this._element, this._datepickerConfig, this._attrs, this._scope, this._dateFilter) {
    init();
  }
  
  
  void updateShowWeekNumbers() {
    showWeekNumbers = mode == 0 && showWeeks;
    showWeekNumbersEls();
  }

  void refill([bool updateSelected = false]) {
    bool valid = true;
    DateTime date = parseDate(_ngModel.modelValue);
    if (date == null) {
      valid = false;
    } else if (updateSelected) {
      selected = date;
    }
    
    var currentMode = modes[mode];
    VisibleDates data = currentMode.getVisibleDates(selected, date);
    data.objects.forEach((DateVO obj) {
      obj.disabled = isDisabled(obj.date, mode);
    });

    rows = split(data.objects, currentMode.split);
    labels = data.labels;
    String title = data.title;
    
    // DOM render
    
    dom.TableCellElement titleEl = _element.querySelector("#title");
    if (titleEl != null) {
      if (rows.length > 0) {
        titleEl.colSpan = rows[0].length - 2 + (showWeekNumbers ? 1 : 0);
      }
      (titleEl.firstChild as dom.ButtonElement).setInnerHtml('<strong>$title</strong>');
    }
    
    dom.TableRowElement labelsEl = _element.querySelector("#labels");
    if (labelsEl != null) {
      labelsEl.children.clear();
      
      dom.TableCellElement showWeekNumbersEl = new dom.TableCellElement();
      showWeekNumbersEl.classes.add("text-center");
      if (showWeekNumbers) {
        showWeekNumbersEl.classes.remove("ng-hide");
      } else {
        showWeekNumbersEl.classes.add("ng-hide");
      }
      showWeekNumbersEl.text = '#';
      labelsEl.append(showWeekNumbersEl);
      
      labels.forEach((String label) {
        dom.TableCellElement labelEl = new dom.TableCellElement();
        labelEl.classes.add("text-center");
        labelEl.text = label;
        labelsEl.append(labelEl);
      });
    }
    
    dom.TableSectionElement rowsEl = _element.querySelector("#rows");
    if (rowsEl != null) {
      rowsEl.children.clear();
      
      rows.forEach((List row){
        dom.TableRowElement rowEl = new dom.TableRowElement();
        rowsEl.append(rowEl);
        
        dom.TableCellElement rowWeekNumbersEl = new dom.TableCellElement();
        rowWeekNumbersEl.classes.add("text-center");
        if (showWeekNumbers) {
          rowWeekNumbersEl.classes.remove("ng-hide");
        } else {
          rowWeekNumbersEl.classes.add("ng-hide");
        }
        rowWeekNumbersEl.setInnerHtml('<em>${getWeekNumber(row)}</em>');
        rowEl.append(rowWeekNumbersEl);
  
        row.forEach((DateVO dt) {
          dom.TableCellElement dtEl = new dom.TableCellElement();
          dtEl.classes.add("text-center");
          rowEl.append(dtEl);
          
          dom.ButtonElement btnEl = new dom.ButtonElement()
          ..type = 'button'
          ..style.width = '100%'
          ..classes.add('btn btn-default btn-sm')
          ..onClick.listen((dom.MouseEvent evt){
            select(dt.date);
          });
          if (dt.selected) {
            btnEl.classes.add('btn-info');
          }
          if (dt.disabled) {
            btnEl.disabled = true;
          }
          dtEl.append(btnEl);
          
          dom.SpanElement labelSpan = new dom.SpanElement()
          ..text = dt.label;
          if (dt.secondary) {
            labelSpan.classes.add('text-muted');
          }
          btnEl.append(labelSpan);
        });
      });
    }
  }
  
  void showWeekNumbersEls() {
    dom.TableCellElement titleEl = _element.querySelector("#title");
    if (titleEl != null && rows != null && rows.length > 0) {
      titleEl.colSpan = rows[0].length - 2 + (showWeekNumbers ? 1 : 0);
    }
    //
    List<dom.TableCellElement> showWeekNumbersEls = _element.querySelectorAll("#labels > td");
    if (showWeekNumbersEls != null && showWeekNumbersEls.length > 0) {
      dom.TableCellElement showWeekNumbersEl = showWeekNumbersEls.first;
      if (showWeekNumbers) {
        showWeekNumbersEl.classes.remove("ng-hide");
      } else {
        showWeekNumbersEl.classes.add("ng-hide");
      }
    }
    //
    dom.TableSectionElement rowsEl = _element.querySelector("#rows");
    if (rowsEl != null) {
      rowsEl.children.forEach((dom.TableRowElement rowEl) {
        dom.TableCellElement rowWeekNumbersEl = rowEl.firstChild;
        if (showWeekNumbers) {
          rowWeekNumbersEl.classes.remove("ng-hide");
        } else {
          rowWeekNumbersEl.classes.add("ng-hide");
        }
      });
    }
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
        dt = new DateTime(0);
      } else {
        if (_ngModel.modelValue is String) {
          try {
            dt = DateTime.parse(_ngModel.modelValue);
          } on FormatException catch(ex) {
            dt = new DateTime(0);
          }
        } else if (_ngModel.modelValue is int) {
          dt = new DateTime.fromMillisecondsSinceEpoch(_ngModel.modelValue);
        } else {
          dt = _ngModel.modelValue as DateTime;
        }
      }

      _ngModel.viewValue = new DateTime(date.year, date.month, date.day, dt.hour, dt.minute, dt.second, dt.millisecond);
      refill(true);
    } else {
      selected = date;
      setMode(mode - 1);
    }
  }

  void move(int direction) {
    var step = modes[mode].step;
    int month = selected.month + direction * (step.containsKey('months') ? step['months'] : 0);
    int year = selected.year + direction * (step.containsKey('years') ? step['years'] : 0);
    selected = new DateTime(year, month, selected.day, selected.hour, selected.minute, selected.second, selected.millisecond);
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
    var checkDate = new DateTime(date.year, date.month, date.day + 4 - date.weekday % 7);
    var time = new DateTime(checkDate.year, 1, 1);
        // Compare with Jan 1 the same year
    return ((((checkDate.millisecondsSinceEpoch - time.millisecondsSinceEpoch) / 86400000).round() / 7) + 1).floor();
  }

  void init() {
    format = new Format()
    ..day = eval(_scope, _attrs['day-format'], _datepickerConfig.dayFormat)
    ..month = eval(_scope, _attrs['month-format'], _datepickerConfig.monthFormat)
    ..year = eval(_scope, _attrs['year-format'], _datepickerConfig.yearFormat)
    ..dayHeader = eval(_scope, _attrs['day-header-format'], _datepickerConfig.dayHeaderFormat)
    ..dayTitle = eval(_scope, _attrs['day-title-format'], _datepickerConfig.dayTitleFormat)
    ..monthTitle = eval(_scope, _attrs['month-title-format'], _datepickerConfig.monthTitleFormat);

    startingDay = eval(_scope, _attrs['starting-day'], _datepickerConfig.startingDay);
    yearRange = eval(_scope, _attrs['year-rRange'], _datepickerConfig.yearRange);

    minDate = _datepickerConfig.minDate != null ? DateTime.parse(_datepickerConfig.minDate) : null;
    maxDate = _datepickerConfig.maxDate != null ? DateTime.parse(_datepickerConfig.maxDate) : null;

    modes = [
        new Mode()
        ..name = 'day'
        ..getVisibleDates = (DateTime date, DateTime selected) {
          var year = date.year, 
              month = date.month, 
              firstDayOfMonth = new DateTime(year, month, 1);
          var difference = startingDay - firstDayOfMonth.weekday,
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
              labels = new List(); // !!! 7
          for (var i = 0; i < numDates; i++) {
            DateTime dt = days[i];
            days[i] = makeDate(dt, format.day, selected != null &&
                selected.day == dt.day && selected.month == dt.month && 
                selected.year == dt.year, dt.month != month);
          }
          for (var j = 0; j < 7; j++) {
            labels.add(_dateFilter(days[j].date, format.dayHeader));
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
        }, 
        new Mode()
        ..name = 'year'
        ..getVisibleDates = (DateTime date, DateTime selected) {
          var years = new List(), 
              year = date.year, 
              startYear =  ((year - 1) ~/ yearRange) * yearRange + 1;
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


  int getDaysInMonth(year, month) {
    return new DateTime(year, month, 0).day;
  }

  List getDates(DateTime startDate, int n) {
    var dates = new List();
    var i = 0;
    // Prevent repeated dates because of timezone bug
    var current = new DateTime(startDate.year, startDate.month, startDate.day, 12, 0, 0);
    while (i++ < n) {
      dates.add(new DateTime.fromMillisecondsSinceEpoch(current.millisecondsSinceEpoch));
      current = current.add(new Duration(days: 1));
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
        (maxDate != null && currentMode.compare(date, this.maxDate) > 0) ||
        (dateDisabled != null && dateDisabled({'date':date, 'mode':currentMode.name})));
  }
  
//  bool isDisabled(DateTime date, [int mode = 0]) {
//    var currentMode = modes[mode];
//    if (minDate != null) {
//      return currentMode.compare(date, minDate) < 0;
//    } else if (maxDate != null) {
//      return currentMode.compare(date, this.maxDate) > 0;
//    } else if (dateDisabled != null ){
//      return dateDisabled({'date': date, 'mode': currentMode.name});
//    }
//    return false;
//  }
}

/**
 * Filter to show week number
 */
@Formatter(name:'weekNumber')
class WeekNumberFilter {
  call(valueToFilter, datepicker) {
    if (valueToFilter != null && valueToFilter is List) {
      return datepicker.getWeekNumber(valueToFilter.toList());
    }
    return null;
  }
}
