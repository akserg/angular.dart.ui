// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

/**
 * Modal controller with template from file.
 */
@Controller(selector: '[modal-ctrl-file-tmpl]', 
    publishAs: 'ctrl1',
    exportExpressions: const ["open"])
class ModalCtrlFileTemplate {
  List<String> items = ["Sun", "Moon", "Star", "Planet"];
  
  String selected;
  String tmp;
  
  Modal modal;
  ModalInstance modalInstance;
  Scope scope;
  
  ModalCtrlFileTemplate(this.modal, this.scope);
  
  void open(String templateUrl) {
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

