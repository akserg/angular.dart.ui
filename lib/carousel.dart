// Copyright (c) 2013 - 2014, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.carousel;

import 'dart:html' as dom;
import 'dart:async' as async;
import "package:angular/angular.dart";
import 'transition.dart';
import 'timeout.dart';

/**
 * Carousel Module.
 */
class CarouselModule extends Module {
  CarouselModule() {
    install(new TransitionModule());
    type(CarouselController);
    type(Carousel);
    type(Slide);
  }
}

class CarouselController {
  List<Slide> slides = [];
  var currentIndex = -1;
  var currentTimeout;
  var isPlaying = false;
  Slide currentSlide;
  
  var destroyed = false;
  
  Scope scope;
  Transition transition;
  Timeout timeout;
  
  CarouselController(this.scope, this.transition, this.timeout) {
    scope.$on('destroy', () {
      destroyed = true;
    });
    
    scope.next = () {
      var newIndex = (currentIndex + 1) % slides.length;

      //Prevent this user-triggered transition from occurring if there is already one in progress
      if (scope.currentTransition == null) {
        return select(slides[newIndex], direction:'next');
      }
    };
    
    scope.prev = () {
      var newIndex = currentIndex - 1 < 0 ? slides.length - 1 : currentIndex - 1;

      //Prevent this user-triggered transition from occurring if there is already one in progress
      if (scope.currentTransition == null) {
        return select(slides[newIndex], direction:'prev');
      }
    };
    
    scope.select = (slide) {
      select(slide);
    };
    
    scope.isActive = (slide) {
      return currentSlide == slide;
    };
    
    scope.slides = () {
      return slides;
    };
    
    scope.$watch('interval', restartTimer);
    scope.$on('destroy', resetTimer);
    
    scope.play = () {
      if (!isPlaying) {
        isPlaying = true;
        restartTimer();
      }
    };
    
    scope.pause = () {
      if (!scope.noPause) {
        isPlaying = false;
        resetTimer();
      }
    };
  }
  
  void select(Slide nextSlide, {String direction:null}) {
    var nextIndex = slides.indexOf(nextSlide);
    // Decide direction if it's not given
    if (direction == null) {
      direction = nextIndex > currentIndex ? 'next' : 'prev';
    }
    if (nextSlide != null && nextSlide != currentSlide) {
      var goNext = () {
        // Scope has been destroyed, stop here.
        if (destroyed) { return; }
        //
        var transitionDone = (Slide next, Slide current) {
          next.direction = '';
          next.entering = false;
          next.leaving = false;
          next.active = true;
          //
          if (current != null) {
            current.direction = '';
            current.entering = false;
            current.leaving = false;
            current.active = false;
          }
          scope.currentTransition = null;
        };
        // If we have a slide to transition from and we have a transition type and we're allowed, go
        if (currentSlide != null && !scope.noTransition && nextSlide.element != null) {
          // We shouldn't do class manip in here, but it's the same weird thing bootstrap does. need to fix sometime
          nextSlide.element.classes.add(direction);
          var reflow = nextSlide.element.offsetWidth; //force reflow
          
          //Set all other slides to stop doing their stuff for the new transition
          slides.forEach((slide) {
            //angular.extend(slide, {direction: '', entering: false, leaving: false, active: false});
            slide.direction = '';
            slide.entering = false;
            slide.leaving = false;
            slide.active = false;
          });
          
          nextSlide.direction = direction;
          nextSlide.entering = true;
          nextSlide.active = true;
          
          if (currentSlide != null) {
            currentSlide.direction = direction;
            currentSlide.leaving = true;
          }
          
          scope.currentTransition = transition(nextSlide.element, {});
          
          // We have to create new pointers inside a closure since next & current will change
          var closure = (next, current) {
            (scope.currentTransition as async.Completer).future.then((onValue) {
              transitionDone(next, current);
            }, onError:(e) {
              transitionDone(next, current);
            });
          };
          //
          closure(nextSlide, currentSlide);
        } else {
          transitionDone(nextSlide, currentSlide);
        }
        currentSlide = nextSlide;
        currentIndex = nextIndex;
        //every time you change slides, reset the timer
        restartTimer();
      };
      
      if (scope.currentTransition != null) {
        (scope.currentTransition as async.Completer).completeError('Transition cancelled');
        //Timeout so ng-class in template has time to fix classes for finished slide
        timeout(goNext);
      } else {
        goNext();
      }
    }
  }
  
  /* Allow outside people to call indexOf on slides array */
  int indexOfSlide (slide) {
    return slides.indexOf(slide);
  }
  
  void restartTimer() {
    resetTimer();
    var interval = scope.interval;
    if (interval != null && interval >= 0) {
      currentTimeout = timeout(timerFn, delay:interval);
    }
  }
  
  void resetTimer() {
    if (currentTimeout != null) {
      timeout.cancel(currentTimeout);
      currentTimeout = null;
    }
  }
  
  void timerFn() {
    if (isPlaying) {
      scope.next();
      restartTimer();
    } else {
      scope.pause();
    }
  }
  
  void addSlide(slide, element) {
    slide.element = element;
    slides.add(slide);
    //if this is the first slide or the slide is set to active, select it
    if(slides.length == 1 || slide.active) {
      select(slides[slides.length-1]);
      if (slides.length == 1) {
        scope.play();
      }
    } else {
      slide.active = false;
    }
  }
  
  void removeSlide(slide) {
    //get the index of the slide inside the carousel
    var index = slides.indexOf(slide);
    slides.removeAt(index);
    if (slides.length > 0 && slide.active) {
      if (index >= slides.length) {
        select(slides[index-1]);
      } else {
        select(slides[index]);
      }
    } else if (currentIndex > index) {
      currentIndex--;
    }
  }
}

/**
 * Carousel component.
 */
@NgComponent(selector: 'carousel', publishAs: 'c', applyAuthorStyles: true, 
    template: ''' 
<div ng-mouseenter=\'c.pause()\' ng-mouseleave=\'c.play()\' class=\'carousel\'>
<ol class=\'carousel-indicators\' ng-show=\'c.slides().length > 1\'>
<li ng-repeat=\'slide in c.slides()\' ng-class=\'{active: c.isActive(slide)}\' ng-click=\'c.select(slide)\'></li>
</ol>
<div class=\'carousel-inner\'><content/></div>
<a class=\'left carousel-control\' ng-click=\'c.prev()\' ng-show=\'c.slides().length > 1\'><span class=\'icon-prev\'></span></a>
<a class=\'right carousel-control\' ng-click=\'c.next()\' ng-show=\'c.slides().length > 1\'><span class=\'icon-next\'></span></a>
</div>''')
class Carousel {
  
}

/**
 * Slide component.
 * Creates a slide inside a [Carousel] component. 
 * Must be placed as a child of a Carousel element.
 */
@NgComponent(selector: 'slide', publishAs: 's', applyAuthorStyles: true,
    template:'''
<div ng-class="{
    'active': s.leaving || (s.active && !s.entering),
    'prev': (s.next || s.active) && s.direction=='prev',
    'next': (s.next || s.active) && s.direction=='next',
    'right': s.direction=='prev',
    'left': s.direction=='next'
  }" class="item text-center"><content/></div>
''')
class Slide {
  @NgTwoWay('active')
  bool active = false;
  
  var direction = '';
  var entering = false;
  var leaving = false;
  
  var scope;
  dom.Element element;
  var carouselCtrl;
  
  Slide(Scope this.scope, dom.Element this.element, this.carouselCtrl) {
    carouselCtrl.addSlide(scope, element);
    //when the scope is destroyed then remove the slide from the current slides array
    scope.$on('destroy', () {
      carouselCtrl.removeSlide(scope);
    });

    scope.$watch('active', (active) {
      if (active) {
        carouselCtrl.select(scope);
      }
    });
  }
}