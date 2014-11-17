// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

/**
 * Modal controller with template from template element.
 */
@Component(
  selector: 'modal-demo-tag-tmpl', 
  useShadowDom: false,
  templateUrl: 'modal/modal_demo_template_element.html',
  exportExpressions: const ["open"]
)
class ModalDemoTagTemplate implements ScopeAware {
  List<String> items = ["Java", "Dart", "JavaScript", "Ruby"];
  
  String selected;
  String tmp;
  String other;
  
  Modal modal;
  ModalInstance modalInstance;
  Scope scope;
  
  ModalDemoTagTemplate(this.modal);
  
  void openUrl(String templateUrl) {
    modalInstance = modal.open(new ModalOptions(templateUrl:templateUrl), scope);
    
    modalInstance.result
      ..then((value) {
        selected = value;
        print('Closed with selection $value');
      }, onError:(e) {
        print('Dismissed with $e');
      });
  }
  
  void ok(sel) {
    modalInstance.close(sel);
  }
}
