// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular_ui_test;

testRadiobuttonComponent() {
  describe("[RadiobuttonComponent]", () {
    TestBed _;
    Scope scope;
        
    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    beforeEach(() {
      module((Module _) => _
        ..install(new ButtonModule())
      );
    });
    
    describe("[model -> UI]", () {
      it('should work correctly set active class based on model', compileComponent(
          '<button ng-model="model" btn-radio="1">click1</button><button ng-model="model" btn-radio="2">click2</button>', 
          {'model':false}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final btns = shadowRoot.querySelectorAll("button[btn-radio]");
        expect(btns[0]).not.toHaveClass('active');
        expect(btns[1]).not.toHaveClass('active');

        scope.context['model'] = 2;
        digest();
        expect(btns[0]).not.toHaveClass('active');
        expect(btns[1]).toHaveClass('active');
      }));
    });
    
    describe("[UI -> model]", () {
      it('should work correctly set active class based on model', compileComponent(
          '<button ng-model="model" btn-radio="1">click1</button><button ng-model="model" btn-radio="2">click2</button>', 
          {}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final btns = shadowRoot.querySelectorAll("button[btn-radio]");
        expect(scope.context['model']).toBeNull();

        btns[0].click();
        digest();
        expect(scope.context['model']).toEqual(1);
        expect(btns[0]).toHaveClass('active');
        expect(btns[1]).not.toHaveClass('active');

        btns[1].click();
        digest();
        expect(scope.context['model']).toEqual(2);
        expect(btns[1]).toHaveClass('active');
        expect(btns[0]).not.toHaveClass('active');
      }));
      
      it('should watch btn-radio values and update state accordingly', compileComponent(
          '<button ng-model="model" btn-radio="myValues[0]">click1</button><button ng-model="model" btn-radio="myValues[1]">click2</button>', 
          {'myValues':["value1", "value2"]}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final btns = shadowRoot.querySelectorAll("button[btn-radio]");
        expect(btns[0]).not.toHaveClass('active');
        expect(btns[1]).not.toHaveClass('active');

        scope.context['model'] = "value2";
        digest();
        expect(btns[0]).not.toHaveClass('active');
        expect(btns[1]).toHaveClass('active');

        scope.context['myValues'][1] = "value3";
        scope.context['model'] = "value3";
        digest();
        expect(btns[0]).not.toHaveClass('active');
        expect(btns[1]).toHaveClass('active');
      }));
    });
  });
}
