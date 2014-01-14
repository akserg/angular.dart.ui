// Copyright (c) 2013, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

library angular.ui.test;

/**
 * Unit testing for Angular UI library.
 */

import 'dart:html' as dom;
//
import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';

import 'package:di/di.dart';
import 'package:angular/angular.dart';
import 'package:angular/mock/module.dart';

import 'package:angular_ui/position.dart';
import 'package:angular_ui/buttons.dart';

part 'tests/position_tests.dart';
part 'tests/buttons_tests.dart';

void main() {
  print('Running unit tests for Angular UI library.');
  useHtmlEnhancedConfiguration();
  group('All Tests:', () {
    test('Position', () => positionTests());
    test('Buttons', () => buttonsTests());
  });
}