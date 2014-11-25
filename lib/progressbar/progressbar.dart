// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.progressbar;

import 'dart:html' as dom;
import 'dart:async' as async;
import "package:angular/angular.dart";
import "package:angular/core_dom/module_internal.dart";
import 'package:angular_ui/utils/utils.dart';
import 'package:angular_ui/utils/transition.dart';

/**
 * Progressbar Module.
 */
class ProgressbarModule extends Module {
  ProgressbarModule() {
    install(new TransitionModule());
    bind(ProgressbarConfig, toValue:new ProgressbarConfig(animate:true, max: 100));
    bind(ProgressBar);
    bind(Progress);
    bind(Bar);
    bind(NgPseudo);
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

@Component(
    selector: 'progressbar',
    //templateUrl: 'packages/angular_ui/progressbar/progressbar.html',
    template: '''
<div class="progress" ng-class="classes">
    <div class="progress-bar" ng-class="[type, 'progress-bar-' + type]" role="progressbar">
        <content></content>
    </div>
</div>''',
    useShadowDom: false,
    map: const {
      'value': '=>value',
      'type': '@type'
    })
//@Component(
//    selector: '[progressbar]',
//    templateUrl: 'packages/angular_ui/progressbar/progressbar.html',
//    publishAs: 'ctrl',
//    useShadowDom: false,
//    map: const {
//      'value': '=>value',
//      'type': '@type'
//    })
class ProgressBar extends _ProgressbarBase {
  ProgressbarConfig _config;

  @NgOneWay("max")
  int max;

  @NgOneWay("animate")
  bool animate;
  
  String get type => _type;
  set type(val) { _type = val; }
  String get classes => _classes;
  
  set value(int val) {
    super.value = val;
  }

  ProgressBar(this._config, Transition transistion, dom.Element element) : super(transistion, element);

  evalMaxOrDefault(Scope scope) {
    max = (max == null) ? _config.max : toInt(scope.parentScope.eval(max.toString()));
  }
  
  evalAnimateOrDefault(Scope scope) {
    animate = (animate == null) ? _config.animate : toBool(scope.parentScope.eval(animate.toString()));
  }

  int get computedMax => max;
  bool get isAnimate => animate;
}

@Component(
    selector: 'stackedProgress',
    useShadowDom: false,
//    templateUrl: 'packages/angular_ui/progressbar/stackedProgress.html'
    template: '''
<div class="progress" ng-class="classes">
    <content></content>
</div><br>'''
)
//@Component(
//    selector: '[stackedProgress]',
//    useShadowDom: false,
//    templateUrl: 'packages/angular_ui/progressbar/stackedProgress.html')
class Progress implements AttachAware, ScopeAware {
  Scope scope;
  
  dom.Element _element;
  String classes;
  
  Progress(this._element);

  void attach() {
    this.classes = _element.classes.toString();
  }
}

@Component(
  selector: 'bar',
  //templateUrl: 'packages/angular_ui/progressbar/bar.html',
  template: '''
<div class="progress-bar" ng-class="[type, 'progress-bar-' + type,  classes]" ng-pseudo="x-bar">
    <content></content>
</div>''',
  useShadowDom: false,
  map: const {
    'value': '=>value',
    'type': '@type'
  })
//@Component(
//    selector: '[bar]',
//    templateUrl: 'packages/angular_ui/progressbar/bar.html',
//    publishAs: 'ctrl',
//    useShadowDom: false,
//    map: const {
//      'value': '=>value',
//      'type': '@type'
//    })
class Bar extends _ProgressbarBase {
  ProgressbarConfig _config;
  NodeAttrs _parentAttrs;

  int _max;
  bool _animate;
  
  String get type => _type;
  set type(val) { _type = val; }
  String get classes => _classes;

  Bar(this._config, Transition transistion, dom.Element element) : super(transistion, element);

  evalMaxOrDefault(Scope scope) {
    if (_element.parent.attributes.containsKey("max")) {
      _max = scope.parentScope.eval(_element.parent.attributes["max"]);
    } else {
      _max = _config.max;
    }
  }
  evalAnimateOrDefault(Scope scope) {
    if (_element.parent.attributes.containsKey("animate")) {
      _animate = scope.parentScope.eval(_element.parent.attributes["animate"]);
    } else {
      _animate = _config.animate;
    }
  }

  int get computedMax => _max;
  bool get isAnimate => _animate;
}

abstract class _ProgressbarBase implements AttachAware, ScopeAware {

  Scope scope;
  dom.Element _element;
  Transition _transistion;

  int _value = 0;
  int _oldValue = 0;

  String _type;
  String _classes;

  _ProgressbarBase(this._transistion, this._element);

  set value(int currenValue) {
    _value = currenValue;
    if (computedMax != null) {
      _update(getProgressBarElement());
    }
  }

  int get computedMax;
  bool get isAnimate;

  dom.Element getProgressBarElement() => _element.querySelector(".progress-bar");

  evalMaxOrDefault(Scope scope);
  evalAnimateOrDefault(Scope scope);

  void attach() {
    _classes = _element.classes.toString();
    new async.Future.delayed(Duration.ZERO, () {
      // We need call update on next event-loop iteration when element 
      // will be really attached.
      evalMaxOrDefault(scope);
      evalAnimateOrDefault(scope);
      _update(getProgressBarElement());
    });
  }

  void _update(dom.Element shadowElement) {
    if (_value == null) {
      throw new StateError('attribute value is required, add value="{{initialValue}}" to your element: \'${_element.innerHtml}\'!');
    }
    
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