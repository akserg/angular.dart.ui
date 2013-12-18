// Copyright (c) 2013, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/monomer
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void transitionTests() {

  // TODO: Add tests for IE < 10
  group('Testing transition:', () {
    // Add injector and configure Modules before tests
    setUp(() {
      setUpInjector();
      module((Module m) => m.install(new AngularUI()));
    });
    
    // Remove injector after tests
    tearDown(tearDownInjector);
    
    /**
     * Test load Transition
     */
    test('should load transition', inject((Transition transition) {
      expect(transition, isNot(isEmpty));
    }));
    
//    /**
//     * Test load Transition
//     */
//    test('should load transition', inject((Transition transition) {
//      expect(transition, isNot(isEmpty));
//    }));
//    
//    /**
//     * Test Custorm [Future]
//     */
//    test('returns our custom future', inject((Transition $transition, Scope $rootScope) {
//      var element = new DivElement();
//      
//      var future = $transition.make($rootScope, element, '');
//      
//      expect(future.then, isNotNull);
//      expect(future.catchError, isNotNull);
//    }));
//    
//    /**
//     * Test CSS if passing a string
//     */
//    test('changes the css if passed a string', inject((Transition $transition, Scope $rootScope) {
//      var element = new DivElement();
//      
//      $transition.make($rootScope, element, 'triggerClass');
//
//      expect(element.classes.contains('triggerClass'), isTrue);
//    }));
//    
//    /**
//     * Test Style if passing an object
//     */
//    test('changes the style if passed an object', inject((Transition $transition, Scope $rootScope) {
//      var element = new DivElement();
//      var triggerStyle = { 'height': '11px' };
//      
//      $transition.make($rootScope, element, triggerStyle);
//
//      expect(element.style.getPropertyValue('height'), equals('11px'));
//    }));
//    
//    /**
//     * Test calls the function.
//     */
//    test('calls the function if passed', inject((Transition $transition, Scope $rootScope) {
//      var element = new DivElement();
//
//      $transition.make($rootScope, element, (Element e){
//        e.classes.add("test");
//      });
//
//      expect(element.classes.contains("test"), isTrue);
//    }));
//    
//    /**
//     * Test transitionEndEventName bust be equals null
//     */
//    test('should be undefined', inject((Transition $transition, Scope $rootScope) {
//      expect($transition.transitionEndEventName == null, isTrue);
//    }));
//    
//    /**
//     * Test a transitionEnd handler does not bind to element
//     */
//    test('does not bind a transitionEnd handler to the element', inject((Transition $transition, Scope $rootScope) {
//      var element = new DivElement();
//
//      $transition.make($rootScope, element, '');
//
//      expect($transition.transitionEndEventName, isNull);
//    }));
//    
//    /**
//     * Test future
//     */
//    test('resolves the future', inject((Transition $transition, Scope $rootScope) {
//      var element = new DivElement();
//      var transitionEndHandler = (Element e) {
//        e.classes.add("test");
//      };
//      
//      Future future = $transition.make($rootScope, element, '');
//      future.then(transitionEndHandler).then((_){
//        expect(element.classes.contains("test"), isTrue);
//      });
//    }));
  });
}