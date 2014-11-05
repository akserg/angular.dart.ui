// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

/**
 * Alert component.
 */
@Component(
  selector: 'alert-demo',
  templateUrl: "alert/alert_demo.html",
  useShadowDom: false)
class AlertDemo implements ScopeAware {
  
  Scope scope;
  
  List<AlertItem> alerts = [
    new AlertItem(type:'danger', msg:'Oh snap! Change a few things up and try submitting again.'),
    new AlertItem(type:'success', msg:'Well done! You successfully read this important alert message.')
  ];

  void addAlert() {
    alerts.add(new AlertItem(msg:"Another alert!"));
  }

  void closeAlert(index) {
    alerts.removeAt(index);
  }
}

@Injectable()
class AlertItem {
  var type;
  var msg;
  
  AlertItem({String this.type:null, String this.msg:''});
}