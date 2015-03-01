// Copyright (C) 2013 - 2015 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui;

import "package:angular/angular.dart";

import 'package:angular_ui/alert/alert.dart';
import 'package:angular_ui/accordion/accordion.dart';
import 'package:angular_ui/buttons/buttons.dart';
import 'package:angular_ui/carousel/carousel.dart';
import 'package:angular_ui/collapse/collapse.dart';
import 'package:angular_ui/dropdown/dropdown_toggle.dart';
import 'package:angular_ui/pagination/pagination.dart';
import 'package:angular_ui/progressbar/progressbar.dart';
import 'package:angular_ui/rating/rating.dart';
import 'package:angular_ui/tabs/tabset.dart';
import 'package:angular_ui/utils/content_append.dart';
import 'package:angular_ui/utils/timeout.dart';
import 'package:angular_ui/utils/transition.dart';
import 'package:angular_ui/modal/modal.dart';
import 'package:angular_ui/dragdrop/dragdrop.dart';
import 'package:angular_ui/datepicker/datepicker.dart';
import 'package:angular_ui/timepicker/timepicker.dart';
import 'package:angular_ui/tooltip/tooltip.dart';
import 'package:angular_ui/popover/popover.dart';
import 'package:angular_ui/typeahead/module.dart';
import 'package:angular_ui/utils/dbl_click_preventer.dart';

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
    install(new DragDropModule());
    install(new DropdownToggleModule());
    install(new PaginationModule());
    install(new ProgressbarModule());
    install(new RatingModule());
    install(new TabsModule());
    install(new TimeoutModule());
    install(new TransitionModule());
    install(new ModalModule());
    install(new DatepickerModule());
    install(new TimepickerModule());
    install(new TooltipModule());
    install(new PopoverModule());
    install(new TypeaheadModule());
    install(new ContentAppendModule());
    install(new DblClickPreventerModule());
  }
}

