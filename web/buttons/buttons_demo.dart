// Copyright (C) 2013 - 2016 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

/**
 * Buttons demo component.
 */
@Component(selector: 'buttons-demo', 
    templateUrl: 'buttons/buttons_demo.html',
    useShadowDom: false)
class ButtonsDemo implements ScopeAware {
  
  Scope scope;
  
  var singleModel = 1;
  
  var radioModel = 'Right';
  
  var leftModel = false;
  
  var middleModel = true;
  
  var rightModel = false;
}