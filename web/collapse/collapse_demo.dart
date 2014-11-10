// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

/**
 * Collapse controller.
 */
@Component(
    selector: 'collapse-demo',
    templateUrl: 'collapse/collapse_demo.html',
    useShadowDom: false)
class CollapseDemo implements ScopeAware {
  
  Scope scope;
  
  var isCollapsed = true;
}
