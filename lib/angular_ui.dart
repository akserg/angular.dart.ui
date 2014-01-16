// Copyright (c) 2013 - 2014, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui;

import "package:angular/angular.dart";

import 'package:angular_ui/buttons.dart';
import 'package:angular_ui/collapse.dart';
import 'package:angular_ui/dropdown_toggle.dart';
import 'package:angular_ui/alert.dart';

/**
 * AngularUI Module
 */
class AngularUIModule extends Module {
  AngularUIModule() {
    install(new ButtonModule());
    install(new CollapseModule());
    install(new DropdownToggleModule());
    install(new AlertModule());
  }
}

