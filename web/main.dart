// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.demo;

import 'dart:html' as dom;
import 'dart:math' as math;
import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'package:angular_ui/angular_ui.dart';
import 'package:angular_ui/utils/utils.dart';
import 'package:logging/logging.dart';

@MirrorsUsed(targets: const[
  'angular.ui',
  'angular.ui.demo'
], override: '*')
import 'dart:mirrors';
import 'package:angular_ui/dragdrop/dragdrop.dart';

part 'accordion/accordion_demo.dart';
part 'alert/alert_demo.dart';
part 'buttons/buttons_demo.dart';
part 'carousel/carousel_demo.dart';
part 'collapse/collapse_demo.dart';
part 'dragdrop/dragdrop_demo.dart';
part 'dragdrop/sortable_demo.dart';
part 'datepicker/datepicker_demo.dart';
part 'dropdown_toggle/dropdown_toggle_demo.dart';
part 'modal/modal_demo_embedded_template.dart';
part 'modal/modal_demo_embedded_template_static_backdrop.dart';
part 'modal/modal_demo_template_element.dart';
part 'modal/modal_demo_template_element_from_other_file.dart';
//part 'modal/modal_demo_template_from_file.dart';
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

  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen((LogRecord r) {
    DateTime now = new DateTime.now();
    dom.window.console.log('${now} [${r.level}] ${r.loggerName}: ${r.message}');
  });
  new Logger("angular.ui")..level = Level.FINER;

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
    bind(PopoverDemo);
    bind(TooltipDemo);
    bind(TimepickerDemo);
    bind(DatepickerDemo);
    bind(ModalDemoEmbeddedTemplate);
    bind(ModalDemoEmbeddedTemplateWithStaticBackdrop);
    bind(ModalDemoTagTemplate);
    bind(ModalDemoOtherTemplate);
//    bind(ModalDemoFileTemplate);
    bind(AlertDemo);
    bind(CollapseDemo);
    bind(DropdownDemo);
    bind(PaginationDemo);
    bind(ProgressDemo);
    bind(ButtonsDemo);
    bind(CarouselDemo);
    bind(TabsDemo);
    bind(AccordionDemo);
    bind(RatingDemo);
    bind(DragDropShoppingBasketDemoController);
    bind(DragDropListDemoController);
    bind(DragDropCustomImageDemoController);
    bind(DragDropMultiDropZonesDemoController);
    bind(SortableController);
    bind(SortableMultiController);
    bind(TypeaheadDemo);
  }
}