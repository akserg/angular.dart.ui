// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.collapse;

import 'dart:html' as dom;
import 'dart:async' as async;
import 'package:angular/angular.dart';
import 'package:angular/utils.dart';
import 'package:angular_ui/utils/transition.dart';

import 'package:logging/logging.dart' show Logger;
final _log = new Logger('angular.ui.collapse');

/**
 * Collapse Module.
 */
class CollapseModule extends Module {
  CollapseModule() {
    install(new TransitionModule());
    bind(Collapse);
  }
}

/**
 * The collapsible directive indicates a block of html that will expand and collapse.
 */
@Component(selector:'[collapse]', useShadowDom: false)
class Collapse implements ScopeAware {

  @NgOneWay("collapse")
  void set isCollapsed(bool value) {
    if (toBool(value)) {
      collapse();
    } else {
      expand();
    }
  }

  dom.Element element;
  Transition transition;
  Scope scope;

  var initialAnimSkip = true;
  async.Completer currentTransition;

  Collapse(this.element, this.transition);

  async.Future doTransition(change) {
    async.Completer newTransition = transition(element, change);

    var newTransitionDone = () {
      // Make sure it's this transition, otherwise, leave it alone.
      if (currentTransition == newTransition) {
        currentTransition = null;
      }
    };

    if (currentTransition != null && !currentTransition.isCompleted) {
      currentTransition.completeError('Canceled');
    }
    currentTransition = newTransition;
    newTransition.future.then((value)=> newTransitionDone(), onError:(e) => newTransitionDone());
    return newTransition.future;
  }

  void expand() {
    if (initialAnimSkip) {
      initialAnimSkip = false;
      expandDone();
    } else {
      element.classes
        ..remove('collapse')
        ..add('collapsing');

      doTransition({ 'height': '${element.scrollHeight}px' }).then((value) => expandDone(), onError: (e) {
        _log.fine('Error on expand: ${e}');
        expandDone();
      });
    }
  }

  void expandDone() {
    element.classes
      ..remove('collapsing')
      ..add('in')
      ..add('collapse');
    element.style.height = 'auto';
  }

  void collapse() {
    if (initialAnimSkip) {
      initialAnimSkip = false;
      collapseDone();
      element.style.height = "0";
    } else {
      // CSS transitions don't work with height: auto, so we have to manually change the height to a specific value
      element.style.height = '${element.scrollHeight}px';
      //trigger reflow so a browser realizes that height was updated from auto to a specific value
      var x;
      if(element.children.length > 0) {
        x = element.children[0].offsetWidth;
      } else {
        x = element.offsetWidth;
      }

      element.classes
        ..remove('collapse')
        ..remove('in')
        ..add('collapsing');

      doTransition({ 'height': '0' }).then((value) => collapseDone(), onError: (e) {
        _log.fine('Error on expand: ${e}');
        collapseDone();
      });
    }
  }

  void collapseDone() {
    element.classes
      ..remove('collapsing')
      ..add('collapse');
  }
}