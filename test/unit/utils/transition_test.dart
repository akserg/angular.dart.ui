// Copyright (C) 2013 - 2016 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular_ui_test;

testTransition() {
  describe("[Transition]", () {
    TestBed _;
    Scope scope;
        
    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    beforeEach(() {
      module((Module _) => _
        ..install(new TransitionModule())
      );
    });

    it('returns our custom promise', inject((Transition transition) {
      var element = new dom.DivElement();
      Future promise = transition(element, '').future;
      expect(promise.then).toBeNotNull();
      expect(promise.catchError).toBeNotNull();
    }));

    it('changes the css if passed a string', inject((Transition transition) {
      var element = new dom.DivElement();
      transition(element, 'triggerClass').future.then((value) {
        expect(element.classes).toContain('triggerClass');
      });
    }));

    it('changes the style if passed an object', inject((Transition transition) {
      var element = new dom.DivElement();
      var triggerStyle = { 'height': '11px' };

      transition(element, triggerStyle).future.then((value) {
        expect(element.style.getPropertyValue('height')).toEqual('11px');
      });
    }));

    it('calls the function if passed', inject((Transition transition) {
      var element = new dom.DivElement();

      transition(element, (dom.Element e){
        e.classes.add("test");
      }).future.then((value) {
        expect(element.classes).toContain("test");
      });
    }));
  });
}
