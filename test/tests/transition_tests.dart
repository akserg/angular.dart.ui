// Copyright (c) 2013 - 2014, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void transitionTests() {

  describe('transition', () {

    TestBed _;
    Transition transition;

    beforeEach(setUpInjector);
    beforeEach(module((Module module) {
      module.install(new TransitionModule());
    }));
    beforeEach(inject((TestBed tb) => _ = tb));
    beforeEach(inject((Transition t) => transition = t));

    afterEach(tearDownInjector);

    it('returns our custom promise', () {
      var element = new dom.DivElement();
      Future promise = transition(element, '').future;
      expect(promise.then).toBeNotNull();
      expect(promise.catchError).toBeNotNull();
    });

    it('changes the css if passed a string', () {
      var element = new dom.DivElement();
      transition(element, 'triggerClass').future.then((value) {
        expect(element.classes).toContain('triggerClass');
      });
    });

    it('changes the style if passed an object', () {
      var element = new dom.DivElement();
      var triggerStyle = { 'height': '11px' };

      transition(element, triggerStyle).future.then((value) {
        expect(element.style.getPropertyValue('height')).toEqual('11px');
      });
    });

    it('calls the function if passed', () {
      var element = new dom.DivElement();

      transition(element, (dom.Element e){
        e.classes.add("test");
      }).future.then((value) {
        expect(element.classes).toContain("test");
      });
    });
  });
}