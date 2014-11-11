// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

@Component(
    selector: 'timepicker-demo', 
    templateUrl: 'timepicker/timepicker_demo.html',
    exportExpressions: const ["ismeridian"],
    useShadowDom: false)
class TimepickerDemo implements ScopeAware {

  Scope scope;
  
  DateTime mytime = new DateTime.now();

  int hstep = 1;
  int mstep = 15;

  Map<String, List> options = {
    'hstep': [1, 2, 3],
    'mstep': [1, 5, 10, 15, 25, 30]
  };

  bool ismeridian = true;
  void toggleMode() {
    ismeridian = !ismeridian;
  }

  void update() {
    var d = new DateTime.now();
    mytime = new DateTime(d.year, d.month, d.day, 14, 0);
  }

  void changed() {
    print('Time changed to: $mytime');
  }

  void clear() {
    mytime = null;
  }

  
}
