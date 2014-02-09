// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.demo;

import 'dart:html' as dom;
import 'dart:math' as math;
import 'package:angular/angular.dart';
import 'package:angular_ui/angular_ui.dart';

/**
 * Entry point into app.
 */
main() {
  ngBootstrap(module: new DemoModule());
}

/**
 * Demo Module
 */
class DemoModule extends Module {
  DemoModule() {
    install(new AngularUIModule());
    //
    type(ButtonsCtrl);
    type(CollapseCtrl);
    type(DropdownCtrl);
    type(AlertCtrl);
    type(ProgressCtrl);
    type(CarouselDemoController);
    type(ModalCtrl);
    type(ModalCtrlTemplate);
    type(ModalCtrlTagTemplate);
    type(ModalCtrlFileTemplate);
  }
}

/**
 * Buttons controller.
 */
@NgController(selector: '[buttons-ctrl]', publishAs: 'ctrl')
class ButtonsCtrl {
  
  var singleModel = 1;
  
  var radioModel = 'Right';
  
  var leftModel = false;
  
  var middleModel = true;
  
  var rightModel = false;
}

/**
 * Collapse controller.
 */
@NgController(selector: '[collapse-ctrl]', publishAs: 'ctrl')
class CollapseCtrl {
  
  var isCollapsed = true;
}

/**
 * Dropdown controller.
 */
@NgController(selector: '[dropdown-ctrl]', publishAs: 'ctrl')
class DropdownCtrl {
  
  var items = [
    "The first choice!",
    "And another choice for you.",
    "but wait! A third!"
  ];
}

/**
 * Dropdown controller.
 */
@NgController(selector: '[alert-ctrl]', publishAs: 'ctrl')
class AlertCtrl {
  
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

class AlertItem {
  var type;
  var msg;
  
  AlertItem({String this.type:null, String this.msg:''});
}

@NgController(selector: '[progress-ctrl]', publishAs: 'ctrl')
class ProgressCtrl {

  math.Random _random = new math.Random();

  int max = 200;
  String type;
  int value = 0;
  int dynamic;

  var stacked = [];
  var showWarning;

  void random() {
    value = ((_random.nextDouble() * 100).floor() + 1);
    dynamic = value;

    if (value < 25) {
      type = 'success';
    } else if (value < 50) {
      type = 'info';
    } else if (value < 75) {
      type = 'warning';
    } else {
      type = 'danger';
    }

    showWarning = (type == 'danger' || type == 'warning');
  }

  void randomStacked() {
    stacked = [];
    var types = ['success', 'info', 'warning', 'danger'];

    for (var i = 0, n = ((_random.nextDouble() * 4).floor() + 1); i < n; i++) {
      var index = ((_random.nextDouble() * 4)).floor();
      stacked.add({
          'value': ((_random.nextDouble() * 30) + 1).floor(), 'type': types[index]
      });
    }
  }

  ProgressCtrl() {
    randomStacked();
    random();
  }
}

@NgController(
    selector: '[ng-controller=carousel-demo-ctrl]',
    publishAs: 'ctrl')
class CarouselDemoController {

  // workaround until number conversion is supported by Angular
  String _myInterval = '5000';
  String get myIntervalAsString => _myInterval;
  set myIntervalAsString(String newVal) {
    _myInterval = newVal;
    try {
      myInterval = int.parse(newVal);
    } catch(e){}
  }
  // workaround end

  int myInterval = 5000;
  List<Map<String,dynamic>> slides = [];

  CarouselDemoController() {

    for (int i = 0; i < 4; i++) {
      addSlide();
    }
  }

  void addSlide() {
    int newWidth = 600 + slides.length;
    slides.add({
      'image': 'http://placekitten.com/${newWidth}/300',
      'text': ['More','Extra','Lots of','Surplus'][slides.length % 4] + ' ' +
        ['Cats', 'Kittys', 'Felines', 'Cutes'][slides.length % 4]
    });
  }
}

/**
 * Modal controller.
 */
@NgController(selector: '[modal-ctrl]', publishAs: 'ctrl')
class ModalCtrl {
  List<String> items = ["One", "Two", "Three", "Four"];
  
  String selected;
  String tmp;
  
  Modal modal;
  ModalInstance modalInstance;
  
  ModalCtrl(this.modal);
  
  void open(id) {
    modalInstance = modal.show(dom.querySelector(id));
    modalInstance.result.then((value) {
        selected = value;
      }, onError: (reson) {
        print('Dismiss $reson');
      });
  }
  
  void ok(sel) {
    modalInstance.close(sel);
  }
}

/**
 * Modal controller with template.
 */
@NgController(selector: '[modal-ctrl-tmpl]', publishAs: 'ctrl')
class ModalCtrlTemplate {
  List<String> items = ["1111", "2222", "3333", "4444"];
  
  String selected;
  String tmp = "";
  
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
    modal.create(new ModalOptions(template:template), scope:scope).then((dom.Element elem) {
      modalInstance = modal.show(elem);
      modalInstance.result.then((value) {
        selected = value;
      }, onError: (reson) {
        print('Dismiss $reson');
      });
    });
  }
  
  void ok(sel) {
    modalInstance.close(sel);
  }
}

/**
 * Modal controller with template from file.
 */
@NgController(selector: '[modal-ctrl-file-tmpl]', publishAs: 'ctrl')
class ModalCtrlFileTemplate {
  List<String> items = ["Sun", "Moon", "Star", "Planet"];
  
  String selected;
  String tmp;
  
  Modal modal;
  ModalInstance modalInstance;
  Scope scope;
  
  ModalCtrlFileTemplate(this.modal, this.scope);
  
  void open(String templateUrl) {
    modal.create(new ModalOptions(templateUrl:templateUrl), scope:scope).then((dom.Element elem) {
      modalInstance = modal.show(elem);
      modalInstance.result.then((value) {
        selected = value;
      }, onError: (reson) {
        print('Dismiss $reson');
      });
    });
  }
  
  void ok(sel) {
    modalInstance.close(sel);
  }
}

/**
 * Modal controller with template from file.
 */
@NgController(selector: '[modal-ctrl-tag-tmpl]', publishAs: 'ctrl')
class ModalCtrlTagTemplate {
  List<String> items = ["Java", "Dart", "JavaScript", "Ruby"];
  
  String selected;
  String tmp;
  
  Modal modal;
  ModalInstance modalInstance;
  Scope scope;
  
  ModalCtrlTagTemplate(this.modal, this.scope);
  
  void open(String templateUrl) {
    modal.create(new ModalOptions(templateUrl:templateUrl), scope:scope).then((dom.Element elem) {
      modalInstance = modal.show(elem);
      modalInstance.result.then((value) {
        selected = value;
      }, onError: (reson) {
        print('Dismiss $reson');
      });
    });
  }
  
  void ok(sel) {
    modalInstance.close(sel);
  }
}