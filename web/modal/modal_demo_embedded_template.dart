// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

/**
 * Modal controller with template.
 */
@Controller(selector: '[modal-ctrl-tmpl]', 
    publishAs: 'ctrl',
    exportExpressions: const ["tmp", "ok"])
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
  
  ModalInstance getModalInstance() {
    return modal.open(new ModalOptions(template:template), scope);
  }
  
  void open() {
    modalInstance = getModalInstance();
    
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