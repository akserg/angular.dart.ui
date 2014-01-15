// Copyright (c) 2013 - 2014, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void collapseTests() {

  group('Testing collapse:', () {
    
    
    
    // Add injector and configure Modules before tests
    setUp(() {
      setUpInjector();
      module((Module m) => m.install(new CollapseModule()));
    });
    
    var compileElement = (Scope scope, Injector injector, Compiler compiler) {
      var div = new dom.Element.tag('div');
      div.setInnerHtml('<div collapse="isCollapsed">Some Content</div>', treeSanitizer: injector.get(dom.NodeTreeSanitizer));
      var el = compiler(div.nodes)(injector, div.nodes);
      scope.$digest();
      var element = el.elements[0];
      dom.document.body.append(element);
      return element;
    };
    
    // Remove injector after tests
    tearDown(tearDownInjector);
    
    test('should be hidden on initialization if isCollapsed = true without transition', inject((Scope scope, Injector injector, Compiler compiler) {
      scope.isCollapsed = true;
      var element = compileElement(scope, injector, compiler);
      scope.$digest();
      //No animation timeout here
      expect(element.style.height, equals("0px"));
      element.remove();
    }));
    
    test('should be hidden on initialization if isCollapsed = true without transition', inject((Scope scope, Injector injector, Compiler compiler) {
      var element = compileElement(scope, injector, compiler);
      scope.isCollapsed = false;
      scope.$digest();
      scope.isCollapsed = true;
      scope.$digest();
      //$timeout.flush();
      expect(element.style.height, equals("0px"));
      element.remove();
    }));
    
    test('should be shown on initialization if isCollapsed = false without transition', inject((Scope scope, Injector injector, Compiler compiler) {
      var element = compileElement(scope, injector, compiler);
      scope.isCollapsed = false;
      scope.$digest();
      //No animation timeout here
      expect(element.style.height != "0px", isTrue);
      element.remove();
    }));
  });
}