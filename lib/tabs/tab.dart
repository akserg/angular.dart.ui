// Copyright (C) 2013 - 2015 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.tabs;

@Component(
    selector: 'tab',
//    templateUrl: 'packages/angular_ui/tabs/tab.html',
    template: '''
<div ng-if="active" class="tab-pane" ng-class="{'active': active}">
  <content></content>
</div>''',
    useShadowDom: false
)
class TabComponent implements DetachAware, ScopeAware {
  
  Scope scope;
  
  final TabsetComponent tabset; 
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
  
  TabComponent(this.element, this.tabset) {
    _log.fine('TabComponent');
    this.tabset.addTab(this);
  }

  @NgTwoWay('active') 
  get active => _active;
  set active(var newValue) {
    _active = newValue;
    if (newValue != null && newValue == true) {
      tabset.select(this);
    }
  }
  
  set select(bool newValue) {
    if (newValue && !_active && onSelectCallback != null) {
      onSelectCallback();
    } else if(!newValue && _active && onDeselectCallback!=null) {
      onDeselectCallback();
    }
    _active = newValue;
    _refreshTabHeading();
  }

  // Work around for dynamic tab heading issue.  It seems to have something to do with the digest cycle
  // on tab and the ng-if adding the element back to dom.
  void _refreshTabHeading() {
    if(this._active && this.heading is Node) {
      var clone = this.heading.clone(true);
      (this.heading as Node).nodes.clear();
      this.heading = clone;
    }
  }

  @override
  void detach() {
    this.tabset.removeTab(this);
  }
}

