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

@NgComponent(
    selector: 'tabset',
    visibility: NgDirective.CHILDREN_VISIBILITY,
    templateUrl: 'packages/angular_ui/tabs/tabset.html',
    publishAs: 'tabsetCtrl',
    applyAuthorStyles: true
)
class TabsetComponent {
  
  @NgOneWay('justified')
  bool justified = false;
  @NgOneWay('vertical')
  bool vertical = false;
  @NgOneWay('type')
  String type = "tabs";
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
