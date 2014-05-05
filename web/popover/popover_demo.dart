// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

@Controller(
    selector: '[popover-demo-controller]',
    publishAs: 'p')
class PopoverDemoCtrl {
  var dynamicPopover = 'Hello, World!';
  var dynamicPopoverTitle = 'Title';
}