// Copyright (c) 2013 - 2014, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.buttons;

import 'dart:html' as dom;
import "package:angular/angular.dart";

/**
 * Buttons Module.
 */
class ButtonModule extends Module {
  ButtonModule() {
    value(ButtonConfig, new ButtonConfig(activeClass:'active', toggleEvent: 'click'));
    type(BtnRadio);
    type(BtnCheckbox);
  }
}

/**
 * Buttons configuration.
 */
class ButtonConfig {
  String activeClass;
  String toggleEvent;
  
  ButtonConfig({this.activeClass, this.toggleEvent});
}

/**
 * Radio button directive.
 */
@NgDirective(selector:'[btn-radio]')
class BtnRadio {
  
  @NgAttr("btn-radio")
  String btnRadioAttr;
  
  ButtonConfig config;
  NgModel ngModel;
  
  dom.Element element;
  Scope scope;
  
  BtnRadio(this.element, this.ngModel, this.config, this.scope) {
    // model -> UI
    ngModel.render = (value) {
      //element.classes.toggle(config.activeClass, ngModel.modelValue == btnRadioAttr);
      element.classes.toggle(config.activeClass, ngModel.modelValue == scope.$eval(btnRadioAttr));
    };
    
    // ui -> model
    element.on[config.toggleEvent].listen((dom.Event event) {
      if (!element.classes.contains(config.activeClass)) {
        ngModel.viewValue = scope.$eval(btnRadioAttr);
      }
    });
  }
}

/**
 * Checkbox button directive
 */
@NgDirective(selector:'[btn-checkbox]')
class BtnCheckbox {
  ButtonConfig config;
  NgModel ngModel;
  
  @NgAttr("btn-checkbox-true")
  String btnCheckboxTrue;
  
  @NgAttr("btn-checkbox-false")
  String btnCheckboxFalse;
  
  Scope scope;
  dom.Element element;
  
  dynamic get trueValue => getCheckboxValue(btnCheckboxTrue, true);
  
  dynamic get falseValue => getCheckboxValue(btnCheckboxFalse, false);
  
  dynamic getCheckboxValue(attributeValue, defaultValue) {
    var val = scope.$eval(attributeValue);
    return val != null ? val : defaultValue;
  }
  
  BtnCheckbox(this.element, this.ngModel, this.config, this.scope) {
    // model -> UI
    ngModel.render = (value) {
      element.classes.toggle(config.activeClass, ngModel.modelValue == trueValue);
    };
  
    // ui -> model
    element.on[config.toggleEvent].listen((dom.Event event) {
      ngModel.viewValue = element.classes.contains(config.activeClass) ? falseValue : trueValue;
    });
  }
}