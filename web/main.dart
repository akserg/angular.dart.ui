// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.demo;

import 'dart:html' as dom;
import 'dart:math' as math;
import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'package:angular_ui/angular_ui.dart';
import 'package:angular_ui/typeahead/module.dart';

@MirrorsUsed(targets: const[
//  'angular',
//  'angular.core',
//  'angular.core.dom',
//  'angular.filter',
//  'angular.perf',
//  'angular.directive',
//  'angular.routing',
//  'angular.core.parser',
//  dom.NodeTreeSanitizer,
  'angular.ui',
  'angular.ui.demo'
],
  override: '*')
import 'dart:mirrors';
import 'package:angular_ui/dragdrop/dragdrop.dart';

part 'accordion/accordion_demo.dart';
part 'alert/alert_demo.dart';
part 'buttons/buttons_demo.dart';
part 'carousel/carousel_demo.dart';
part 'collapse/collapse_demo.dart';
part 'dragdrop/dragdrop_demo.dart';
part 'datepicker/datepicker_demo.dart';
part 'dropdown_toggle/dropdown_toggle_demo.dart';
part 'modal/modal_demo.dart';
part 'pagination/pagination_demo.dart';
part 'progressbar/progressbar_demo.dart';
part 'tabs/tabs_demo.dart';
part 'timepicker/timepicker_demo.dart';
part 'rating/rating_demo.dart';
part 'tooltip/tooltip_demo.dart';
part 'popover/popover_demo.dart';
part 'typeahead/typeahead_demo.dart';

/**
 * Entry point into app.
 */
main() {
  applicationFactory()
    .addModule(new DemoModule())
    .run();
}

/**
 * Demo Module
 */
class DemoModule extends Module {
  DemoModule() {
    install(new AngularUIModule());
    //
    type(PopoverDemoCtrl);
    type(TooltipDemoCtrl);
    type(TimepickerDemoCtrl);
    type(DatepickerCtrl);
    type(ModalCtrlTemplate);
    type(ModalCtrlTagTemplate);
    type(ModalCtrlFileTemplate);
    type(ModalCtrlOtherTemplate);
    type(AlertCtrl);
    type(CollapseCtrl);
    type(DropdownCtrl);
    type(PaginationController);
    type(ProgressCtrl);
    type(ButtonsCtrl);
    type(CarouselDemoController);
    type(TabsCtrl);
    type(AccordionDemoController);
    type(RatingCtrl);
    type(DragDropShoppingBasketDemoController);
    type(DragDropListDemoController);
    type(DragDropCustomImageDemoController);
    type(DragDropHandlerDemoController);
    type(TypeaheadDemoController);
  }
}