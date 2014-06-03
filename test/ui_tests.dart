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

import 'package:angular_ui/angular_ui.dart';

import 'package:angular_ui/accordion/accordion.dart';
import 'package:angular_ui/alert/alert.dart';
import 'package:angular_ui/buttons/buttons.dart';
import 'package:angular_ui/collapse/collapse.dart';
import 'package:angular_ui/dragdrop/dragdrop.dart';
import 'package:angular_ui/dropdown/dropdown_toggle.dart';
import 'package:angular_ui/pagination/pagination.dart';
import 'package:angular_ui/utils/position.dart';
import 'package:angular_ui/utils/timeout.dart';
import 'package:angular_ui/utils/transition.dart';
import 'package:angular_ui/utils/content_append.dart';
import 'package:angular_ui/progressbar/progressbar.dart';
import 'package:angular_ui/modal/modal.dart';
import 'package:angular_ui/datepicker/datepicker.dart';
import 'package:angular_ui/tabs/tabset.dart';
import 'package:angular_ui/timepicker/timepicker.dart';
import 'package:angular_ui/rating/rating.dart';
import 'package:angular_ui/carousel/carousel.dart';
import 'package:angular_ui/tooltip/tooltip.dart';
import 'package:angular_ui/popover/popover.dart';
import 'tests/typeahead/module.dart';

part 'tests/accordion_tests.dart';
part 'tests/alert_tests.dart';
part 'tests/buttons_tests.dart';
part 'tests/collapse_tests.dart';
part 'tests/dragdrop_tests.dart';
part 'tests/dragdrop_sortable_tests.dart';
part 'tests/dropdown_toggle_tests.dart';
part 'tests/pagination_test.dart';
part 'tests/utils/position_tests.dart';
part 'tests/progressbar_tests.dart';
part 'tests/tabs_tests.dart';
part 'tests/utils/timeout_tests.dart';
part 'tests/utils/transition_tests.dart';
part 'tests/modal_tests.dart';
part 'tests/datepicker_tests.dart';
part 'tests/timepicker_tests.dart';
part 'tests/rating_tests.dart';
part 'tests/carousel_tests.dart';
part 'tests/tooltip_tests.dart';
part 'tests/popover_tests.dart';
part 'tests/utils/content_append_tests.dart';

void main() {
  useHtmlEnhancedConfiguration();
  group('All Tests:', () {
    group('Typeahead', () => typeaheadTests());
    group('Acoordion', () => accordionTests());
    group('Alert', () => alertTests());
    group('Buttons', () => buttonsTests());
    group('Collapse', () => collapseTests());
    group('Drag&Drop -', () => dragdropTests());
    group('Drag&Drop-Sortable -', () => dragdropSortableTests());
    group('DropdownToggle', () => dropdownToggleTests());
    group('Pager', () => pagerTests());
    group('Pagination', () => paginationTests());
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
    group('Tooltip', () => tooltipTests());
    group('Popover', () => popoverTests());
    group('ContentAppend', () => contentAppendTests());
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
