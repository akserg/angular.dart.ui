// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

@Component(
    selector: 'tabs-demo',
    templateUrl: 'tabs/tabs_demo.html',
    useShadowDom: false)
class TabsDemo implements ScopeAware {
  Scope scope;
  
  List tabs = [
     { 'title':'Dynamic Title 1', 'content':'Dynamic content 1', 'active':false, 'disabled': false },
     { 'title':'Dynamic Title 2', 'content':'Dynamic content 2', 'active':false, 'disabled': true }
  ];
  
  void alertMe() {
    dom.window.alert('You\'ve selected the alert tab!');
  }
}
