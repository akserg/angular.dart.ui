// Copyright (c) 2013 - 2014, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.demo;

import 'package:angular/angular.dart';
import 'package:angular_ui/buttons.dart';
import 'package:angular_ui/collapse.dart';
import 'package:angular_ui/dropdown_toggle.dart';

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
    install(new DropdownToggleModule());
    type(ButtonsCtrl);
    type(CollapseCtrl);
    type(DropdownCtrl);
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

/**
 * Collapse controller.
 */
@NgController(selector: '[collapse-ctrl]', publishAs: 'ctrl')
class CollapseCtrl {
  
  var scope;
  
  var isCollapsed = true;
  
  CollapseCtrl(Scope this.scope);
}

/**
 * Buttons controller.
 */
@NgController(selector: '[dropdown-ctrl]', publishAs: 'ctrl')
class DropdownCtrl {
  
  var scope;
  
  List<Item> items;
  
  DropdownCtrl(Scope this.scope) {
    items = [
      new Item("The first choice!"),
      new Item("And another choice for you."),
      new Item("but wait! A third!")
    ];
  }
}

class Item {
  var label;
  
  Item(String this.label);
}