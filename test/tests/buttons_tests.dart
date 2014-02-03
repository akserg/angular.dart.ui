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
      scope.$digest();
      return el;
    };
    
    //model -> UI
    it('should work correctly with default model values', () {
      scope.model = false;
      var btn = compileButton('<button ng-model="model" btn-checkbox>click</button>');
      expect(btn).not.toHaveClass('active');

      scope.model = true;
      scope.$digest();
      expect(btn).toHaveClass('active');
    });
    
    it('should bind custom model values', () {
      scope.model = 1;
      var btn = compileButton('<button ng-model="model" btn-checkbox btn-checkbox-true="1" btn-checkbox-false="0">click</button>');
      expect(btn).toHaveClass('active');

      scope.model = 0;
      scope.$digest();
      expect(btn).not.toHaveClass('active');
    });
    
    //UI-> model
    it('should toggle default model values on click', () {
      scope.model = false;
      var btn = compileButton('<button ng-model="model" btn-checkbox>click</button>');

      btn.click();
      scope.$digest();
      expect(scope.model).toEqual(true);
      expect(btn).toHaveClass('active');

      btn.click();
      scope.$digest();
      expect(scope.model).toEqual(false);
      expect(btn).not.toHaveClass('active');
    });
    
    it('should toggle custom model values on click', () {
      scope.model = 0;
      var btn = compileButton('<button ng-model="model" btn-checkbox btn-checkbox-true="1" btn-checkbox-false="0">click</button>');

      btn.click();
      scope.$digest();
      expect(scope.model).toEqual(1);
      expect(btn).toHaveClass('active');

      btn.click();
      scope.$digest();
      expect(scope.model).toEqual(0);
      expect(btn).not.toHaveClass('active');
    });
    
    it('should monitor true / false value changes', () {
      scope.model = 1;
      scope.trueVal = 1;
      var btn = compileButton('<button ng-model="model" btn-checkbox btn-checkbox-true="trueVal">click</button>');

      expect(btn).toHaveClass('active');
      expect(scope.model).toEqual(1);

      scope.model = 2;
      scope.trueVal = 2;
      scope.$digest();

      expect(btn).toHaveClass('active');
      expect(scope.model).toEqual(2);
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
      scope.$digest();
      return el.querySelectorAll('button');
    };
    
    //model -> UI
    it('should work correctly set active class based on model', () {
      var btns = compileButtons('<button ng-model="model" btn-radio="1">click1</button><button ng-model="model" btn-radio="2">click2</button>');
      expect(btns[0]).not.toHaveClass('active');
      expect(btns[1]).not.toHaveClass('active');

      scope.model = 2;
      scope.$digest();
      expect(btns[0]).not.toHaveClass('active');
      expect(btns[1]).toHaveClass('active');
    });
    
    //UI->model
    it('should work correctly set active class based on model', () {
      var btns = compileButtons('<button ng-model="model" btn-radio="1">click1</button><button ng-model="model" btn-radio="2">click2</button>');
      expect(scope.model).toBeNull();

      btns[0].click();
      scope.$digest();
      expect(scope.model).toEqual(1);
      expect(btns[0]).toHaveClass('active');
      expect(btns[1]).not.toHaveClass('active');

      btns[1].click();
      scope.$digest();
      expect(scope.model).toEqual(2);
      expect(btns[1]).toHaveClass('active');
      expect(btns[0]).not.toHaveClass('active');
    });
    
    it('should watch btn-radio values and update state accordingly', () {
      scope.myValues = ["value1", "value2"];

      var btns = compileButtons('<button ng-model="model" btn-radio="myValues[0]">click1</button><button ng-model="model" btn-radio="myValues[1]">click2</button>');
      expect(btns[0]).not.toHaveClass('active');
      expect(btns[1]).not.toHaveClass('active');

      scope.model = "value2";
      scope.$digest();
      expect(btns[0]).not.toHaveClass('active');
      expect(btns[1]).toHaveClass('active');

      scope.myValues[1] = "value3";
      scope.model = "value3";
      scope.$digest();
      expect(btns[0]).not.toHaveClass('active');
      expect(btns[1]).toHaveClass('active');
    });
  });
}