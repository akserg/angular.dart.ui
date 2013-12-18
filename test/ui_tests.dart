// Copyright (c) 2013, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/monomer
// All rights reserved.  Please see the LICENSE.md file.

library angular.ui.test;

/**
 * Unit testing for Monomer library.
 */

import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';

import 'package:di/di.dart';
import 'package:angular/angular.dart';
import 'package:angular/mock/module.dart';

import 'package:angular_ui/angular_ui.dart';

part 'tests/transition_tests.dart';

void main() {
  print('Running unit tests for Angular UI library.');
  useHtmlEnhancedConfiguration();
  group('All Tests:', () {
    test('Transition', () => transitionTests());
  });
}