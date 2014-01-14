// Copyright (c) 2013, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.demo;

import 'package:angular/angular.dart';
import 'package:angular_ui/buttons.dart';
import 'package:angular_ui/collapse.dart';

/**
 * Entry point into app.
 */
main() {
  ngBootstrap(module: new DemoModule());
}

/**
 * Demo Module
 */
class DemoModule extends Module {
  DemoModule() {
    install(new ButtonsModule());
    install(new CollapseModule());
    type(ButtonsCtrl);
    type(CollapseCtrl);
  }
}

/**
 * Buttons controller.
 */
@NgController(selector: '[buttons-ctrl]', publishAs: 'ctrl')
class ButtonsCtrl {
  
  var scope;
  
  ButtonsCtrl(Scope this.scope);
  
  var singleModel = 1;
  
  var radioModel = 'Right';
  
  var leftModel = false;
  
  var middleModel = true;
  
  var rightModel = false;
}

@NgController(selector: '[collapse-ctrl]', publishAs: 'ctrl')
class CollapseCtrl {
  
  var scope;
  
  var isCollapsed = true;
  
  CollapseCtrl(Scope this.scope);
  
  void clickHandler() {
    isCollapsed = !isCollapsed;
    print('Click. $isCollapsed');
  }
}