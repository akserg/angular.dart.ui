// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
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
      scope.context['isCollapsed'] = true;
      scope.rootScope.apply();
      //No animation timeout here
      expect(element.style.height, equals('0px'));
    });

    it('should collapse if isCollapsed = true with animation on subsequent use', () {
      scope.context['isCollapsed'] = false;
      scope.rootScope.apply();
      scope.context['isCollapsed'] = true;
      scope.rootScope.apply();
      timeout.flush();
      expect(element.style.height, equals('0px'));
    });

    it('should be shown on initialization if isCollapsed = false without transition', () {
      scope.context['isCollapsed'] = false;
      scope.rootScope.apply();
      //No animation timeout here
      expect(element.style.height, isNot(equals('0px')));
    });

    it('should expand if isCollapsed = false with animation on subsequent use', () {
      scope.context['isCollapsed'] = false;
      scope.rootScope.apply();
      scope.context['isCollapsed'] = true;
      scope.rootScope.apply();
      scope.context['isCollapsed'] = false;
      scope.rootScope.apply();
      timeout.flush();
      expect(element.style.height, isNot(equals('0px')));
    });

    it('should expand if isCollapsed = true with animation on subsequent uses', () {
      scope.context['isCollapsed'] = false;
      scope.rootScope.apply();
      scope.context['isCollapsed'] = true;
      scope.rootScope.apply();
      scope.context['isCollapsed'] = false;
      scope.rootScope.apply();
      scope.context['isCollapsed'] = true;
      scope.rootScope.apply();
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
      scope.context['hid'] = true;
      Collapse collapse = (ngProbe(element).directives as List).firstWhere((d) => d is Collapse);
      collapse.isCollapsed = false;
      scope.rootScope.apply();
      var collapseHeight = element.clientHeight;
      scope.context['hid'] = false;
      scope.rootScope.apply();
      expect(element.clientHeight, greaterThan(collapseHeight));
    });

    it('should shrink accordingly when content size inside collapse decreases', () {
      scope.context['hid'] = false;
      scope.context['isCollapsed'] = false;
      scope.rootScope.apply();
      var collapseHeight = element.clientHeight;
      scope.context['hid'] = true;
      scope.rootScope.apply();
      expect(element.clientHeight, lessThan(collapseHeight));
    });

  });
}