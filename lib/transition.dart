// Copyright (c) 2013, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui;

class Transition {
  
  static const Map transitionEndEventNames = const {
   'WebkitTransition': 'webkitTransitionEnd',
   'MozTransition': 'transitionend',
   'OTransition': 'oTransitionEnd',
   'transition': 'transitionend'
  };
  static const Map animationEndEventNames = const {
    'WebkitTransition': 'webkitAnimationEnd',
    'MozTransition': 'animationend',
    'OTransition': 'oAnimationEnd',
    'transition': 'animationend'
  };
  
  String transitionEndEventName;
  String animationEndEventName;
  
  Transition() {
    // Work out the name of the transitionEnd event
    var transElement = document.createElement('trans');
    
    transitionEndEventName = _findEndEventName(transElement, transitionEndEventNames);
    animationEndEventName = _findEndEventName(transElement, animationEndEventNames);
  }
  
  String _findEndEventName(Element transElement, Map endEventNames) {
    endEventNames.forEach((k, v) {
      if (transElement.classes.contains(k)) {
        return v;
      }
    });
    return null;
  }
  
  Future make(Scope scope, Element element, trigger, [Map options = null]) {
    if (options == null) {
      options = {};
    }
    var deferred = new Completer();
    var endEventName = options.containsKey("animation") ? animationEndEventName : transitionEndEventName ;
    
    EventListener transitionEndHandler;
    transitionEndHandler = (event) {
      scope.$root.$apply((){
        element.removeEventListener(endEventName, transitionEndHandler);
        deferred.complete(element);
      });
    };
    
    if (endEventName != null) {
      element.addEventListener(endEventName, transitionEndHandler);
    }
    
    // Wrap in a timeout to allow the browser time to update the DOM before the 
    // transition is to occur
    // TODO: Ideas about delaying assign classes
//    new Timer(new Duration(milliseconds:0), () {
      if (trigger is String) {
        element.classes.add(trigger);
      } else if (trigger is Function) {
        Function.apply(trigger, [element]);
      } else if (trigger is Map) {
        trigger.forEach((propertyName, value) {
          element.style.setProperty(propertyName, value);
        });
      }
      
      //If browser does not support transitions, instantly resolve
      if (endEventName == null) {
        deferred.complete(element);
      }
//    });
    
    deferred.future.catchError((error){
      if (endEventName != null) {
        element.removeEventListener(endEventName, transitionEndHandler);
      }
    });
    
    return deferred.future;
  }
}
