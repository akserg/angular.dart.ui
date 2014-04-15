// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.test;

void ratingTests() {

  describe('Rating', () {
    
    TestBed _;
    Scope scope;
    
    beforeEach(() {
      setUpInjector();
      module((Module module) {
        module.install(new RatingModule());
      });
      inject((TestBed tb, Scope s, TemplateCache cache) { 
        _ = tb;
        scope = s;
        addToTemplateCache(cache, 'packages/angular_ui/rating/rating.html');
      });
    });
    
    afterEach(tearDownInjector);

    dom.Element createElement([String html = null]) {
      scope.context['rate'] = 3;
      List<dom.Node> elements = $(html != null ? html : '<rating ng-model="rate"></rating>');
      dom.Element element =_.compile(elements, scope:scope);
      
      microLeap();
      scope.rootScope.apply();
      
      return element;
    }
    
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
    
    it('contains the default number of icons', async(inject(() {
      dom.Element element = createElement();
      
      expect(getStars(element).length).toBe(5);
    })));
    
    it('initializes the default star icons as selected', async(inject(() {
      dom.Element element = createElement();
      
      expect(getState(element)).toEqual([true, true, true, false, false]);
    })));
    
    it('handles correctly the click event', async(inject(() {
      dom.Element element = createElement();
      
      getStar(element, 2).click();
      scope.apply();
      expect(getState(element)).toEqual([true, true, false, false, false]);
      expect(scope.context['rate']).toBe(2);

      getStar(element, 5).click();
      scope.apply();
      expect(getState(element)).toEqual([true, true, true, true, true]);
      expect(scope.context['rate']).toBe(5);
    })));
    
    it('handles correctly the hover event', async(inject(() {
      dom.Element element = createElement();
      
      _.triggerEvent(getStar(element, 2), 'mouseover');
      expect(getState(element)).toEqual([true, true, false, false, false]);
      expect(scope.context['rate']).toBe(3);

      _.triggerEvent(getStar(element, 5), 'mouseenter');
      expect(getState(element)).toEqual([true, true, true, true, true]);
      expect(scope.context['rate']).toBe(3);

      dom.Element span = getSpan(element);
      _.triggerEvent(span, 'mouseleave');
      expect(getState(element)).toEqual([true, true, true, false, false]);
      expect(scope.context['rate']).toBe(3);
    })));
    
    //***************
    
    it('changes the number of selected icons when value changes', async(inject(() {
      dom.Element element = createElement();
      
      scope.context['rate'] = 2;
      scope.apply();

      expect(getState(element)).toEqual([true, true, false, false, false]);
    })));

    it('shows different number of icons when `max` attribute is set', async(inject(() {
      dom.Element element = createElement('<rating ng-model="rate" max="7"></rating>');

      expect(getStars(element).length).toBe(7);
    })));

    it('shows different number of icons when `max` attribute is from scope variable', async(inject(() {
      scope.context['max'] = 15;
      dom.Element element = createElement('<rating ng-model="rate" max="max"></rating>');
      
      expect(getStars(element).length).toBe(15);
    })));

    it('handles readonly attribute', async(inject(() {
      scope.context['isReadonly'] = true;
      dom.Element element = createElement('<rating ng-model="rate" readonly="isReadonly"></rating>');

      expect(getState(element)).toEqual([true, true, true, false, false]);

      var star5 = getStar(element, 5);
      _.triggerEvent(star5, 'mouseover');
      expect(getState(element)).toEqual([true, true, true, false, false]);

      scope.context['isReadonly'] = false;
      scope.apply();

      _.triggerEvent(star5, 'mouseover');
      expect(getState(element)).toEqual([true, true, true, true, true]);
    })));

    it('should fire onHover', async(inject(() {
      scope.context['hoveringOver'] = jasmine.createSpy('hoveringOver');
      dom.Element element = createElement('<rating ng-model="rate" on-hover="hoveringOver(value)"></rating>');

      _.triggerEvent(getStar(element, 3), 'mouseover');
      expect(scope.context['hoveringOver']).toHaveBeenCalledWith(3);
    })));

    it('should fire onLeave', async(inject(() {
      scope.context['leaving'] = jasmine.createSpy('leaving');
      dom.Element element = createElement('<rating ng-model="rate" on-leave="leaving()"></rating>');

      dom.Element span = getSpan(element);
      _.triggerEvent(span, 'mouseleave');
      expect(scope.context['leaving']).toHaveBeenCalled();
    })));

    describe('custom states', () {
      dom.Element createElement() {
        scope.context['rate'] = 3;
        scope.context['classOn'] = 'icon-ok-sign';
        scope.context['classOff'] = 'icon-ok-circle';
        List<dom.Node> elements = $('<rating ng-model="rate" state-on="classOn" state-off="classOff"></rating>');
        dom.Element element =_.compile(elements, scope:scope);
        
        microLeap();
        scope.rootScope.apply();
        
        return element;
      }

      it('changes the default icons', async(inject(() {
        dom.Element element = createElement();
        
        expect(getState(element, scope.context['classOn'], scope.context['classOff'])).toEqual([true, true, true, false, false]);
      })));
    });

    describe('`rating-states`', () {
      dom.Element createElement() {
        scope.context['rate'] = 3;
        scope.context['states'] = [
          {'stateOn': 'sign', 'stateOff': 'circle'},
          {'stateOn': 'heart', 'stateOff': 'ban'},
          {'stateOn': 'heart'},
          {'stateOff': 'off'}
        ];
        List<dom.Node> elements = $('<rating ng-model="rate" rating-states="states"></rating>');
        dom.Element element =_.compile(elements, scope:scope);
        
        microLeap();
        scope.rootScope.apply();
        
        return element;
      }
      
      it('should define number of icon elements', async(inject(() {
        dom.Element element = createElement();
        
        expect(getStars(element).length).toBe(scope.context['states'].length);
      })));

      it('handles each icon', async(inject(() {
        dom.Element element = createElement();
        
        var stars = getStars(element);

        for (var i = 0; i < stars.length; i++) {
          var star = stars[i];
          Map<String, String> state = scope.context['states'][i];
          var isOn = i < scope.context['rate'];

          expect(star.classes.contains(state['stateOn'])).toBe(isOn);
          expect(star.classes.contains(state['stateOff'])).toBe(!isOn);
        }
      })));
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

      it('should change number of icon elements', async(inject(() {
        dom.Element element = createElement();
        scope.context['rate'] = 5;
        scope.apply();
        
        expect(getStars(element).length).toBe(10);
      })));

      it('should change icon states', async(inject(() {
        dom.Element element = createElement();
        scope.context['rate'] = 5;
        scope.apply();
        
        expect(getState(element, 'on', 'off')).toEqual([true, true, true, true, true, false, false, false, false, false]);
      })));
    });
  });
}