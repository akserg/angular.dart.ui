// Copyright (c) 2013, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void transitionTests() {

  group('Testing transition:', () {
    
    // Add injector and configure Modules before tests
    setUp(() {
      setUpInjector();
      module((Module m) => m.install(new TransitionModule()));
    });
    
    // Remove injector after tests
    tearDown(tearDownInjector);
    
    test('should load transition', inject((Transition transition) {
      expect(transition, isNot(isEmpty));
    }));
    
    test('returns our custom future', inject((Transition transition) {
      var element = new dom.DivElement();
      
      var future = transition(element, '').future;
      
      expect(future.then, isNotNull);
      expect(future.catchError, isNotNull);
    }));
    
    test('changes the css if passed a string', inject((Transition transition) {
      var element = new dom.DivElement();
      
      transition(element, 'triggerClass').future.then((value) {
        expect(element.classes.contains('triggerClass'), isTrue);
      });
    }));
    
    test('changes the style if passed an object', inject((Transition transition) {
      var element = new dom.DivElement();
      var triggerStyle = { 'height': '11px' };
      
      transition(element, triggerStyle).future.then((value) {
        expect(element.style.getPropertyValue('height'), equals('11px'));
      });
    }));
    
    test('calls the function if passed', inject((Transition transition) {
      var element = new dom.DivElement();

      transition(element, (dom.Element e){
        e.classes.add("test");
      }).future.then((value) {
        expect(element.classes.contains("test"), isTrue);
      });
    }));
    
    test('should be undefined', inject((Transition transition) {
      expect(transition.transitionEndEventName == null, isTrue);
    }));
    
    test('does not bind a transitionEnd handler to the element', inject((Transition transition) {
      var element = new dom.DivElement();

      transition(element, '').future.then((value) {
        expect(transition.transitionEndEventName, isNull);
      });
    }));
    
    test('resolves the future', inject((Transition transition) {
      var element = new dom.DivElement();
      var transitionEndHandler = (dom.Element e) {
        e.classes.add("test");
      };
      
      var future = transition(element, '').future;
      future.then(transitionEndHandler).then((_){
        expect(element.classes.contains("test"), isTrue);
      });
    }));
  });
}