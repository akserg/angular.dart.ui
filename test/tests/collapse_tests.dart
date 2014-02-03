// Copyright (c) 2013 - 2014, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void collapseTests() {

  describe('Testing collapse:', () {
    TestBed _;
    Scope scope;
    Transition transition;
    Timeout timeout;
    dom.Element element;

    beforeEach(() {
      setUpInjector();

      module((Module module) {
        module.install(new CollapseModule());
      });
      inject((TestBed tb) => _ = tb);
      inject((Scope s) => scope = s);
      inject((Transition t) => transition = t);
      inject((Timeout t) => timeout = t);
      element = _.compile('<div collapse="isCollapsed">Some Content</div>');
      dom.document.body.append(element);
    });

    afterEach(() {
      tearDownInjector();
      element.remove();
    });


    it('should be hidden on initialization if isCollapsed = true without transition', () {
      scope.isCollapsed = true;
      scope.$digest();
      //No animation timeout here
      expect(element.style.height, equals('0px'));
    });

    it('should collapse if isCollapsed = true with animation on subsequent use', () {
      scope.isCollapsed = false;
      scope.$digest();
      scope.isCollapsed = true;
      scope.$digest();
      timeout.flush();
      expect(element.style.height, equals('0px'));
    });

    it('should be shown on initialization if isCollapsed = false without transition', () {
      scope.isCollapsed = false;
      scope.$digest();
      //No animation timeout here
      expect(element.style.height, isNot(equals('0px')));
    });

    it('should expand if isCollapsed = false with animation on subsequent use', () {
      scope.isCollapsed = false;
      scope.$digest();
      scope.isCollapsed = true;
      scope.$digest();
      scope.isCollapsed = false;
      scope.$digest();
      timeout.flush();
      expect(element.style.height, isNot(equals('0px')));
    });

    it('should expand if isCollapsed = true with animation on subsequent uses', () {
      scope.isCollapsed = false;
      scope.$digest();
      scope.isCollapsed = true;
      scope.$digest();
      scope.isCollapsed = false;
      scope.$digest();
      scope.isCollapsed = true;
      scope.$digest();
      timeout.flush();
      expect(element.style.height, equals('0px'));

      Collapse collapse = (ngProbe(element).directives as List).firstWhere((d) => d is Collapse);
      collapse.currentTransition.complete(true);
      expect(element.style.height).toEqual('0px');
    });
  });

  describe('dynamic content', () {

    TestBed _;
    Scope scope;
    Transition transition;
    Timeout timeout;
    dom.Element element;

    beforeEach(() {
      setUpInjector();

      module((Module module) {
        module.install(new CollapseModule());
      });
      inject((TestBed tb) => _ = tb);
      inject((Scope s) => scope = s);
      inject((Transition t) => transition = t);
      inject((Timeout t) => timeout = t);
      element = _.compile('<div collapse="isCollapsed"><p>Initial content</p><div ng-hide="hid">Additional content</div></div>');
      dom.document.body.append(element);
    });

    afterEach(() {
      tearDownInjector();
      element.remove();
    });


    it('should grow accordingly when content size inside collapse increases', () {
      scope['hid'] = true;
      Collapse collapse = (ngProbe(element).directives as List).firstWhere((d) => d is Collapse);
      collapse.isCollapsed = false;
      scope.$digest();
      var collapseHeight = element.clientHeight;
      scope['hid'] = false;
      scope.$digest();
      expect(element.clientHeight, greaterThan(collapseHeight));
    });

    it('should shrink accordingly when content size inside collapse decreases', () {
      scope['hid'] = false;
      scope.isCollapsed = false;
      scope.$digest();
      var collapseHeight = element.clientHeight;
      scope['hid'] = true;
      scope.$digest();
      expect(element.clientHeight, lessThan(collapseHeight));
    });

  });
}