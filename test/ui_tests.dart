// Copyright (c) 2013 - 2014, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

library angular.ui.test;

/**
 * Unit testing for Angular UI library.
 */

import 'dart:html' as dom;
import 'dart:async';
import 'package:logging/logging.dart' as logging;
import 'package:logging_handlers/logging_handlers_shared.dart';

//
import 'package:unittest/html_enhanced_config.dart';
import '_specs.dart';
import 'package:angular/core_dom/module.dart';

import 'package:angular_ui/utils/utils.dart';

import 'package:angular_ui/alert.dart';
import 'package:angular_ui/buttons.dart';
import 'package:angular_ui/collapse.dart';
import 'package:angular_ui/dropdown_toggle.dart';
import 'package:angular_ui/position.dart';
import 'package:angular_ui/timeout.dart';
import 'package:angular_ui/transition.dart';
import 'package:angular_ui/progressbar/progressbar.dart';

part 'tests/alert_tests.dart';
part 'tests/buttons_tests.dart';
part 'tests/collapse_tests.dart';
part 'tests/dropdown_toggle_tests.dart';
part 'tests/position_tests.dart';
part 'tests/progressbar_tests.dart';
part 'tests/timeout_tests.dart';
part 'tests/transition_tests.dart';

final _log = new logging.Logger('test');

void main() {
  startQuickLogging();
  logging.Logger.root.level = logging.Level.FINEST;
  _log.fine('Running unit tests for Angular UI library.');

  useHtmlEnhancedConfiguration();
  group('All Tests:', () {
    test('Alert', () => alertTests());
    test('Buttons', () => buttonsTests());
    test('Collapse', () => collapseTests());
    test('DropdownToggle', () => dropdownToggleTests());
    test('Position', () => positionTests());
    test('Progressbar', () => porgressbarTests());
    test('Timeout', () => timeoutTests());
    test('Transition', () => transitionTests());
  });
}
