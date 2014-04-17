// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.alert;

import "package:angular/angular.dart";
import "package:angular/core/parser/syntax.dart";

/**
 * Alert Module.
 */
class AlertModule extends Module {
  AlertModule() {
    type(Alert);
  }
}

/**
 * Alert component.
 */
@Component(selector: 'alert', publishAs: 't', applyAuthorStyles: true, 
    templateUrl: 'packages/angular_ui/alert/alert.html')
@Component(selector: '[alert]', publishAs: 't', applyAuthorStyles: true, 
    templateUrl: 'packages/angular_ui/alert/alert.html')
class Alert {
  @NgOneWay('type')
  String type;
  
  @NgCallback('close')
  var close;

  /**
   * Flag helps show or hide close button depends on availability of [close] 
   * attribute.
   */
  bool get showable => (close as BoundExpression).expression.isChain;
  
  /**
   * Calculate and return alert type as string depnds on type. If type is null
   * methods returns 'warning' as default value.
   */
  String get alertTypeAsString => "alert-${type != null ? type : 'warning'}";
  
  /**
   * Thst method calls [close] callback
   */
  void closeHandler() {
    close();
  }
}