// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular_ui_test;

testRatingComponent() {
  describe("[RatingComponent]", () {
    TestBed _;
    Scope scope;
        
    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    beforeEach(() {
      module((Module _) => _
        ..install(new RatingModule())
      );
      inject((TestBed t) => _ = t);
      return loadTemplates(['rating/rating.html']);
   });

    dom.Element getSpan(dom.Element element) {
      return ngQuery(element, 'span')[0];
    }
    
    List<dom.Element> getStars(dom.Element element) {
      return ngQuery(element, 'i');
    }
    
    dom.Element getStar(dom.Element element, int number) {
      return getStars(element)[number - 1];
    }
    
    List getState(dom.Element element, [String classOn = null, String classOff = null]) {
      var stars = getStars(element);
      var state = [];
      for (var i = 0, n = stars.length; i < n; i++) {
        state.add((stars[i].classes.contains(classOn != null ? classOn : 'glyphicon-star') && !stars[i].classes.contains(classOff != null ? classOff : 'glyphicon-star-empty')) );
      }
      return state;
    }
    
    it('contains the default number of icons', compileComponent(
        '<rating ng-model="rate"></rating>', 
        {'rate': 3}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final rating = shadowRoot.querySelector('rating');
      
      expect(getStars(rating).length).toBe(5);
    }));
    
    it('initializes the default star icons as selected', compileComponent(
        '<rating ng-model="rate"></rating>', 
        {'rate': 3}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final rating = shadowRoot.querySelector('rating');
      
      expect(getState(rating)).toEqual([true, true, true, false, false]);
    }));
    
    it('handles correctly the click event', compileComponent(
        '<rating ng-model="rate"></rating>', 
        {'rate': 3}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final rating = shadowRoot.querySelector('rating');
      
      getStar(rating, 2).click();
      scope.apply();
      expect(getState(rating)).toEqual([true, true, false, false, false]);
      expect(scope.context['rate']).toBe(2);

      getStar(rating, 5).click();
      scope.apply();
      expect(getState(rating)).toEqual([true, true, true, true, true]);
      expect(scope.context['rate']).toBe(5);
    }));
    
    it('handles correctly the hover event', compileComponent(
        '<rating ng-model="rate"></rating>', 
        {'rate': 3}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final rating = shadowRoot.querySelector('rating');
      
      _.triggerEvent(getStar(rating, 2), 'mouseover');
      expect(getState(rating)).toEqual([true, true, false, false, false]);
      expect(scope.context['rate']).toBe(3);

      _.triggerEvent(getStar(rating, 5), 'mouseenter');
      expect(getState(rating)).toEqual([true, true, true, true, true]);
      expect(scope.context['rate']).toBe(3);

      dom.Element span = getSpan(rating);
      _.triggerEvent(span, 'mouseleave');
      expect(getState(rating)).toEqual([true, true, true, false, false]);
      expect(scope.context['rate']).toBe(3);
    }));
    
    //***************
  
    it('changes the number of selected icons when value changes', compileComponent(
        '<rating ng-model="rate"></rating>', 
        {'rate': 3}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final rating = shadowRoot.querySelector('rating');
      
      scope.context['rate'] = 2;
      scope.apply();
  
      expect(getState(rating)).toEqual([true, true, false, false, false]);
    }));
    
    it('shows different number of icons when `max` attribute is set', compileComponent(
        '<rating ng-model="rate" max="7"></rating>', 
        {'rate': 3}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final rating = shadowRoot.querySelector('rating');

      expect(getStars(rating).length).toBe(7);
    }));
    
    it('shows different number of icons when `max` attribute is from scope variable', compileComponent(
        '<rating ng-model="rate" max="max"></rating>', 
        {'rate': 3, 'max': 15}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final rating = shadowRoot.querySelector('rating');
      
      expect(getStars(rating).length).toBe(15);
    }));
    
    it('handles readonly attribute', compileComponent(
        '<rating ng-model="rate" readonly="isReadonly"></rating>', 
        {'rate': 3, 'isReadonly': true}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final rating = shadowRoot.querySelector('rating');

      expect(getState(rating)).toEqual([true, true, true, false, false]);

      var star5 = getStar(rating, 5);
      _.triggerEvent(star5, 'mouseover');
      expect(getState(rating)).toEqual([true, true, true, false, false]);

      scope.context['isReadonly'] = false;
      scope.apply();

      _.triggerEvent(star5, 'mouseover');
      expect(getState(rating)).toEqual([true, true, true, true, true]);
    }));
    
    it('should fire onHover', compileComponent(
        '<rating ng-model="rate" on-hover="hoveringOver(value)"></rating>', 
        {'rate': 3, 'hoveringOver': guinness.createSpy('hoveringOver')}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final rating = shadowRoot.querySelector('rating');

      _.triggerEvent(getStar(rating, 3), 'mouseover');
      expect(scope.context['hoveringOver']).toHaveBeenCalledWith(3);
    }));
    
    it('should fire onLeave', compileComponent(
        '<rating ng-model="rate" on-leave="leaving()"></rating>', 
        {'rate': 3, 'leaving': guinness.createSpy('leaving')}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final rating = shadowRoot.querySelector('rating');

      dom.Element span = getSpan(rating);
      _.triggerEvent(span, 'mouseleave');
      expect(scope.context['leaving']).toHaveBeenCalled();
    }));
    
    describe('custom states', () {
      it('changes the default icons', compileComponent(
          '<rating ng-model="rate" state-on="classOn" state-off="classOff"></rating>', 
          {'rate': 3, 'classOn': 'icon-ok-sign', 'classOff': 'icon-ok-circle'}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final rating = shadowRoot.querySelector('rating');
        
        expect(getState(rating, scope.context['classOn'], scope.context['classOff'])).toEqual([true, true, true, false, false]);
      }));
    });
    
    describe('`rating-states`', () {
      
      String getHtml() => '<rating ng-model="rate" rating-states="states"></rating>';
      Map getScope() => {'rate': 3, 'states': [
        {'stateOn': 'sign', 'stateOff': 'circle'},
        {'stateOn': 'heart', 'stateOff': 'ban'},
        {'stateOn': 'heart'},
        {'stateOff': 'off'}
      ]};
      
      it('changes the default icons', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final rating = shadowRoot.querySelector('rating');
        
        expect(getStars(rating).length).toBe(scope.context['states'].length);
      }));

      it('handles each icon', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final rating = shadowRoot.querySelector('rating');
        
        var stars = getStars(rating);

        for (var i = 0; i < stars.length; i++) {
          var star = stars[i];
          Map<String, String> state = scope.context['states'][i];
          var isOn = i < scope.context['rate'];

          expect(star.classes.contains(state['stateOn'])).toBe(isOn);
          expect(star.classes.contains(state['stateOff'])).toBe(!isOn);
        }
      }));
    });
    
    describe('setting ratingConfig', () {
      RatingConfig originalConfig;
      beforeEach(inject((RatingConfig ratingConfig) {
        //
        originalConfig = new RatingConfig()
        ..max = ratingConfig.max
        ..stateOn = ratingConfig.stateOn
        ..stateOff = ratingConfig.stateOff;
        //
        ratingConfig.max = 10;
        ratingConfig.stateOn = 'on';
        ratingConfig.stateOff = 'off';
      }));
      
      afterEach(inject((RatingConfig ratingConfig) {
        // return it to the original state
        ratingConfig
        ..max = originalConfig.max
        ..stateOn = originalConfig.stateOn
        ..stateOff = originalConfig.stateOff;
      }));

      String getHtml() => '<rating ng-model="rate"></rating>';
      
      it('should change number of icon elements', compileComponent(
          getHtml(), 
          {'rate': 3}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final rating = shadowRoot.querySelector('rating');
        
        scope.context['rate'] = 5;
        digest();
        
        expect(getStars(rating).length).toBe(10);
      }));

      it('should change icon states', compileComponent(
          getHtml(), 
          {'rate': 3}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final rating = shadowRoot.querySelector('rating');
        
        scope.context['rate'] = 5;
        digest();
        
        expect(getState(rating, 'on', 'off')).toEqual([true, true, true, true, true, false, false, false, false, false]);
      }));
    });
  });
}
