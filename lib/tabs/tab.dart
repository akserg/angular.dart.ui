// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.tabs;

@Component(
    selector: 'tab',
    visibility: Directive.CHILDREN_VISIBILITY,
    templateUrl: 'packages/angular_ui/tabs/tab.html',
    publishAs: 'tabCtrl',
    useShadowDom: false
)
class TabComponent implements DetachAware {
  
  final TabsetComponent tabsetCtrl; 
  final Element element;
  
  //Called in contentHeadingTransclude once it inserts the tab's content into the dom
  @NgCallback('select')
  var onSelectCallback;
  
  @NgCallback('deselect')
  var onDeselectCallback;
  
  bool _active = false;

  @NgAttr('heading')
  var heading;
  
  @NgTwoWay('disabled')
  bool disabled = false;
  
  TabComponent(this.element, this.tabsetCtrl, Scope scope) {
    _log.fine('TabComponent');
    this.tabsetCtrl.addTab(this);
  }

  @NgTwoWay('active') get active => _active;
  set active(var newValue) {
    if (newValue!=null && newValue==true) {
      tabsetCtrl.select(this);
    }
  }
  
  set select(bool newValue) {
    if (newValue) {
      if(onSelectCallback!=null) {
        onSelectCallback();
      }
    } else {
      if(_active && onDeselectCallback!=null) {
        onDeselectCallback();
      }
    }
    _active = newValue;
  }

  @override
  void detach() {
    this.tabsetCtrl.removeTab(this);
  }
}

