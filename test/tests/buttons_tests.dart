// Copyright (c) 2013 - 2014, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void buttonsTests() {

  group('Testing Checkbox buttons:', () {
    // Add injector and configure Modules before tests
    setUp(() {
      setUpInjector();
      module((Module m) => m.install(new ButtonsModule()));
    });
    
    var compileButton = (String html, Scope scope, Injector injector, Compiler compiler) {
      var div = new dom.Element.tag('div');
      div.setInnerHtml(html, treeSanitizer: injector.get(dom.NodeTreeSanitizer));
      var el = compiler(div.nodes)(injector, div.nodes);
      scope.$digest();
      return el.elements[0];
    };
    
    // Remove injector after tests
    tearDown(tearDownInjector);
    
    // model -> UI
    test('Should work correctly with default model values', inject((Scope scope, Injector injector, Compiler compiler) {
      scope.model = false;
      var btn = compileButton('<button ng-model="model" btn-checkbox>click</button>', scope, injector, compiler);
      expect(btn.classes.contains('active'), isFalse);

      scope.model = true;
      scope.$digest();
      expect(btn.classes.contains('active'), isTrue);
    }));
    
    
    // UI-> model
    test('Should toggle default model values on click', inject((Scope scope, Injector injector, Compiler compiler) {
      scope.model = false;
      var btn = compileButton('<button ng-model="model" btn-checkbox>click</button>', scope, injector, compiler);

      btn.click();
      scope.$digest();
      expect(scope.model, isTrue);
      expect(btn.classes.contains('active'), isTrue);

      btn.click();
      scope.$digest();
      expect(scope.model, isFalse);
      expect(btn.classes.contains('active'), isFalse);
    }));
    
  });
  
  group('Testing Radio buttons:', () {
    // Add injector and configure Modules before tests
    setUp(() {
      setUpInjector();
      module((Module m) => m.install(new ButtonsModule()));
    });
    
    var compileButtons = (String html, Scope scope, Injector injector, Compiler compiler) {
      var div = new dom.Element.tag('div');
      div.setInnerHtml(html, treeSanitizer: injector.get(dom.NodeTreeSanitizer));
      var el = compiler(div.nodes)(injector, div.nodes);
      scope.$digest();
      return el.elements;
    };

    // Remove injector after tests
    tearDown(tearDownInjector);
    
    // model -> UI
    test('Should work correctly with default model values', inject((Scope scope, Injector injector, Compiler compiler) {
      var btns = compileButtons('<button ng-model="model" btn-radio="1">click1</button><button ng-model="model" btn-radio="2">click2</button>', scope, injector, compiler);
      expect(btns.length, equals(2));
      expect(btns[0].classes.contains('active'), isFalse);
      expect(btns[1].classes.contains('active'), isFalse);

      scope.model = 2;
      scope.$digest();
      expect(btns[0].classes.contains('active'), isFalse);
      expect(btns[1].classes.contains('active'), isTrue);
    }));
    
    
    // UI-> model
    test('Should toggle default model values on click', inject((Scope scope, Injector injector, Compiler compiler) {
      var btns = compileButtons('<button ng-model="model" btn-radio="1">click1</button><button ng-model="model" btn-radio="2">click2</button>', scope, injector, compiler);
      expect(btns.length, equals(2));
      expect(scope.model, isNull);
      
      btns[0].click();
      scope.$digest();
      expect(scope.model, equals(1));
      expect(btns[0].classes.contains('active'), isTrue);
      expect(btns[1].classes.contains('active'), isFalse);
      
      btns[1].click();
      scope.$digest();
      expect(scope.model, equals(2));
      expect(btns[0].classes.contains('active'), isFalse);
      expect(btns[1].classes.contains('active'), isTrue);
    }));
    
  });
}