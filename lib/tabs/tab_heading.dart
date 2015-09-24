// Copyright (C) 2013 - 2015 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.tabs;

@Decorator(selector: 'tab-heading')
class TabHeading {
  TabHeading(Element elem, TabComponent tab) {
    var clone = elem.clone(true);
    elem.nodes.clear();
    tab.heading = clone;
  }
}
