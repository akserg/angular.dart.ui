// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

@Decorator(
    selector: '[tooltip-demo-controller]')
class TooltipDemoCtrl {
  var dynamicTooltip = 'Hello, World!';
  var dynamicTooltipText = 'dynamic';
  var htmlTooltip = 'I\'ve been made <b>bold</b>!';
}