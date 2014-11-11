// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.alert;

import "package:angular/angular.dart";
import "package:angular/core_dom/module_internal.dart";

/**
 * Alert Module.
 */
class AlertModule extends Module {
  AlertModule() {
    bind(Alert);
  }
}

/**
 * Alert component.
 */
@Component(selector: 'alert', 
  useShadowDom: false,
//  templateUrl: 'packages/angular_ui/alert/alert.html'
  template: '''
<div class='alert' ng-class='alertTypeAsString'>
  <button type='button' class='close' data-dismiss='alert' ng-show='closeable' ng-click='close()'>&times;</button>
  <content/>
</div>'''
)
//@Component(selector: '[alert]', 
//  useShadowDom: false,
//  templateUrl: 'packages/angular_ui/alert/alert.html')
class Alert implements ScopeAware {
  @NgOneWay('type')
  String type;
  
  @NgCallback('close')
  var close;
  
  Scope scope;

  /**
   * Flag helps show or hide close button depends on availability of [close] 
   * attribute.
   */
  var _closeable = false;
  bool get closeable => _closeable;

  /**
   * Calculate and return alert type as string depnds on type. If type is null
   * methods returns 'warning' as default value.
   */
  String get alertTypeAsString => "alert-${type != null ? type : 'warning'}";
  
  Alert(NodeAttrs attr) {
    _closeable = attr.containsKey('close');
  }
}