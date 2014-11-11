// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular_ui_test;

testTimepickerComponent() {
  DateTime newTime(hours, minutes) {
    var time = new DateTime.now();
    return new DateTime(time.year, time.month, time.day, hours, minutes, time.second, time.millisecond);
  }
  
  describe("[TimepickerComponent]", () {
        
    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    beforeEach(() {
      module((Module _) => _
        ..install(new TimepickerModule())
      );
//      return loadTemplates(['/timepicker/timepicker.html']);
    });

    String getHtml({String extra:''}) {
      return r'<timepicker ng-model="time" $extra></timepicker>';
    };
    
    Map getScopeContent() {
      return {'time': newTime(14, 40)};
    };
    
    List getModelState(Scope scope) {
      return [scope.context['time'].hour, scope.context['time'].minute];
    }

    dom.Element getArrow(timepicker, isUp, tdIndex) {
      var el = ngQuery(timepicker, 'tr')[(isUp) ? 0 : 2];
      el = ngQuery(el, 'td')[tdIndex];
      return ngQuery(el, 'a')[0];
    }

    dom.Element getHoursButton(timepicker, isUp) {
      return getArrow(timepicker, isUp, 0);
    }

    dom.Element getMinutesButton(timepicker, isUp) {
      return getArrow(timepicker, isUp, 2);
    }

    dom.ButtonElement getMeridianButton(timepicker) {
      return ngQuery(timepicker, 'button')[0];
    }

    void doClick(Scope scope, button, [int n = 1]) {
      for (var i = 0, max = n; i < max; i++) {
        button.click();
        microLeap();
        digest();
      }
    }

    dom.Event wheelThatMouse(delta) {
      var e = new dom.WheelEvent('mousewheel', deltaX:delta);
      return e;
    }
    
    dom.Event wheelThatOtherMouse(delta) {
      var e = new dom.WheelEvent('wheel', deltaY:delta);
      return e;
    }
    
    List getTimeState(timepicker, [withoutMeridian = false]) {
      List<dom.InputElement> inputs = ngQuery(timepicker, 'input');

      var state = [];
      for (var i = 0; i < 2; i ++) {
        state.add(inputs[i].value);
      }
      if (!withoutMeridian) {
        state.add(getMeridianButton(timepicker).text);
      }
      return state;
    }
    
    //*****************
      
    it('contains three row & three input elements', compileComponent(
        getHtml(), 
        getScopeContent(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final timepicker = shadowRoot.querySelector('timepicker');
      
      expect(ngQuery(timepicker, 'tr').length).toBe(3);
      expect(ngQuery(timepicker, 'input').length).toBe(2);
      expect(ngQuery(timepicker, 'button').length).toBe(1);
    }));
    
    it('has initially the correct time & meridian', compileComponent(
        getHtml(), 
        getScopeContent(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final timepicker = shadowRoot.querySelector('timepicker');
      
      expect(getTimeState(timepicker)).toEqual(['02', '40', 'PM']);
      expect(getModelState(scope)).toEqual([14, 40]);
    }));
    
//    it('has `selected` current time when model is initially cleared', compileComponent(
//        getHtml(), 
//        {'time': null}, 
//        (Scope scope, dom.HtmlElement shadowRoot) {
//      final timepicker = shadowRoot.querySelector('timepicker');
//
//      expect(scope.context['time']).toBe(null);
//      expect(getTimeState(timepicker)).not.toEqual(['', '', '']);
//    }));
    
    it('changes inputs when model changes value', compileComponent(
        getHtml(), 
        {'time': newTime(11, 50)}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final timepicker = shadowRoot.querySelector('timepicker');
      
      expect(getTimeState(timepicker)).toEqual(['11', '50', 'AM']);
      expect(getModelState(scope)).toEqual([11, 50]);

      scope.context['time'] = newTime(16, 40);
      microLeap();
      scope.rootScope.apply();
      
      expect(getTimeState(timepicker)).toEqual(['04', '40', 'PM']);
      expect(getModelState(scope)).toEqual([16, 40]);
    }));
    
    it('increases / decreases hours when arrows are clicked', compileComponent(
        getHtml(), 
        getScopeContent(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final timepicker = shadowRoot.querySelector('timepicker');
      
      var up = getHoursButton(timepicker, true);
      var down = getHoursButton(timepicker, false);

      doClick(scope, up);
      expect(getTimeState(timepicker)).toEqual(['03', '40', 'PM']);
      expect(getModelState(scope)).toEqual([15, 40]);

      doClick(scope, down);
      expect(getTimeState(timepicker)).toEqual(['02', '40', 'PM']);
      expect(getModelState(scope)).toEqual([14, 40]);

      doClick(scope, down);
      expect(getTimeState(timepicker)).toEqual(['01', '40', 'PM']);
      expect(getModelState(scope)).toEqual([13, 40]);
    }));
    
    it('increase / decreases minutes by default step when arrows are clicked', compileComponent(
        getHtml(), 
        getScopeContent(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final timepicker = shadowRoot.querySelector('timepicker');
      
      var up = getMinutesButton(timepicker, true);
      var down = getMinutesButton(timepicker, false);
  
      doClick(scope, up);
      expect(getTimeState(timepicker)).toEqual(['02', '41', 'PM']);
      expect(getModelState(scope)).toEqual([14, 41]);
  
      doClick(scope, down);
      expect(getTimeState(timepicker)).toEqual(['02', '40', 'PM']);
      expect(getModelState(scope)).toEqual([14, 40]);
  
      doClick(scope, down);
      expect(getTimeState(timepicker)).toEqual(['02', '39', 'PM']);
      expect(getModelState(scope)).toEqual([14, 39]);
    }));
    
    it('meridian button has correct type', compileComponent(
        getHtml(), 
        getScopeContent(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final timepicker = shadowRoot.querySelector('timepicker');
      
      var button = getMeridianButton(timepicker);
      expect(button.attributes['type']).toEqual('button');
    }));
    
    it('toggles meridian when button is clicked', compileComponent(
        getHtml(), 
        getScopeContent(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final timepicker = shadowRoot.querySelector('timepicker');
      
      var button = getMeridianButton(timepicker);
  
      doClick(scope, button);
      expect(getTimeState(timepicker)).toEqual(['02', '40', 'AM']);
      expect(getModelState(scope)).toEqual([2, 40]);
  
      doClick(scope, button);
      expect(getTimeState(timepicker)).toEqual(['02', '40', 'PM']);
      expect(getModelState(scope)).toEqual([14, 40]);
  
      doClick(scope, button);
      expect(getTimeState(timepicker)).toEqual(['02', '40', 'AM']);
      expect(getModelState(scope)).toEqual([2, 40]);
    }));
    
    it('has minutes "connected" to hours', compileComponent(
        getHtml(), 
        getScopeContent(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final timepicker = shadowRoot.querySelector('timepicker');
      
      var up = getMinutesButton(timepicker, true);
      var down = getMinutesButton(timepicker, false);
  
      doClick(scope, up, 10);
      expect(getTimeState(timepicker)).toEqual(['02', '50', 'PM']);
      expect(getModelState(scope)).toEqual([14, 50]);
  
      doClick(scope, up, 10);
      expect(getTimeState(timepicker)).toEqual(['03', '00', 'PM']);
      expect(getModelState(scope)).toEqual([15, 0]);
  
      doClick(scope, up, 10);
      scope.rootScope.apply();
      expect(getTimeState(timepicker)).toEqual(['03', '10', 'PM']);
      expect(getModelState(scope)).toEqual([15, 10]);
  
      doClick(scope, down, 10);
      scope.rootScope.apply();
      expect(getTimeState(timepicker)).toEqual(['03', '00', 'PM']);
      expect(getModelState(scope)).toEqual([15, 0]);
  
      doClick(scope, down, 10);
      scope.rootScope.apply();
      expect(getTimeState(timepicker)).toEqual(['02', '50', 'PM']);
      expect(getModelState(scope)).toEqual([14, 50]);
    }));
    
    it('has hours "connected" to meridian', compileComponent(
        getHtml(), 
        getScopeContent(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final timepicker = shadowRoot.querySelector('timepicker');
      
      var up = getHoursButton(timepicker, true);
      var down = getHoursButton(timepicker, false);
  
      // AM -> PM
      scope.context['time'] = newTime(11, 0);
      scope.rootScope.apply();
      expect(getTimeState(timepicker)).toEqual(['11', '00', 'AM']);
      expect(getModelState(scope)).toEqual([11, 0]);
  
      doClick(scope, up);
      expect(getTimeState(timepicker)).toEqual(['12', '00', 'PM']);
      expect(getModelState(scope)).toEqual([12, 0]);
  
      doClick(scope, up);
      expect(getTimeState(timepicker)).toEqual(['01', '00', 'PM']);
      expect(getModelState(scope)).toEqual([13, 0]);
  
      doClick(scope, down);
      expect(getTimeState(timepicker)).toEqual(['12', '00', 'PM']);
      expect(getModelState(scope)).toEqual([12, 0]);
  
      doClick(scope, down);
      expect(getTimeState(timepicker)).toEqual(['11', '00', 'AM']);
      expect(getModelState(scope)).toEqual([11, 0]);
  
      // PM -> AM
      scope.context['time'] = newTime(23, 0);
      scope.rootScope.apply();
      expect(getTimeState(timepicker)).toEqual(['11', '00', 'PM']);
      expect(getModelState(scope)).toEqual([23, 0]);
  
      doClick(scope, up);
      expect(getTimeState(timepicker)).toEqual(['12', '00', 'AM']);
      expect(getModelState(scope)).toEqual([0, 0]);
  
      doClick(scope, up);
      expect(getTimeState(timepicker)).toEqual(['01', '00', 'AM']);
      expect(getModelState(scope)).toEqual([01, 0]);
  
      doClick(scope, down);
      expect(getTimeState(timepicker)).toEqual(['12', '00', 'AM']);
      expect(getModelState(scope)).toEqual([0, 0]);
  
      doClick(scope, down);
      expect(getTimeState(timepicker)).toEqual(['11', '00', 'PM']);
      expect(getModelState(scope)).toEqual([23, 0]);
    }));
    
    
    it('changes only the time part when hours change', compileComponent(
        getHtml(), 
        {'time': newTime(23, 50)}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final timepicker = shadowRoot.querySelector('timepicker');
      
      var date =  scope.context['time'].day;
      var up = getHoursButton(timepicker, true);
      doClick(scope, up);
  
      expect(getTimeState(timepicker)).toEqual(['12', '50', 'AM']);
      expect(getModelState(scope)).toEqual([0, 50]);
      expect(date).toEqual(scope.context['time'].day);
    }));
  
//    it('changes only the time part when minutes change', compileComponent(
//        getHtml(extra:'minute-step="15"'), 
//        {'time': newTime(0, 0)}, 
//        (Scope scope, dom.HtmlElement shadowRoot) {
//      final timepicker = shadowRoot.querySelector('timepicker');
//  
//      var date =  scope.context['time'].day;
//      var up = getMinutesButton(timepicker, true);
//      doClick(scope, up, 2);
//      expect(getTimeState(timepicker)).toEqual(['12', '30', 'AM']);
//      expect(getModelState(scope)).toEqual([0, 30]);
//      expect(date).toEqual(scope.context['time'].day);
//  
//      var down = getMinutesButton(timepicker, false);
//      doClick(scope, down, 2);
//      expect(getTimeState(timepicker)).toEqual(['12', '00', 'AM']);
//      expect(getModelState(scope)).toEqual([0, 0]);
//      expect(date).toEqual(scope.context['time'].day);
//  
//      doClick(scope, down, 2);
//      expect(getTimeState(timepicker)).toEqual(['11', '30', 'PM']);
//      expect(getModelState(scope)).toEqual([23, 30]);
//      expect(date).toEqual(scope.context['time'].day);
//    }));
    
    it('responds properly on "mousewheel" events', compileComponent(
        getHtml(), 
        getScopeContent(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final timepicker = shadowRoot.querySelector('timepicker');
      
      var inputs = ngQuery(timepicker, 'input');
      var hoursEl = inputs[0], minutesEl = inputs[1];
      var upMouseWheelEvent = wheelThatMouse(1);
      var downMouseWheelEvent = wheelThatMouse(-1);
  
      expect(getTimeState(timepicker)).toEqual(['02', '40', 'PM']);
      expect(getModelState(scope)).toEqual([14, 40]);
  
      // Hours UP
      hoursEl.dispatchEvent( upMouseWheelEvent );
      scope.rootScope.apply();
      expect(getTimeState(timepicker)).toEqual(['03', '40', 'PM']);
      expect(getModelState(scope)).toEqual([15, 40]);
      // Hours UP
      hoursEl.dispatchEvent( upMouseWheelEvent );
      scope.rootScope.apply();
      expect(getTimeState(timepicker)).toEqual(['04', '40', 'PM']);
      expect(getModelState(scope)).toEqual([16, 40]);
      // Minutes UP
      minutesEl.dispatchEvent( upMouseWheelEvent );
      scope.rootScope.apply();
      expect(getTimeState(timepicker)).toEqual(['04', '41', 'PM']);
      expect(getModelState(scope)).toEqual([16, 41]);
      // Minutes UP
      minutesEl.dispatchEvent( upMouseWheelEvent );
      scope.rootScope.apply();
      expect(getTimeState(timepicker)).toEqual(['04', '42', 'PM']);
      expect(getModelState(scope)).toEqual([16, 42]);
  
      // Minutes DOWN
      minutesEl.dispatchEvent( downMouseWheelEvent );
      scope.rootScope.apply();
      expect(getTimeState(timepicker)).toEqual(['04', '41', 'PM']);
      expect(getModelState(scope)).toEqual([16, 41]);
      // Minutes DOWN
      minutesEl.dispatchEvent( downMouseWheelEvent );
      scope.rootScope.apply();
      expect(getTimeState(timepicker)).toEqual(['04', '40', 'PM']);
      expect(getModelState(scope)).toEqual([16, 40]);
      // Hours DOWN
      hoursEl.dispatchEvent( downMouseWheelEvent );
      scope.rootScope.apply();
      expect(getTimeState(timepicker)).toEqual(['03', '40', 'PM']);
      expect(getModelState(scope)).toEqual([15, 40]);
      // Hours DOWN
      hoursEl.dispatchEvent( downMouseWheelEvent );
      scope.rootScope.apply();
      expect(getTimeState(timepicker)).toEqual(['02', '40', 'PM']);
      expect(getModelState(scope)).toEqual([14, 40]);
    }));
 
    it('responds properly on "wheel" events', compileComponent(
        getHtml(), 
        getScopeContent(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final timepicker = shadowRoot.querySelector('timepicker');
      
      var inputs = ngQuery(timepicker, 'input');
      var hoursEl = inputs[0], minutesEl = inputs[1];
      var upMouseWheelEvent = wheelThatOtherMouse(-1);
      var downMouseWheelEvent = wheelThatOtherMouse(1);
  
      expect(getTimeState(timepicker)).toEqual(['02', '40', 'PM']);
      expect(getModelState(scope)).toEqual([14, 40]);
  
      // UP
      hoursEl.dispatchEvent( upMouseWheelEvent );
      scope.rootScope.apply();
      expect(getTimeState(timepicker)).toEqual(['03', '40', 'PM']);
      expect(getModelState(scope)).toEqual([15, 40]);
  
      hoursEl.dispatchEvent( upMouseWheelEvent );
      scope.rootScope.apply();
      expect(getTimeState(timepicker)).toEqual(['04', '40', 'PM']);
      expect(getModelState(scope)).toEqual([16, 40]);
  
      minutesEl.dispatchEvent( upMouseWheelEvent );
      scope.rootScope.apply();
      expect(getTimeState(timepicker)).toEqual(['04', '41', 'PM']);
      expect(getModelState(scope)).toEqual([16, 41]);
  
      minutesEl.dispatchEvent( upMouseWheelEvent );
      scope.rootScope.apply();
      expect(getTimeState(timepicker)).toEqual(['04', '42', 'PM']);
      expect(getModelState(scope)).toEqual([16, 42]);
  
      // DOWN
      minutesEl.dispatchEvent( downMouseWheelEvent );
      scope.rootScope.apply();
      expect(getTimeState(timepicker)).toEqual(['04', '41', 'PM']);
      expect(getModelState(scope)).toEqual([16, 41]);
  
      minutesEl.dispatchEvent( downMouseWheelEvent );
      scope.rootScope.apply();
      expect(getTimeState(timepicker)).toEqual(['04', '40', 'PM']);
      expect(getModelState(scope)).toEqual([16, 40]);
  
      hoursEl.dispatchEvent( downMouseWheelEvent );
      scope.rootScope.apply();
      expect(getTimeState(timepicker)).toEqual(['03', '40', 'PM']);
      expect(getModelState(scope)).toEqual([15, 40]);
  
      hoursEl.dispatchEvent( downMouseWheelEvent );
      scope.rootScope.apply();
      expect(getTimeState(timepicker)).toEqual(['02', '40', 'PM']);
      expect(getModelState(scope)).toEqual([14, 40]);
    }));
    
    describe('attributes',  () {
 
      String getHtml() {
        return r'<timepicker ng-model="time" hour-step="hstep" minute-step="mstep"></timepicker>';
      };
      
      Map getScopeContent() {
        return {'time': newTime(14, 0), 'hstep': 2, 'mstep': 30};
      };
      
      it('increases / decreases hours by configurable step', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final timepicker = shadowRoot.querySelector('timepicker');
        
        var up = getHoursButton(timepicker, true);
        var down = getHoursButton(timepicker, false);
  
        expect(getTimeState(timepicker)).toEqual(['02', '00', 'PM']);
        expect(getModelState(scope)).toEqual([14, 0]);
  
        doClick(scope, up);
        expect(getTimeState(timepicker)).toEqual(['04', '00', 'PM']);
        expect(getModelState(scope)).toEqual([16, 0]);
  
        doClick(scope, down);
        expect(getTimeState(timepicker)).toEqual(['02', '00', 'PM']);
        expect(getModelState(scope)).toEqual([14, 0]);
  
        doClick(scope, down);
        expect(getTimeState(timepicker)).toEqual(['12', '00', 'PM']);
        expect(getModelState(scope)).toEqual([12, 0]);
  
        // Change step
        scope.context['hstep'] = 3;
        scope.rootScope.apply();
  
        doClick(scope, up);
        expect(getTimeState(timepicker)).toEqual(['03', '00', 'PM']);
        expect(getModelState(scope)).toEqual([15, 0]);
  
        doClick(scope, down);
        expect(getTimeState(timepicker)).toEqual(['12', '00', 'PM']);
        expect(getModelState(scope)).toEqual([12, 0]);
      }));
      
      it('increases / decreases minutes by configurable step', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final timepicker = shadowRoot.querySelector('timepicker');
        
        var up = getMinutesButton(timepicker, true);
        var down = getMinutesButton(timepicker, false);
  
        doClick(scope, up);
        expect(getTimeState(timepicker)).toEqual(['02', '30', 'PM']);
        expect(getModelState(scope)).toEqual([14, 30]);
  
        doClick(scope, up);
        expect(getTimeState(timepicker)).toEqual(['03', '00', 'PM']);
        expect(getModelState(scope)).toEqual([15, 0]);
  
        doClick(scope, down);
        expect(getTimeState(timepicker)).toEqual(['02', '30', 'PM']);
        expect(getModelState(scope)).toEqual([14, 30]);
  
        doClick(scope, down);
        expect(getTimeState(timepicker)).toEqual(['02', '00', 'PM']);
        expect(getModelState(scope)).toEqual([14, 0]);
  
        // Change step
        scope.context['mstep'] = 15;
        scope.rootScope.apply();
  
        doClick(scope, up);
        expect(getTimeState(timepicker)).toEqual(['02', '15', 'PM']);
        expect(getModelState(scope)).toEqual([14, 15]);
  
        doClick(scope, down);
        expect(getTimeState(timepicker)).toEqual(['02', '00', 'PM']);
        expect(getModelState(scope)).toEqual([14, 0]);
  
        doClick(scope, down);
        expect(getTimeState(timepicker)).toEqual(['01', '45', 'PM']);
        expect(getModelState(scope)).toEqual([13, 45]);
      }));
  
      it('responds properly on "mousewheel" events with configurable steps', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final timepicker = shadowRoot.querySelector('timepicker');
        
        var inputs = ngQuery(timepicker, 'input');
        var hoursEl = inputs[0], minutesEl = inputs[1];
        var upMouseWheelEvent = wheelThatMouse(1);
        var downMouseWheelEvent = wheelThatMouse(-1);
  
        expect(getTimeState(timepicker)).toEqual(['02', '00', 'PM']);
        expect(getModelState(scope)).toEqual([14, 0]);
  
        // UP
        hoursEl.dispatchEvent( upMouseWheelEvent );
        scope.rootScope.apply();
        expect(getTimeState(timepicker)).toEqual(['04', '00', 'PM']);
        expect(getModelState(scope)).toEqual([16, 0]);
  
        minutesEl.dispatchEvent( upMouseWheelEvent );
        scope.rootScope.apply();
        expect(getTimeState(timepicker)).toEqual(['04', '30', 'PM']);
        expect(getModelState(scope)).toEqual([16, 30]);
  
        // DOWN
        minutesEl.dispatchEvent( downMouseWheelEvent );
        scope.rootScope.apply();
        expect(getTimeState(timepicker)).toEqual(['04', '00', 'PM']);
        expect(getModelState(scope)).toEqual([16, 0]);
  
        hoursEl.dispatchEvent( downMouseWheelEvent );
        scope.rootScope.apply();
        expect(getTimeState(timepicker)).toEqual(['02', '00', 'PM']);
        expect(getModelState(scope)).toEqual([14, 0]);
      }));
      
      it('responds properly on "wheel" events with configurable steps', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final timepicker = shadowRoot.querySelector('timepicker');
        
        var inputs = ngQuery(timepicker, 'input');
        var hoursEl = inputs[0], minutesEl = inputs[1];
        var upMouseWheelEvent = wheelThatOtherMouse(-1);
        var downMouseWheelEvent = wheelThatOtherMouse(1);
  
        expect(getTimeState(timepicker)).toEqual(['02', '00', 'PM']);
        expect(getModelState(scope)).toEqual([14, 0]);
  
        // UP
        hoursEl.dispatchEvent( upMouseWheelEvent );
        scope.rootScope.apply();
        expect(getTimeState(timepicker)).toEqual(['04', '00', 'PM']);
        expect(getModelState(scope)).toEqual([16, 0]);
  
        minutesEl.dispatchEvent( upMouseWheelEvent );
        scope.rootScope.apply();
        expect(getTimeState(timepicker)).toEqual(['04', '30', 'PM']);
        expect(getModelState(scope)).toEqual([16, 30]);
  
        // DOWN
        minutesEl.dispatchEvent( downMouseWheelEvent );
        scope.rootScope.apply();
        expect(getTimeState(timepicker)).toEqual(['04', '00', 'PM']);
        expect(getModelState(scope)).toEqual([16, 0]);
  
        hoursEl.dispatchEvent( downMouseWheelEvent );
        scope.rootScope.apply();
        expect(getTimeState(timepicker)).toEqual(['02', '00', 'PM']);
        expect(getModelState(scope)).toEqual([14, 0]);
      }));
  
      it('can handle strings as steps', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final timepicker = shadowRoot.querySelector('timepicker');
        
        var upHours = getHoursButton(timepicker, true);
        var upMinutes = getMinutesButton(timepicker, true);
  
        expect(getTimeState(timepicker)).toEqual(['02', '00', 'PM']);
        expect(getModelState(scope)).toEqual([14, 0]);
  
        scope.context['hstep'] = '4';
        scope.context['mstep'] = '20';
        scope.rootScope.apply();
  
        doClick(scope, upHours);
        expect(getTimeState(timepicker)).toEqual(['06', '00', 'PM']);
        expect(getModelState(scope)).toEqual([18, 0]);
  
        doClick(scope, upMinutes);
        expect(getTimeState(timepicker)).toEqual(['06', '20', 'PM']);
        expect(getModelState(scope)).toEqual([18, 20]);
      }));
    });
    
    describe('12 / 24 hour mode',  () {
      
      String getHtml() {
        return r'<timepicker ng-model="time" show-meridian="meridian"></timepicker>';
      };
      
      Map getScopeContent() {
        return {'time': newTime(14, 10), 'meridian': false};
      };
  
      dom.Element getMeridianTd(dom.Element timepicker) {
        dom.Element res = ngQuery(timepicker, 'tr')[1].querySelectorAll('td')[3];
        return res;
      }
  
      it('initially displays correct time when `show-meridian` is false', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final timepicker = shadowRoot.querySelector('timepicker');
        
        expect(getTimeState(timepicker, true)).toEqual(['14', '10']);
        expect(getModelState(scope)).toEqual([14, 10]);
        //expect(getMeridianTd()).toBeHidden();
        expect(getMeridianTd(timepicker).classes.contains('ng-hide')).toBeTruthy();
      }));
  
      it('toggles correctly between different modes', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final timepicker = shadowRoot.querySelector('timepicker');
        
        expect(getTimeState(timepicker, true)).toEqual(['14', '10']);
  
        scope.context['meridian'] = true;
        scope.rootScope.apply();
        expect(getTimeState(timepicker)).toEqual(['02', '10', 'PM']);
        expect(getModelState(scope)).toEqual([14, 10]);
        //expect(getMeridianTd()).not.toBeHidden();
        expect(getMeridianTd(timepicker).classes.contains('ng-hide')).toBeFalsy();
  
        scope.context['meridian'] = false;
        scope.rootScope.apply();
        expect(getTimeState(timepicker, true)).toEqual(['14', '10']);
        expect(getModelState(scope)).toEqual([14, 10]);
        //expect(getMeridianTd()).toBeHidden();
        expect(getMeridianTd(timepicker).classes.contains('ng-hide')).toBeTruthy();
      }));
      
//      it('handles correctly initially empty model on parent timepicker', async(inject(() {
//        dom.Element timepicker = createTimepicker();
//        
//        scope.context['time'] = null;
//        timepicker = $compile('<span ng-model="time"><timepicker show-meridian="meridian"></timepicker></span>')($rootScope);
//        scope.rootScope.apply();
//  
//        expect(scope.context['time']).toBe(null);
//      }));
    });
    
    describe('`meridians` attribute', () {

      String getHtml() {
        return r'<timepicker ng-model="time" meridians="meridiansArray"></timepicker>';
      };
      
      Map getScopeContent() {
        return {'time': newTime(14, 10), 'meridiansArray': ['am', 'pm']};
      };
  
      it('displays correctly', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final timepicker = shadowRoot.querySelector('timepicker');
        
        expect(getTimeState(timepicker)[2]).toEqual('pm');
      }));
  
      it('toggles correctly', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final timepicker = shadowRoot.querySelector('timepicker');
        
        scope.context['time'] = newTime(2, 40);
        scope.rootScope.apply();
        expect(getTimeState(timepicker)[2]).toEqual('am');
      }));
    });
    
    describe('setting timepickerConfig steps', () {
      TimepickerConfig originalConfig;
      
      beforeEach(inject((TimepickerConfig tpConfig) {
        originalConfig = tpConfig;
        tpConfig
          ..hourStep = 2
          ..minuteStep = 10
          ..showMeridian = false;
      }));
      
      afterEach(inject((TimepickerConfig tpConfig) {
        // return it to the original state
        tpConfig
            ..hourStep = originalConfig.hourStep
            ..minuteStep = originalConfig.minuteStep
            ..showMeridian = originalConfig.showMeridian;
      }));
      
      String getHtml() {
        return r'<timepicker ng-model="time"></timepicker>';
      };
      
      Map getScopeContent() {
        return {'time': newTime(14, 40)};
      };
  
      it('does not affect the initial value', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final timepicker = shadowRoot.querySelector('timepicker');
        
        expect(getTimeState(timepicker, true)).toEqual(['14', '40']);
        expect(getModelState(scope)).toEqual([14, 40]);
      }));
  
      it('increases / decreases hours with configured step', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final timepicker = shadowRoot.querySelector('timepicker');
        
        var up = getHoursButton(timepicker, true);
        var down = getHoursButton(timepicker, false);
  
        doClick(scope, up, 2);
        expect(getTimeState(timepicker, true)).toEqual(['18', '40']);
        expect(getModelState(scope)).toEqual([18, 40]);
  
        doClick(scope, down, 3);
        expect(getTimeState(timepicker, true)).toEqual(['12', '40']);
        expect(getModelState(scope)).toEqual([12, 40]);
      }));
  
      it('increases / decreases minutes with configured step', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final timepicker = shadowRoot.querySelector('timepicker');
        
        var up = getMinutesButton(timepicker, true);
        var down = getMinutesButton(timepicker, false);
  
        doClick(scope, up);
        expect(getTimeState(timepicker, true)).toEqual(['14', '50']);
        expect(getModelState(scope)).toEqual([14, 50]);
  
        doClick(scope, down, 3);
        expect(getTimeState(timepicker, true)).toEqual(['14', '20']);
        expect(getModelState(scope)).toEqual([14, 20]);
      }));
    });
    
    describe('setting timepickerConfig meridian labels', () {
          
      TimepickerConfig originalConfig;
            
      beforeEach(inject((TimepickerConfig tpConfig) {
        originalConfig = tpConfig;
        tpConfig
          ..meridians = ['π.μ.', 'μ.μ.']
          ..showMeridian = true;
      }));
      
      afterEach(inject((TimepickerConfig tpConfig) {
        // return it to the original state
        tpConfig
            ..meridians = originalConfig.meridians
            ..showMeridian = originalConfig.showMeridian;
      }));      
      
      String getHtml() {
        return r'<timepicker ng-model="time"></timepicker>';
      };
      
      Map getScopeContent() {
        return {'time': newTime(14, 40)};
      };
  
      it('displays correctly', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final timepicker = shadowRoot.querySelector('timepicker');
        
        expect(getTimeState(timepicker)).toEqual(['02', '40', 'μ.μ.']);
        expect(getModelState(scope)).toEqual([14, 40]);
      }));
  
      it('toggles correctly', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final timepicker = shadowRoot.querySelector('timepicker');
        
        scope.context['time'] = newTime(2, 40);
        scope.rootScope.apply();
  
        expect(getTimeState(timepicker)).toEqual(['02', '40', 'π.μ.']);
        expect(getModelState(scope)).toEqual([2, 40]);
      }));
    });
    
//    describe('user input validation',  () {
//      var changeInputValueTo;
//  
//      beforeEach(inject(($sniffer) {
//        changeInputValueTo =  (inputEl, value) {
//          inputEl.val(value);
//          inputEl.dispatchEvent($sniffer.hasEvent('input') ? 'input' : 'change');
//          scope.rootScope.apply();
//        };
//      }));
//  
//       getHoursInputEl() {
//        return timepicker.find('input').eq(0);
//      }
//  
//       getMinutesInputEl() {
//        return timepicker.find('input').eq(1);
//      }
//  
//      it('has initially the correct time & meridian', async(inject(() {
//        dom.Element timepicker = createTimepicker();
//        
//        expect(getTimeState(timepicker)).toEqual(['02', '40', 'PM']);
//        expect(getModelState()).toEqual([14, 40]);
//      }));
//  
//      it('updates hours & pads on input change & pads on blur', async(inject(() {
//        dom.Element timepicker = createTimepicker();
//        
//        var el = getHoursInputEl();
//  
//        changeInputValueTo(el, 5);
//        expect(getTimeState(timepicker)).toEqual(['5', '40', 'PM']);
//        expect(getModelState()).toEqual([17, 40]);
//  
//        el.blur();
//        expect(getTimeState(timepicker)).toEqual(['05', '40', 'PM']);
//        expect(getModelState()).toEqual([17, 40]);
//      }));
//  
//      it('updates minutes & pads on input change & pads on blur', async(inject(() {
//        dom.Element timepicker = createTimepicker();
//        
//        var el = getMinutesInputEl();
//  
//        changeInputValueTo(el, 9);
//        expect(getTimeState(timepicker)).toEqual(['02', '9', 'PM']);
//        expect(getModelState()).toEqual([14, 9]);
//  
//        el.blur();
//        expect(getTimeState(timepicker)).toEqual(['02', '09', 'PM']);
//        expect(getModelState()).toEqual([14, 9]);
//      }));
//  
//      it('clears model when input hours is invalid & alerts the UI', async(inject(() {
//        dom.Element timepicker = createTimepicker();
//        
//        var el = getHoursInputEl();
//  
//        changeInputValueTo(el, 'pizza');
//        expect(scope.context['time']).toBe(null);
//        expect(el.parent().hasClass('has-error')).toBe(true);
//        expect(timepicker.hasClass('ng-invalid-time')).toBe(true);
//  
//        changeInputValueTo(el, 8);
//        el.blur();
//        scope.rootScope.apply();
//        expect(getTimeState(timepicker)).toEqual(['08', '40', 'PM']);
//        expect(getModelState()).toEqual([20, 40]);
//        expect(el.parent().hasClass('has-error')).toBe(false);
//        expect(timepicker.hasClass('ng-invalid-time')).toBe(false);
//      }));
//  
//      it('clears model when input minutes is invalid & alerts the UI', async(inject(() {
//        dom.Element timepicker = createTimepicker();
//        
//        var el = getMinutesInputEl();
//  
//        changeInputValueTo(el, 'pizza');
//        expect(scope.context['time']).toBe(null);
//        expect(el.parent().hasClass('has-error')).toBe(true);
//        expect(timepicker.hasClass('ng-invalid-time')).toBe(true);
//  
//        changeInputValueTo(el, 22);
//        expect(getTimeState(timepicker)).toEqual(['02', '22', 'PM']);
//        expect(getModelState()).toEqual([14, 22]);
//        expect(el.parent().hasClass('has-error')).toBe(false);
//        expect(timepicker.hasClass('ng-invalid-time')).toBe(false);
//      }));
//  
//      it('handles 12/24H mode change', async(inject(() {
//        scope.context['meridian'] = true;
////        timepicker = $compile('<timepicker ng-model="time" show-meridian="meridian"></timepicker>')($rootScope);
//        dom.Element timepicker = _.compile('<timepicker ng-model="time" meridians="meridiansArray"></timepicker>', scope:scope);
//
//        microLeap();
//        scope.rootScope.apply();
//  
//        var el = getHoursInputEl();
//  
//        changeInputValueTo(el, '16');
//        expect(scope.context['time']).toBe(null);
//        expect(el.parent().hasClass('has-error')).toBe(true);
//        expect(timepicker.hasClass('ng-invalid-time')).toBe(true);
//  
//        scope.context['meridian'] = false;
//        scope.rootScope.apply();
//        expect(getTimeState(timepicker, true)).toEqual(['16', '40']);
//        expect(getModelState()).toEqual([16, 40]);
//        expect(timepicker.hasClass('ng-invalid-time')).toBe(false);
//      }));
//    });

    describe('when model is not a Date', () {
      
      it('should not be invalid when the model is null', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final timepicker = shadowRoot.querySelector('timepicker');
        
        scope.context['time'] = null;
        scope.rootScope.apply();
        expect(timepicker.classes.contains('ng-invalid-time')).toBeFalsy();
      }));
  
      it('should not be invalid when the model is undefined', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final timepicker = shadowRoot.querySelector('timepicker');
        
        scope.context['time'] = null;
        scope.rootScope.apply();
        expect(timepicker.classes.contains('ng-invalid-time')).toBeFalsy();
      }));
  
      it('should not be invalid when the model is a valid string date representation', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final timepicker = shadowRoot.querySelector('timepicker');
        
        //scope.context['time'] = 'September 30, 2010 15:30:00'; // 1969-07-20 20:18:00
        scope.context['time'] = '2010-09-30 15:30:00';
        scope.rootScope.apply();
        expect(timepicker.classes.contains('ng-invalid-time')).toBeFalsy();
        expect(getTimeState(timepicker)).toEqual(['03', '30', 'PM']);
      }));
      
//      it('should be invalid when the model is not a valid string date representation', async(inject(() {
//        dom.Element timepicker = createTimepicker();
//        
//        scope.context['time'] = 'pizza';
//        scope.rootScope.apply();
//        expect(timepicker.classes.contains('ng-invalid-time')).toBeTruthy();
//      }));
      
//      it('should return valid when the model becomes valid', async(inject(() {
//        dom.Element timepicker = createTimepicker();
//        
//        scope.context['time'] = 'pizza';
//        scope.rootScope.apply();
//        //expect(timepicker.hasClass('ng-invalid-time')).toBe(true);
//        expect(timepicker.classes.contains('ng-invalid-time')).toBeTruthy();
//  
//        scope.context['time'] = new Date();
//        scope.rootScope.apply();
//        //expect(timepicker.hasClass('ng-invalid-time')).toBe(false);
//        expect(timepicker.classes.contains('ng-invalid-time')).toBeFalse();
//      }));
//  
//      it('should return valid when the model is cleared', async(inject(() {
//        dom.Element timepicker = createTimepicker();
//        
//        scope.context['time'] = 'pizza';
//        scope.rootScope.apply();
//        expect(timepicker.hasClass('ng-invalid-time')).toBe(true);
//        expect(timepicker.classes.contains('ng-invalid-time')).toBeTruthy();
//  
//        scope.context['time'] = null;
//        scope.rootScope.apply();
//        //expect(timepicker.hasClass('ng-invalid-time')).toBe(false);
//        expect(timepicker.classes.contains('ng-invalid-time')).toBeFalse();
//      }));
    });
    
//    describe('use with `ng-required` directive', () {
//      it('should be invalid initially', async(inject(() {
//        dom.Element element = createTimepicker('ng-required="true"');
//        
//        //expect(element.hasClass('ng-invalid')).toBe(true);
//        expect(element.classes.contains('ng-invalid')).toBeTruthy();
//      })));
//  
//      it('should be valid if model has been specified', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        _scope.context['time'] = new Date();
//        _scope.rootScope.apply();
//        //expect(element.hasClass('ng-invalid')).toBe(false);
//        expect(element.classes.contains('ng-invalid')).toBeFalsy();
//      })));
//    });
    
  });
}