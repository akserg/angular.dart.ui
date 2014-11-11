// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular_ui_test;

testCheckboxComponent() {
  describe("[CheckboxComponent]", () {
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
      it('should work correctly with default model values', compileComponent(
          '<button ng-model="model" btn-checkbox>click</button>', 
          {'model':false}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final btn = shadowRoot.querySelector("button[btn-checkbox]");
        expect(btn).not.toHaveClass('active');
        
        scope.context['model'] = true;
        digest();
        expect(btn).toHaveClass('active');
      }));
      
      it('should bind custom model values', compileComponent(
          '<button ng-model="model" btn-checkbox btn-checkbox-true="1" btn-checkbox-false="0">click</button>', 
          {'model':1}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final btn = shadowRoot.querySelector("button[btn-checkbox]");
        expect(btn).toHaveClass('active');
  
        scope.context['model'] = 0;
        digest();
        expect(btn).not.toHaveClass('active');
      }));
    });
    
    describe("[UI-> model]", () {
      it('should toggle default model values on click', compileComponent(
          '<button ng-model="model" btn-checkbox>click</button>', 
          {'model':false}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final btn = shadowRoot.querySelector("button[btn-checkbox]");

        btn.click();
        expect(scope.context['model']).toEqual(true);
        expect(btn).toHaveClass('active');

        btn.click();
        expect(scope.context['model']).toEqual(false);
        expect(btn).not.toHaveClass('active');
      }));
      
      it('should toggle custom model values on click', compileComponent(
          '<button ng-model="model" btn-checkbox btn-checkbox-true="1" btn-checkbox-false="0">click</button>', 
          {'model':false}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final btn = shadowRoot.querySelector("button[btn-checkbox]");

        btn.click();
        expect(scope.context['model']).toEqual(1);
        expect(btn).toHaveClass('active');

        btn.click();
        expect(scope.context['model']).toEqual(0);
        expect(btn).not.toHaveClass('active');
      }));
      
      it('should monitor true / false value changes', compileComponent(
          '<button ng-model="model" btn-checkbox btn-checkbox-true="trueVal">click</button>', 
          {'model':1, 'trueVal':1}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final btn = shadowRoot.querySelector("button[btn-checkbox]");

        expect(btn).toHaveClass('active');
        expect(scope.context['model']).toEqual(1);

        scope.context['model'] = 2;
        scope.context['trueVal'] = 2;
        digest();

        expect(btn).toHaveClass('active');
        expect(scope.context['model']).toEqual(2);
      }));
    });
  });
}
