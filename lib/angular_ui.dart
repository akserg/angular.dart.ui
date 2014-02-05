// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui;

import "package:angular/angular.dart";

import 'package:angular_ui/alert.dart';
import 'package:angular_ui/accordion/accordion.dart';
import 'package:angular_ui/buttons.dart';
import 'package:angular_ui/carousel.dart';
import 'package:angular_ui/collapse.dart';
import 'package:angular_ui/dropdown_toggle.dart';
import 'package:angular_ui/progressbar/progressbar.dart';
import 'package:angular_ui/rating/rating.dart';
import 'package:angular_ui/timeout.dart';
import 'package:angular_ui/transition.dart';
import 'package:angular_ui/modal/modal.dart';
import 'package:angular_ui/utils/compile.dart';

export 'package:angular_ui/modal/modal.dart';

/**
 * AngularUI Module
 */
class AngularUIModule extends Module {
  AngularUIModule() {
    install(new AlertModule());
    install(new AccordionModule());
    install(new ButtonModule());
    install(new CarouselModule());
    install(new CollapseModule());
    install(new DropdownToggleModule());
    install(new ProgressbarModule());
    install(new RatingModule());
    install(new TimeoutModule());
    install(new TransitionModule());
    install(new ModalModule());
    install(new CompileModule());
  }
}

