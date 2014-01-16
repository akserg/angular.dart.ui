// Copyright (c) 2013 - 2014, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.alert;

import "package:angular/angular.dart";

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
@NgComponent(selector: 'alert', publishAs: 't', applyAuthorStyles: true, 
    templateUrl: 'packages/angular_ui/alert.html')
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
   * Thst method calls [close] callback
   */
  void closeHandler() {
    close();
  }
}