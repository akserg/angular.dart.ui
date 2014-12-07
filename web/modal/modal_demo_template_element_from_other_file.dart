// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

/**
 * Modal controller with template from file for other.
 */
@Component(
  selector: 'modal-demo-other-tmpl', 
  useShadowDom: false,
  templateUrl: 'modal/modal_demo_template_element_from_other_file.html',
  exportExpressions: const ["open"]
)
class ModalDemoOtherTemplate implements ScopeAware {
  List<String> items = ["Hydrogen", "Lithium", "Oxygen", "Chromium"];
  
  String selected;
  String tmp;
  
  Modal modal;
  ModalInstance modalInstance;
  Scope _scope;
  NgModel ngModel;
  
  ModalDemoOtherTemplate(this.modal, this.ngModel) {
    print("!!! modal $modal");
    print("!!! ngModel $ngModel");
  }
  
  get scope => _scope;
  set scope(Scope value) {
    // Find ngModel in parent scope
    print("!!! Parent ngModel ${value.parentScope.context['ngModel']}");
    // Update local variables from outside
//    ngModel.render = (value) {
//      selected2 = value;
//    };
//    // Update model from inside
//    _scope.watch('selected', (newValue, _) {
//      ngModel.viewValue = newValue;
//    });
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
