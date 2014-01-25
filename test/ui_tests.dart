// Copyright (c) 2013 - 2014, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

library angular.ui.test;

/**
 * Unit testing for Angular UI library.
 */

import 'dart:html' as dom;
import 'dart:async';
//
import 'package:unittest/html_enhanced_config.dart';
import '_specs.dart';
import 'package:angular/core_dom/module.dart';

import 'package:angular_ui/position.dart';
import 'package:angular_ui/transition.dart';
import 'package:angular_ui/buttons.dart';
import 'package:angular_ui/collapse.dart';
import 'package:angular_ui/dropdown_toggle.dart';
import 'package:angular_ui/alert.dart';
import 'package:angular_ui/timeout.dart';
import 'package:angular_ui/progressbar/progressbar.dart';
import 'package:angular_ui/utils/utils.dart';

part 'tests/position_tests.dart';
part 'tests/transition_tests.dart';
part 'tests/buttons_tests.dart';
part 'tests/collapse_tests.dart';
part 'tests/dropdown_toggle_tests.dart';
part 'tests/alert_tests.dart';
part 'tests/timeout_tests.dart';
part 'tests/progressbar_tests.dart';

void main() {
  print('Running unit tests for Angular UI library.');
  useHtmlEnhancedConfiguration();
  group('All Tests:', () {
    test('Position', () => positionTests());
    test('Timeout', () => timeoutTests());
    test('Transition', () => transitionTests());
    test('Buttons', () => buttonsTests());
    test('DropdownToggle', () => dropdownToggleTests());
    test('Collapse', () => collapseTests());
    test('Alert', () => alertTests());
    test('Progressbar', () => porgressbarTests());
  });
}