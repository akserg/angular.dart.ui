// Copyright (C) 2013 - 2015 Angular Dart UI authors. Please see AUTHORS.md.
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
    static const Map<String, String> transitionEndEventNames = const {
      'WebkitTransition': 'webkitTransitionEnd',
      'MozTransition': 'transitionend',
      'OTransition': 'oTransitionEnd',
      'transition': 'transitionend'
    };
    static const Map<String, String> animationEndEventNames = const {
      'WebkitTransition': 'webkitAnimationEnd',
      'MozTransition': 'animationend',
      'OTransition': 'oAnimationEnd',
      'transition': 'animationend'
    };
    
    Timeout timeout;
    String transitionEndEventName, animationEndEventName;

    Transition(this.timeout) {
      _log.fine("Transition");
      
      var transElement = dom.document.createElement('trans');
      
      findEndEventName(Map endEventNames) {
        for (String name in endEventNames.keys) {
          if (transElement.style.supportsProperty(name)) {
            return endEventNames[name];
          }
        }
        return null;
      }
      transitionEndEventName = findEndEventName(transitionEndEventNames);
      animationEndEventName = findEndEventName(animationEndEventNames);
    }

    async.Completer call(dom.Element element, trigger, {Map options: const{}}) { 
      async.Completer deferred = new async.Completer();
      var endEventName;
      if (options.containsKey('animation')) {
        endEventName = animationEndEventName;
      } else {
        endEventName = transitionEndEventName;
      }
      
      var transitionEndHandler;
      
      transitionEndHandler = (dom.Event event) {
        if (endEventName != null) {
          element.removeEventListener(endEventName, transitionEndHandler);
        }
        if (!deferred.isCompleted) {
          deferred.complete(element);
        }
      };
      
      if (endEventName != null) {
        element.addEventListener(endEventName, transitionEndHandler);
      }
      
      // Wrap in a timeout to allow the browser time to update the DOM before the transition is to occur
      timeout(() {
        if (trigger is String) {
          element.classes.add(trigger);
        } else if (trigger is Function) {
          trigger(element);
        } else if (trigger is Map) {
          trigger.forEach((propertyName, value) => element.style.setProperty(propertyName, value));
        }
        
        //If browser does not support transitions, instantly resolve
        if (endEventName == null) {
          deferred.complete(element);
        }
      });
       
      // Add our custom cancel function to the promise that is returned
      // We can call this if we are about to run a new transition, which we know will prevent this transition from ending,
      // i.e. it will therefore never raise a transitionEnd event for that transition
      deferred.future.then((value) {
        if (value == 'Canceled' && endEventName != null) {
          element.removeEventListener(endEventName, transitionEndHandler);
        }
      });
      
      return deferred;
   }
}