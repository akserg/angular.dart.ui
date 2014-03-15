// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void buttonsTests() {

  
  describe('Testing Checkbox buttons:', () {
    TestBed _;
    Scope scope;
    
    beforeEach(setUpInjector);
    beforeEach(module((Module module) {
      module.install(new ButtonModule());
    }));
    beforeEach(inject((TestBed tb) => _ = tb));
    beforeEach(inject((Scope s) => scope = s));

    afterEach(tearDownInjector);
    
    var compileButton = (String markup) {
      var el = _.compile(markup);
      scope.rootScope.apply();
      return el;
    };
    
    //model -> UI
    it('should work correctly with default model values', () {
      scope.context['model'] = false;
      var btn = compileButton('<button ng-model="model" btn-checkbox>click</button>');
      expect(btn).not.toHaveClass('active');

      scope.context['model'] = true;
      scope.rootScope.apply();
      expect(btn).toHaveClass('active');
    });
    
    it('should bind custom model values', () {
      scope.context['model'] = 1;
      var btn = compileButton('<button ng-model="model" btn-checkbox btn-checkbox-true="1" btn-checkbox-false="0">click</button>');
      expect(btn).toHaveClass('active');

      scope.context['model'] = 0;
      scope.rootScope.apply();
      expect(btn).not.toHaveClass('active');
    });
    
    //UI-> model
    it('should toggle default model values on click', () {
      scope.context['model'] = false;
      var btn = compileButton('<button ng-model="model" btn-checkbox>click</button>');

      btn.click();
      scope.rootScope.apply();
      expect(scope.context['model']).toEqual(true);
      expect(btn).toHaveClass('active');

      btn.click();
      scope.rootScope.apply();
      expect(scope.context['model']).toEqual(false);
      expect(btn).not.toHaveClass('active');
    });
    
    it('should toggle custom model values on click', () {
      scope.context['model'] = 0;
      var btn = compileButton('<button ng-model="model" btn-checkbox btn-checkbox-true="1" btn-checkbox-false="0">click</button>');

      btn.click();
      scope.rootScope.apply();
      expect(scope.context['model']).toEqual(1);
      expect(btn).toHaveClass('active');

      btn.click();
      scope.rootScope.apply();
      expect(scope.context['model']).toEqual(0);
      expect(btn).not.toHaveClass('active');
    });
    
    it('should monitor true / false value changes', () {
      scope.context['model'] = 1;
      scope.context['trueVal'] = 1;
      var btn = compileButton('<button ng-model="model" btn-checkbox btn-checkbox-true="trueVal">click</button>');

      expect(btn).toHaveClass('active');
      expect(scope.context['model']).toEqual(1);

      scope.context['model'] = 2;
      scope.context['trueVal'] = 2;
      scope.rootScope.apply();

      expect(btn).toHaveClass('active');
      expect(scope.context['model']).toEqual(2);
    });
  });
  
  describe('Testing radio buttons:', () {
    TestBed _;
    Scope scope;
    
    beforeEach(setUpInjector);
    beforeEach(module((Module module) {
      module.install(new ButtonModule());
    }));
    beforeEach(inject((TestBed tb) => _ = tb));
    beforeEach(inject((Scope s) => scope = s));

    afterEach(tearDownInjector);
    
    var compileButtons = (String markup) {
      var el = _.compile('<div>'+markup+'</div>');
      scope.rootScope.apply();
      return el.querySelectorAll('button');
    };
    
    //model -> UI
    it('should work correctly set active class based on model', () {
      var btns = compileButtons('<button ng-model="model" btn-radio="1">click1</button><button ng-model="model" btn-radio="2">click2</button>');
      expect(btns[0]).not.toHaveClass('active');
      expect(btns[1]).not.toHaveClass('active');

      scope.context['model'] = 2;
      scope.rootScope.apply();
      expect(btns[0]).not.toHaveClass('active');
      expect(btns[1]).toHaveClass('active');
    });
    
    //UI->model
    it('should work correctly set active class based on model', () {
      var btns = compileButtons('<button ng-model="model" btn-radio="1">click1</button><button ng-model="model" btn-radio="2">click2</button>');
      expect(scope.context['model']).toBeNull();

      btns[0].click();
      scope.rootScope.apply();
      expect(scope.context['model']).toEqual(1);
      expect(btns[0]).toHaveClass('active');
      expect(btns[1]).not.toHaveClass('active');

      btns[1].click();
      scope.rootScope.apply();
      expect(scope.context['model']).toEqual(2);
      expect(btns[1]).toHaveClass('active');
      expect(btns[0]).not.toHaveClass('active');
    });
    
    it('should watch btn-radio values and update state accordingly', () {
      scope.context['myValues'] = ["value1", "value2"];

      var btns = compileButtons('<button ng-model="model" btn-radio="myValues[0]">click1</button><button ng-model="model" btn-radio="myValues[1]">click2</button>');
      expect(btns[0]).not.toHaveClass('active');
      expect(btns[1]).not.toHaveClass('active');

      scope.context['model'] = "value2";
      scope.rootScope.apply();
      expect(btns[0]).not.toHaveClass('active');
      expect(btns[1]).toHaveClass('active');

      scope.context['myValues'][1] = "value3";
      scope.context['model'] = "value3";
      scope.rootScope.apply();
      expect(btns[0]).not.toHaveClass('active');
      expect(btns[1]).toHaveClass('active');
    });
  });
}