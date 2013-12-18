// Copyright (c) 2013, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

library angular.ui;

import 'dart:html';
import 'dart:async';
import "package:angular/angular.dart";

part 'transition.dart';

class AngularUI extends Module {
  AngularUI() {
    //factory(Transition, (_) => new Transition());
    type(Transition);
  }
}
