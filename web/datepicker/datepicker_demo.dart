// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

/**
 * Datepicker controller.
 */
@Component(
    selector: 'datepicker-demo',
    templateUrl: 'datepicker/datepicker_demo.html',
    useShadowDom: false
)
class DatepickerDemo {
  
  var dt;
  bool showWeeks = true;
  DateTime minDate;
  bool opened = false;
  Map dateOptions = {
   'year-format': '\'yy\'',
   'starting-day': 1
  };
  List formats = ['dd-MMMM-yyyy', 'yyyy/MM/dd', 'shortDate'];
  String format;
  
//  Date filter;
  
  DatepickerDemo() { //this.filter ) {
    toggleMin();
    format = formats[0];
  }
  
  void today() {
    dt = new DateTime.now();
  }
  
  void toggleWeeks() {
    showWeeks = !showWeeks;
  }
  
  void clear() {
    dt = null;
  }
  
  bool disabled(DateTime date, mode) {
    return ( mode == 'day' && ( date.day == 0 || date.day == 6 ) );
  }
  
  void toggleMin() {
    minDate = minDate == null ? new DateTime.now() : null;
  }
  
  void open(dom.Event event) {
    event.preventDefault();
    event.stopPropagation();

    opened = true;
  }
  
//  String translate(DateTime date) {
//    return filter.call(date, format);
//  }
}