// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.tabs;

@Component(
    selector: 'tab-heading-transclude',
    applyAuthorStyles: true
)
class TabHeadingTranscludeComponent implements ShadowRootAware {
  
  @NgOneWay('tab')
  TabComponent tab;

  TabHeadingTranscludeComponent() {
    _log.fine('TabsetComponent');
  }
  
  void onShadowRoot(ShadowRoot shadowRoot) {
    Element tabHeading = tab.element.querySelector('tab-heading');
    if (tabHeading!=null) {
      shadowRoot.append(tabHeading);
    } else {
      shadowRoot.appendText(tab.heading);
    }
  }
}