// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

@Component(
    selector: 'accordion-demo',
    templateUrl: 'accordion/accordion_demo.html',
    exportExpressions: const ["oneAtATime", "groups", "addItem", "items", "isOpen"],
    useShadowDom: false)
class AccordionDemo implements ScopeAware {
  
  Scope scope;
  
  bool oneAtATime = true;
  bool isOpen = false;
  List groups = [
    {
      'title': "Dynamic Group Header - 1",
      'content': "Dynamic Group Body - 1"
    },
    {
      'title': "Dynamic Group Header - 2",
      'content': "Dynamic Group Body - 2"
    }
  ];
  List items = ['Item 1', 'Item 2', 'Item 3'];

  void addItem() {
    int newItemNo = items.length + 1;
    items.add('Item ' + newItemNo.toString());
  }
  
}