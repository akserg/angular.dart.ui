// Copyright (C) 2013 - 2015 Angular Dart UI authors. Please see AUTHORS.md.
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
    bind(ButtonConfig, toValue:new ButtonConfig(activeClass:'active', toggleEvent: 'click'));
    bind(BtnRadio);
    bind(BtnCheckbox);
  }
}

/**
 * Buttons configuration.
 */
class ButtonConfig {
  String activeClass;
  String toggleEvent;
  
  ButtonConfig({this.activeClass:'active', this.toggleEvent:'click'});
}

/**
 * Radio button directive.
 */
@Decorator(selector:'[btn-radio]')
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
      element.classes.toggle(config.activeClass, ngModel.modelValue == scope.eval(btnRadioAttr));
    };
    
    // ui -> model
    element.on[config.toggleEvent].listen((dom.Event event) {
      if (!element.classes.contains(config.activeClass)) {
        ngModel.markAsTouched();
        ngModel.viewValue = scope.eval(btnRadioAttr);
        ngModel.render(ngModel.modelValue);
      }
    });
  }
}

/**
 * Checkbox button directive
 */
@Decorator(selector:'[btn-checkbox]')
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
    var val = scope.eval(attributeValue);
    return val != null ? val : defaultValue;
  }
  
  BtnCheckbox(this.element, this.ngModel, this.config, this.scope) {
    // model -> UI
    ngModel.render = (value) {
      element.classes.toggle(config.activeClass, ngModel.modelValue == trueValue);
    };
  
    // ui -> model
    element.on[config.toggleEvent].listen((dom.Event event) {
      // We need remove focus out of the element because it doesn't change the state
      element.blur();
      ngModel.markAsTouched();
      ngModel.viewValue = element.classes.contains(config.activeClass) ? falseValue : trueValue;
      ngModel.render(ngModel.modelValue);
    });
    element.onBlur.listen((e) {
      ngModel.markAsTouched();
    });
  }
}