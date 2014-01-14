// Copyright (c) 2013, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.demo;

import 'package:angular/angular.dart';
import 'package:angular_ui/buttons.dart';

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
    type(ButtonsCtrl);
  }
}

/**
 * Buttons controller.
 */
@NgController(selector: 'buttons-ctrl', publishAs: 'ctrl')
class ButtonsCtrl {
  
  @NgTwoWay("singleModel")
  var singleModel = '0';
  
  @NgTwoWay("radioModel")
  var radioModel = 'Middle';
  
  @NgTwoWay("leftModel")
  var leftModel = false;
  
  @NgTwoWay("middleModel")
  var middleModel = false;
  
  @NgTwoWay("rightModel")
  var rightModel = false;
}