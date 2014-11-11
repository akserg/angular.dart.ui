// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

/**
 * Dropdown demo component.
 */
@Component(
    selector: 'dropdown-demo', 
    templateUrl: 'dropdown_toggle/dropdown_toggle_demo.html',
    useShadowDom: false)
class DropdownDemo implements ScopeAware {
  
  Scope scope;
  
  var items = [
    "The first choice!",
    "And another choice for you.",
    "but wait! A third!"
  ];
}