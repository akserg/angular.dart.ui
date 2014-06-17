// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

/**
 * Modal controller with template.
 */
@Controller(selector: '[modal-ctrl-tmpl]', publishAs: 'ctrl')
class ModalCtrlTemplate {
  List<String> items = ["1111", "2222", "3333", "4444"];
  String selected;
  String tmp;
  
  Modal modal;
  ModalInstance modalInstance;
  Scope scope;
  
  String template = """
<div class="modal-header">
  <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
  <h4 class="modal-title">I'm a modal!</h4>
</div>
<div class="modal-body">
  <ul>
    <li ng-repeat="item in ctrl.items">
      <a ng-click="ctrl.tmp = item">{{ item }}</a>
    </li>
  </ul>
  Selected: <b>{{ctrl.tmp}}</b>
</div>
<div class="modal-footer">
  <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
  <button type="button" class="btn btn-primary" ng-click="ctrl.ok(ctrl.tmp)">OK</button>
</div>
""";
  
  ModalCtrlTemplate(this.modal, this.scope);
  
  void open() {
    modalInstance = modal.open(new ModalOptions(template:template), scope);
    
    modalInstance.opened
      ..then((v) {
        print('Opened');
      }, onError: (e) {
        print('Open error is $e');
      });
    
    // Override close to add you own functionality 
    modalInstance.close = (result) { 
      selected = result;
      print('Closed with selection $selected');
      modal.hide();
    };
    // Override dismiss to add you own functionality 
    modalInstance.dismiss = (String reason) { 
      print('Dismissed with $reason');
      modal.hide();
   };
  }
  
  void ok(sel) {
    modalInstance.close(sel);
  }
}

/**
 * Modal controller with template from file.
 */
@Controller(selector: '[modal-ctrl-tag-tmpl]', publishAs: 'ctrl')
class ModalCtrlTagTemplate {
  List<String> items = ["Java", "Dart", "JavaScript", "Ruby"];
  
  String selected;
  String tmp;
  String other;
  
  Modal modal;
  ModalInstance modalInstance;
  Scope scope;
  
  ModalCtrlTagTemplate(this.modal, this.scope);
  
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

/**
 * Modal controller with template from file.
 */
@Controller(selector: '[modal-ctrl-file-tmpl]', publishAs: 'ctrl')
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
