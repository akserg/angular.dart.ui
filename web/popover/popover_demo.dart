// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

@Component(
    selector: 'popover-demo',
    useShadowDom: false,
    templateUrl: 'popover/popover_demo.html',
    exportExpressions: const ["dynamicPopover","dynamicPopoverTitle"])
class PopoverDemo implements ScopeAware {
  Scope scope;
  var dynamicPopover = 'Hello, World!';
  var dynamicPopoverTitle = 'Title';
}