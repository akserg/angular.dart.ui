// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.tabs;

import 'package:angular/angular.dart';
import 'dart:html';
import 'package:logging/logging.dart';

part 'tab.dart';
part 'tab_heading.dart';

final _log = new Logger('angular.ui.accordion');

class TabsModule extends Module {
  TabsModule() {
    type(TabsetComponent);
    type(TabComponent);
    type(TabHeadingTranscludeComponent);
  }
}

//TODO add selector [tabset]
//TODO move html to external file
@NgComponent(
    selector: 'tabset',
    visibility: NgDirective.CHILDREN_VISIBILITY,
    template:
'''
<div class="tabbable">
  <ul class="nav nav-tabs" ng-class="{'nav-stacked': tabsetCtrl.vertical, 'nav-justified': tabsetCtrl.justified}">
    <li ng-repeat="tab in tabsetCtrl.tabs" ng-class="{active: tab.active, disabled: tab.disabled}">
      <a ng-click="tabsetCtrl.select(tab)"><tab-heading-transclude tab="tab"></tab-heading-transclude></a>
    </li>
  </ul>
  <div class="tab-content">
    <content></content>
  </div>
</div>
''',
    publishAs: 'tabsetCtrl',
    applyAuthorStyles: true
)
class TabsetComponent {
  
  @NgOneWay('justified')
  bool justified = false;
  @NgOneWay('vertical')
  bool vertical = false;
  List<TabComponent> tabs = [];
  
  TabsetComponent() {
    _log.fine('TabsetComponent');
  }
  
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
