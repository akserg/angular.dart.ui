// Copyright (c) 2013 - 2014, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void collapseTests() {

  describe('Testing collapse:', () {
    TestBed _;
    Scope scope;
    Transition transition; 
    
    beforeEach(setUpInjector);
    beforeEach(module((Module module) {
      module.install(new CollapseModule());
    }));
    beforeEach(inject((TestBed tb) => _ = tb));
    beforeEach(inject((Scope s) => scope = s));
    beforeEach(inject((Transition t) => transition = t));

    afterEach(tearDownInjector);
    
    dom.Element element;
    
    beforeEach(() {
      element = _.compile('<div collapse="isCollapsed">Some Content</div>');
      dom.document.body.append(element);
    });
    
    afterEach(() {
      element.remove();
    });
    
    it('should be hidden on initialization if isCollapsed = true without transition', () {
      scope.isCollapsed = true;
      scope.$digest();
      //No animation timeout here
      expect(element.style.height, equals('0px'));
    });
  });    
}