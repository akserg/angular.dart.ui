// Copyright (c) 2013 - 2014, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.demo;

import 'package:angular/angular.dart';
import 'package:angular_ui/angular_ui.dart';

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
    install(new AngularUIModule());
    //
    type(ButtonsCtrl);
    type(CollapseCtrl);
    type(DropdownCtrl);
    type(AlertCtrl);
  }
}

/**
 * Buttons controller.
 */
@NgController(selector: '[buttons-ctrl]', publishAs: 'ctrl')
class ButtonsCtrl {
  
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
  
  var isCollapsed = true;
}

/**
 * Dropdown controller.
 */
@NgController(selector: '[dropdown-ctrl]', publishAs: 'ctrl')
class DropdownCtrl {
  
  var items = [
    "The first choice!",
    "And another choice for you.",
    "but wait! A third!"
  ];
}

/**
 * Dropdown controller.
 */
@NgController(selector: '[alert-ctrl]', publishAs: 'ctrl')
class AlertCtrl {
  
  List<AlertItem> alerts = [
    new AlertItem(type:'danger', msg:'Oh snap! Change a few things up and try submitting again.'),
    new AlertItem(type:'success', msg:'Well done! You successfully read this important alert message.')
  ];

  void addAlert() {
    alerts.add(new AlertItem(msg:"Another alert!"));
  }

  void closeAlert(index) {
    alerts.removeAt(index);
  }
}

class AlertItem {
  var type;
  var msg;
  
  AlertItem({String this.type:null, String this.msg:''});
}
