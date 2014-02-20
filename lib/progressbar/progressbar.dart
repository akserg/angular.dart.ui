// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.progressbar;

import 'dart:html' as dom;
import "package:angular/angular.dart";
import 'package:angular_ui/utils/utils.dart';
import 'package:angular_ui/utils/transition.dart';

/**
 * Progressbar Module.
 */
class ProgressbarModule extends Module {
  ProgressbarModule() {
    install(new TransitionModule());
    value(ProgressbarConfig, new ProgressbarConfig(animate:true, max: 100));
    type(ProgressBar);
    type(Progress);
    type(Bar);
    type(NgPseudo);
  }
}

/**
 * Progressbar configuration.
 */
class ProgressbarConfig {
  bool animate;
  int max;

  ProgressbarConfig({this.animate, this.max});
}

@NgComponent(
    selector: 'progressbar',
    templateUrl: 'packages/angular_ui/progressbar/progressbar.html',
    publishAs: 'ctrl',
    map: const {
      'value': '=>value',
      'type': '@type'
    })
@NgComponent(
    selector: '[progressbar]',
    templateUrl: 'packages/angular_ui/progressbar/progressbar.html',
    publishAs: 'ctrl',
    map: const {
      'value': '=>value',
      'type': '@type'
    })
class ProgressBar extends _ProgressbarBase {
  ProgressbarConfig _config;
  NodeAttrs _attrs;

  @NgOneWay("max")
  int max;

  @NgOneWay("animate")
  bool animate;

  ProgressBar(this._attrs, this._config, Transition transistion, Scope scope, dom.Element element) : super(transistion, scope, element);

  evalMaxOrDefault(Scope scope) => max = (max == null) ? _config.max : toInt(scope.$parent.$eval(max.toString()));
  evalAnimateOrDefault(Scope scope) => animate = (animate == null) ? _config.animate : toBool(scope.$parent.$eval(animate.toString()));

  NodeAttrs get nodeAttr => _attrs;
  dom.Element getShadowElement(shadowRoot) => getFirstDiv(shadowRoot).children.first;
  int get computedMax => max;
  bool get isAnimate => animate;
}

@NgComponent(
    selector: 'stackedProgress',
    templateUrl: 'packages/angular_ui/progressbar/stackedProgress.html')
@NgComponent(
    selector: '[stackedProgress]',
    templateUrl: 'packages/angular_ui/progressbar/stackedProgress.html')
class Progress implements NgShadowRootAware, NgAttachAware {
  Scope _scope;
  dom.Element _element;
  Progress(this._scope, this._element);

  void attach() {
    _scope.classes = _element.classes.toString();
  }

  void onShadowRoot(dom.ShadowRoot shadowRoot) {
    shadowRoot.applyAuthorStyles = true;
  }
}

@NgComponent(
    selector: 'bar',
    templateUrl: 'packages/angular_ui/progressbar/bar.html',
    publishAs: 'ctrl',
    map: const {
      'value': '=>value',
      'type': '@type'
    })
@NgComponent(
    selector: '[bar]',
    templateUrl: 'packages/angular_ui/progressbar/bar.html',
    publishAs: 'ctrl',
    map: const {
      'value': '=>value',
      'type': '@type'
    })
class Bar extends _ProgressbarBase {
  ProgressbarConfig _config;
  NodeAttrs _parentAttrs;
  NodeAttrs _attrs;
  dom.Element _element;

  int _max;
  bool _animate;

  Bar(this._attrs, this._config, Transition transistion, Scope scope, dom.Element element) : super(transistion, scope, element) {
    _element = element;
  }

  evalMaxOrDefault(Scope scope) => _max = (_parentAttrs["max"] == null) ? _config.max : scope.$parent.$eval(_parentAttrs["max"]);
  evalAnimateOrDefault(Scope scope) => _animate = (_parentAttrs['animate'] == null) ? _config.animate : toBool(scope.$parent.$eval(_parentAttrs['animate']));

  _lazyInitParentAttrs() {
    if (_parentAttrs == null) _parentAttrs = new NodeAttrs(_element.parent);
  }

  void attach() {
    _lazyInitParentAttrs();
    super.attach();
  }

  void onShadowRoot(dom.ShadowRoot shadowRoot) {
    _lazyInitParentAttrs();
    super.onShadowRoot(shadowRoot);
  }

  NodeAttrs get nodeAttr => _attrs;
  dom.Element getShadowElement(shadowRoot) => getFirstDiv(shadowRoot);
  int get computedMax => _max;
  bool get isAnimate => _animate;
}

abstract class _ProgressbarBase implements NgShadowRootAware, NgAttachAware {
  dom.Element _element;
  Scope _scope;
  Transition _transistion;
  dom.ShadowRoot _shadowRoot;

  int _value;
  int _oldValue = 0;

  String type;
  String classes;

  _ProgressbarBase(this._transistion, this._scope, this._element);

  set value(int currenValue) {
    _value = currenValue;
    if (_shadowRoot != null) _update(getShadowElement(_shadowRoot));
  }

  int get computedMax;
  bool get isAnimate;
  NodeAttrs get nodeAttr;
  dom.Element getShadowElement(dom.ShadowRoot shadowRoot);

  evalMaxOrDefault(Scope scope);
  evalAnimateOrDefault(Scope scope);

  void attach() {
    classes = _element.classes.toString();
    if (_shadowRoot != null) _update(getShadowElement(_shadowRoot));
  }

  void onShadowRoot(dom.ShadowRoot shadowRoot) {
    _shadowRoot = shadowRoot;
    _shadowRoot.applyAuthorStyles = true;
    evalMaxOrDefault(_scope);
    evalAnimateOrDefault(_scope);
    if (_value != null) _update(getShadowElement(_shadowRoot));
  }

  void _update(dom.Element shadowElement) {
    if (_value == null) throw new StateError('attribute value is required, add value="{{initialValue}}" to your element: \'${_element.innerHtml}\'!');
    int percent = _getPercentage(_value);
    if (isAnimate) {
      shadowElement.style.width = _getPercentage(_oldValue).toString() + '%';
      _transistion(shadowElement, {'width': (percent.toString() + '%')});
    } else {
      shadowElement.style.width = (percent.toString() + '%');
      shadowElement.style.transition = 'none';
    }
    _oldValue = _value;
  }

  int _getPercentage(int value) {
    return (100 * value / computedMax).round();
  }
}