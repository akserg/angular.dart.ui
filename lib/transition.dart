// Copyright (c) 2013 - 2014, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.transition;

import 'dart:html' as dom;
import 'dart:async' as async;
import "package:angular/angular.dart";

import 'timeout.dart';

/**
 * Transition Module.
 */
class TransitionModule extends Module {
  TransitionModule() {
    install(new TimeoutModule());
    type(Transition);
  }
}

class Transition {
  
  // Work out the name of the transitionEnd event
  var _transElement = new dom.DivElement();
  var _transitionEndEventNames = {
    'WebkitTransition': 'webkitTransitionEnd',
    'MozTransition': 'transitionend',
    'OTransition': 'oTransitionEnd',
    'transition': 'transitionend'
  };
  var _animationEndEventNames = {
    'WebkitTransition': 'webkitAnimationEnd',
    'MozTransition': 'animationend',
    'OTransition': 'oAnimationEnd',
    'transition': 'animationend'
  };
  
  var transitionEndEventName, animationEndEventName;
  
  Timeout timeout;
  
  Transition(this.timeout) {
    transitionEndEventName = _findEndEventName(_transitionEndEventNames);
    animationEndEventName = _findEndEventName(_animationEndEventNames);
  }
  
  async.Completer call(dom.Element element, trigger, {Map options:null}) {
    options = options != null ? options : {};
    //
    async.Completer deferred = new async.Completer();
    //
    var endEventName = options.containsKey('animation') ? animationEndEventName : transitionEndEventName;
    //
    dom.EventListener transitionEndHandler;
    transitionEndHandler = (dom.Event event) {
      element.removeEventListener(endEventName, transitionEndHandler);
      if (!deferred.isCompleted) {
        deferred.complete(element);
      }
    };
    
    if (endEventName != null) {
      element.addEventListener(endEventName, transitionEndHandler);
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
      if (endEventName == null && !deferred.isCompleted) {
        deferred.complete(element);
      }
    });
    
    // Add our custom cancel function to the promise that is returned
    // We can call this if we are about to run a new transition, which we know will prevent this transition from ending,
    // i.e. it will therefore never raise a transitionEnd event for that transition
    deferred.future.catchError((error) {
      if (endEventName != null) {
        element.removeEventListener(endEventName, transitionEndHandler);
      }
      if (!deferred.isCompleted) {
        deferred.completeError('Transition cancelled');
      }
    });
    
    return deferred;
  }
  
  String _findEndEventName(endEventNames) {
    endEventNames.forEach((k, v) {
      if (_transElement.style.getPropertyValue(k) != '') {
        return v;
      }
    });
    return null;
  }
}

