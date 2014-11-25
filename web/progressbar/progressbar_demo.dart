// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

/**
 * Progress bar controller.
 */
@Component(
  selector: 'progress-demo', 
  templateUrl: 'progressbar/progressbar_demo.html',
  useShadowDom: false
)
class ProgressDemo implements ScopeAware {

  Scope scope;
  
  math.Random _random = new math.Random();

  int max = 200;
  String type;
  int value = 0;
  int dynamic;

  var stacked = [];
  var showWarning;

  void random() {
    value = ((_random.nextDouble() * 100).floor() + 1);
    dynamic = value;

    if (value < 25) {
      type = 'success';
    } else if (value < 50) {
      type = 'info';
    } else if (value < 75) {
      type = 'warning';
    } else {
      type = 'danger';
    }

    showWarning = (type == 'danger' || type == 'warning');
  }

  void randomStacked() {
    stacked = [];
    var types = ['success', 'info', 'warning', 'danger'];

    for (var i = 0, n = ((_random.nextDouble() * 4).floor() + 1); i < n; i++) {
      var index = ((_random.nextDouble() * 4)).floor();
      stacked.add({
          'value': ((_random.nextDouble() * 30) + 1).floor(), 'type': types[index]
      });
    }
  }

  ProgressDemo() {
    randomStacked();
    random();
  }
}