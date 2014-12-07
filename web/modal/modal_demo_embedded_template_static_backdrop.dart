// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

/**
 * Modal controller with template and static backdrop.
 */
@Component(
    selector: 'modal-demo-embedded-tmpl-static-backdrop', 
    useShadowDom: false,
    templateUrl: 'modal/modal_demo_embedded_template_static_backdrop.html',
    exportExpressions: const ["tmp", "ok"])
class ModalDemoEmbeddedTemplateWithStaticBackdrop implements ScopeAware {
  List<String> items = ["First", "Second", "Third", "Fourth"];
  String selected;
  String tmp;
  
  Modal modal;
  ModalInstance modalInstance;
  Scope scope;
  
  String template = """
<div class="modal-header">
  <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
  <h4 class="modal-title">I'm a modal with a <b>static</b> backdrop!</h4>
</div>
<div class="modal-body">
  <ul>
    <li ng-repeat="item in items">
      <a ng-click="tmp = item">{{ item }}</a>
    </li>
  </ul>
  Selected: <b>{{tmp}}</b>
</div>
<div class="modal-footer">
  <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
  <button type="button" class="btn btn-primary" ng-click="ok(tmp)">OK</button>
</div>
""";
  
ModalDemoEmbeddedTemplateWithStaticBackdrop(this.modal);
  
  ModalInstance getModalInstance() {
    return modal.open(new ModalOptions(template:template, backdrop: 'static'), scope);
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
