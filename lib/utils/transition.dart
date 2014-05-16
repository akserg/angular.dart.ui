// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.transition;

import 'dart:html' as dom;
import 'dart:async' as async;
import "package:angular/angular.dart";

import 'timeout.dart';

import 'package:logging/logging.dart' show Logger;
final _log = new Logger('angular.ui.transition');


/**
 * Transition Module.
 */
class TransitionModule extends Module {
  TransitionModule() {
    install(new TimeoutModule());
    bind(Transition);
  }
}

@Injectable()
class Transition {

  Timeout timeout;

  Transition(this.timeout) {
    _log.fine("Transition");
  }

  async.Completer call(dom.Element element, trigger, {Map options: const{}}) {

    async.Completer deferred = new async.Completer();

    dom.EventListener transitionEndHandler = (dom.Event event) {

      //_log.finer("TransitionEndHandler called");
      if (!deferred.isCompleted) {
        deferred.complete(element);
      }
    };

    if(options.containsKey('animation')) {
      dom.Window.animationEndEvent.forTarget(element).first.then(
              (dom.AnimationEvent e) => transitionEndHandler);
      //_log.finer("AnimationEnd.listener added");
    } else {
      element.onTransitionEnd.first.then((dom.TransitionEvent e) => transitionEndHandler(e));
      //_log.finer("TransitionEnd.listener added");
    }

    // Wrap in a timeout to allow the browser time to update the DOM before the transition is to occur
    //new async.Timer(const Duration(milliseconds: 200), () {
    timeout(() {
      if (trigger is String) {
        element.classes.add(trigger);
      } else if (trigger is Function) {
        trigger(element);
      } else if (trigger is Map) {
        trigger.forEach((propertyName, value) => element.style.setProperty(propertyName, value));
      }
      //If browser does not support transitions, instantly resolve
//      if (endEventName == null && !deferred.isCompleted) {
//        deferred.complete(element);
//      }
    });

    // Add our custom cancel function to the promise that is returned
    // We can call this if we are about to run a new transition, which we know will prevent this transition from ending,
    // i.e. it will therefore never raise a transitionEnd event for that transition
    deferred.future.catchError((error) {
      if (!deferred.isCompleted) {
        deferred.completeError('Transition cancelled');
      }
    });

    return deferred;
  }
}

