// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.tabs;

import 'package:angular/angular.dart';
import 'dart:html';
import 'package:logging/logging.dart';
import 'package:angular_ui/utils/content_append.dart';

part 'tab.dart';
part 'tab_heading.dart';

final _log = new Logger('angular.ui.tabs');

class TabsModule extends Module {
  TabsModule() {
    install(new ContentAppendModule());
    bind(TabsetComponent);
    bind(TabComponent);
    bind(TabHeading);
  }
}

@Component(
    selector: 'tabset',
//    templateUrl: 'packages/angular_ui/tabs/tabset.html',
    template: '''
<div class="tabbable">
  <ul class="nav nav-{{type}}" ng-class="{'nav-stacked': vertical, 'nav-justified': justified}">
    <li ng-repeat="tab in tabs" ng-class="{active: tab.active, disabled: tab.disabled}">
      <a ng-click="select(tab)"><content-append node="tab.heading"></content-append></a>
    </li>
  </ul>
  <div class="tab-content">
    <content></content>
  </div>
</div>''',
    useShadowDom: false
)
class TabsetComponent implements ScopeAware {
  
  Scope scope;
  
  @NgOneWay('justified')
  bool justified = false;
  
  @NgOneWay('vertical')
  bool vertical = false;
  
  @NgOneWay('type')
  String type = "tabs";
  
  List<TabComponent> tabs = [];
  
  void select(TabComponent tab) {
    if (!tab.disabled) {
      tabs.forEach((tab) {
        tab.select = false;
      });
      tab.select = true;
    }
  }

  void addTab(TabComponent tab) {
    tabs.add(tab);
    if (tabs.length == 1 || tab.active) {
      select(tab);
    }
  }

  void removeTab(TabComponent tab) {
    int index = tabs.indexOf(tab);
    //Select a new tab if the tab to be removed is selected
    if (tab.active && tabs.length > 1) {
      //If this is the last tab, select the previous tab. else, the next tab.
      int newActiveIndex = index == tabs.length - 1 ? index - 1 : index + 1;
      select(tabs[newActiveIndex]);
    }
    tabs.remove(tab);
  }
  
}
