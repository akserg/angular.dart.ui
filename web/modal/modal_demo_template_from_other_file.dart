// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

/**
 * Modal controller with template from file for other.
 */
@Controller(selector: '[modal-ctrl-other-tmpl]', publishAs: 'ctrl2')
class ModalCtrlOtherTemplate {
  List<String> items = ["Hydrogen", "Lithium", "Oxygen", "Chromium"];
  
  String selected;
  String tmp;
  
  Modal modal;
  ModalInstance modalInstance;
  Scope scope;
  NgModel ngModel;
  
  ModalCtrlOtherTemplate(this.modal, this.scope, this.ngModel) {
    // Update local variables from outside
    ngModel.render = (value) {
      selected = value;
    };
    // Update model from inside
    scope.watch('ctrl2.selected', (newValue, _) {
      ngModel.viewValue = newValue;
    });
  }
  
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
