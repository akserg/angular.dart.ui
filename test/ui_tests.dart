// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

library angular.ui.test;

/**
 * Unit testing for Angular UI library.
 */

import 'dart:html' as dom;
import 'dart:async';

import 'package:unittest/html_enhanced_config.dart';
import '_specs.dart';
import 'package:angular/core_dom/module_internal.dart';

import 'package:angular_ui/utils/utils.dart';

import 'package:angular_ui/accordion/accordion.dart';
import 'package:angular_ui/alert/alert.dart';
import 'package:angular_ui/buttons/buttons.dart';
import 'package:angular_ui/collapse/collapse.dart';
import 'package:angular_ui/dragdrop/dragdrop.dart';
import 'package:angular_ui/dropdown/dropdown_toggle.dart';
import 'package:angular_ui/utils/position.dart';
import 'package:angular_ui/utils/timeout.dart';
import 'package:angular_ui/utils/transition.dart';
import 'package:angular_ui/progressbar/progressbar.dart';
import 'package:angular_ui/modal/modal.dart';
import 'package:angular_ui/datepicker/datepicker.dart';
import 'package:angular_ui/tabs/tabset.dart';
import 'package:angular_ui/timepicker/timepicker.dart';
import 'package:angular_ui/rating/rating.dart';
import 'package:angular_ui/carousel/carousel.dart';

part 'tests/accordion_tests.dart';
part 'tests/alert_tests.dart';
part 'tests/buttons_tests.dart';
part 'tests/collapse_tests.dart';
part 'tests/dragdrop_tests.dart';
part 'tests/dropdown_toggle_tests.dart';
part 'tests/position_tests.dart';
part 'tests/progressbar_tests.dart';
part 'tests/tabs_tests.dart';
part 'tests/timeout_tests.dart';
part 'tests/transition_tests.dart';
part 'tests/modal_tests.dart';
part 'tests/datepicker_tests.dart';
part 'tests/timepicker_tests.dart';
part 'tests/rating_tests.dart';
part 'tests/carousel_tests.dart';

void main() {
  useHtmlEnhancedConfiguration();
  group('All Tests:', () {
    group('Acoordion', () => accordionTests());
    group('Alert', () => alertTests());
    group('Buttons', () => buttonsTests());
    group('Collapse', () => collapseTests());
    group('Drag&Drop', () => dragdropTests());
    group('DropdownToggle', () => dropdownToggleTests());
    group('Position', () => positionTests());
    group('Progressbar', () => porgressbarTests());
    group('Tabs', () => tabsTests());
    group('Timeout', () => timeoutTests());
    group('Transition', () => transitionTests());
    group('Modal', () => modalTests());
    group('Rating', () => ratingTests());
    group('Datepicker', () => datepickerTests());
    group('Timepicker', () => timepickerTests());
    group('Carousel', () => carouselTests());
  });
}

/**
 * It adds an html template into the TemplateCache.
 */
void addToTemplateCache(TemplateCache cache, String path) {
  dom.HttpRequest request = new dom.HttpRequest();
  request.open("GET", path, async : false);
  request.send();
  cache.put(path, new HttpResponse(200, request.responseText));
}
