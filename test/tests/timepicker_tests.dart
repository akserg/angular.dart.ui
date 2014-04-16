// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void timepickerTests() {
  
  DateTime newTime(hours, minutes) {
    var time = new DateTime.now();
    return new DateTime(time.year, time.month, time.day, hours, minutes, time.second, time.millisecond);
  }
  
  describe('Testing timepicker:', () {
    TestBed _;
    Scope _scope;
    TemplateCache cache;
    
    beforeEach(setUpInjector);
    beforeEach(module((Module module) {
      module.install(new TimepickerModule());
    }));
    beforeEach(inject((TestBed tb) => _ = tb));
    beforeEach(inject((Scope s) { 
      _scope = s;
      _scope.context['time'] = newTime(14, 40);
    }));
    beforeEach(inject((TemplateCache c) { 
      cache = c;
      addToTemplateCache(cache, 'packages/angular_ui/timepicker/timepicker.html');
    }));
    
    afterEach(tearDownInjector);

    dom.Element createTimepicker() {
      dom.Element element = _.compile('<timepicker ng-model="time"></timepicker>', scope:_scope);

      microLeap();
      _scope.rootScope.apply();
      
      return element;
    }
    
    List getModelState() {
      return [_scope.context['time'].hour, _scope.context['time'].minute];
    }

    dom.Element getArrow(element, isUp, tdIndex) {
      var el = ngQuery(element, 'tr')[(isUp) ? 0 : 2];
      el = ngQuery(el, 'td')[tdIndex];
      return ngQuery(el, 'a')[0];
    }

    dom.Element getHoursButton(element, isUp) {
      return getArrow(element, isUp, 0);
    }

    dom.Element getMinutesButton(element, isUp) {
      return getArrow(element, isUp, 2);
    }

    dom.ButtonElement getMeridianButton(element) {
      return ngQuery(element, 'button')[0];
    }

    void doClick(button, [n = 1]) {
      for (var i = 0, max = n || 1; i < max; i++) {
        button.click();
        microLeap();
        _scope.rootScope.apply();
      }
    }

    dom.Event wheelThatMouse(delta) {
      var e = new dom.WheelEvent('mousewheel', deltaX:delta);
      return e;
    }
    
    dom.Event wheelThatOtherMouse(delta) {
      var e = new dom.WheelEvent('wheel', deltaY:delta);
      e.deltaY = delta;
      return e;
    }
    
    List getTimeState(element, [withoutMeridian = false]) {
      List<dom.InputElement> inputs = ngQuery(element, 'input');

      var state = [];
      for (var i = 0; i < 2; i ++) {
        state.add(inputs[i].value);
      }
      if (!withoutMeridian) {
        state.add(getMeridianButton(element).text);
      }
      return state;
    }
    
    //*****************
    
    it('contains three row & three input elements', async(inject(() {
      dom.Element element = createTimepicker();
      
      expect(ngQuery(element, 'tr').length).toBe(3);
      expect(ngQuery(element, 'input').length).toBe(2);
      expect(ngQuery(element, 'button').length).toBe(1);
    })));
    
    it('has initially the correct time & meridian', async(inject(() {
      dom.Element element = createTimepicker();
      
      expect(getTimeState(element)).toEqual(['02', '40', 'PM']);
      expect(getModelState()).toEqual([14, 40]);
    })));
    
    it('has `selected` current time when model is initially cleared', async(inject(() {
      _scope.context['time'] = null;
      dom.Element element = createTimepicker();

      expect(_scope.context['time']).toBe(null);
      expect(getTimeState(element)).not.toEqual(['', '', '']);
    })));
    
    it('changes inputs when model changes value', async(inject(() {
      _scope.context['time'] = newTime(11, 50);
      dom.Element element = createTimepicker();
      
      expect(getTimeState(element)).toEqual(['11', '50', 'AM']);
      expect(getModelState()).toEqual([11, 50]);

      _scope.context['time'] = newTime(16, 40);
      microLeap();
      _scope.rootScope.apply();
      
      expect(getTimeState(element)).toEqual(['04', '40', 'PM']);
      expect(getModelState()).toEqual([16, 40]);
    })));
    
//    it('increases / decreases hours when arrows are clicked', async(inject(() {
//      dom.Element element = createTimepicker();
//      
//      var up = getHoursButton(element, true);
//      var down = getHoursButton(element, false);
//
//      doClick(up);
//      expect(getTimeState(element)).toEqual(['03', '40', 'PM']);
//      expect(getModelState()).toEqual([15, 40]);
//
//      doClick(down);
//      expect(getTimeState(element)).toEqual(['02', '40', 'PM']);
//      expect(getModelState()).toEqual([14, 40]);
//
//      doClick(down);
//      expect(getTimeState(element)).toEqual(['01', '40', 'PM']);
//      expect(getModelState()).toEqual([13, 40]);
//    })));
//
//    it('increase / decreases minutes by default step when arrows are clicked', async(inject(() {
//      dom.Element element = createTimepicker();
//      
//      var up = getMinutesButton(element, true);
//      var down = getMinutesButton(element, false);
//  
//      doClick(up);
//      expect(getTimeState(element)).toEqual(['02', '41', 'PM']);
//      expect(getModelState()).toEqual([14, 41]);
//  
//      doClick(down);
//      expect(getTimeState(element)).toEqual(['02', '40', 'PM']);
//      expect(getModelState()).toEqual([14, 40]);
//  
//      doClick(down);
//      expect(getTimeState(element)).toEqual(['02', '39', 'PM']);
//      expect(getModelState()).toEqual([14, 39]);
//    })));
//    
//    it('meridian button has correct type', async(inject(() {
//      dom.Element element = createTimepicker();
//      
//      var button = getMeridianButton(element);
//      expect(button.attributes['type']).toBe('button');
//    })));
//  
//    it('toggles meridian when button is clicked', async(inject(() {
//      dom.Element element = createTimepicker();
//      
//      var button = getMeridianButton(element);
//  
//      doClick(button);
//      expect(getTimeState(element)).toEqual(['02', '40', 'AM']);
//      expect(getModelState()).toEqual([2, 40]);
//  
//      doClick(button);
//      expect(getTimeState(element)).toEqual(['02', '40', 'PM']);
//      expect(getModelState()).toEqual([14, 40]);
//  
//      doClick(button);
//      expect(getTimeState(element)).toEqual(['02', '40', 'AM']);
//      expect(getModelState()).toEqual([2, 40]);
//    })));
//  
//    it('has minutes "connected" to hours', async(inject(() {
//      dom.Element element = createTimepicker();
//      
//      var up = getMinutesButton(element, true);
//      var down = getMinutesButton(element, false);
//  
//      doClick(up, 10);
//      expect(getTimeState(element)).toEqual(['02', '50', 'PM']);
//      expect(getModelState()).toEqual([14, 50]);
//  
//      doClick(up, 10);
//      expect(getTimeState(element)).toEqual(['03', '00', 'PM']);
//      expect(getModelState()).toEqual([15, 0]);
//  
//      doClick(up, 10);
//      _scope.rootScope.apply();
//      expect(getTimeState(element)).toEqual(['03', '10', 'PM']);
//      expect(getModelState()).toEqual([15, 10]);
//  
//      doClick(down, 10);
//      _scope.rootScope.apply();
//      expect(getTimeState(element)).toEqual(['03', '00', 'PM']);
//      expect(getModelState()).toEqual([15, 0]);
//  
//      doClick(down, 10);
//      _scope.rootScope.apply();
//      expect(getTimeState(element)).toEqual(['02', '50', 'PM']);
//      expect(getModelState()).toEqual([14, 50]);
//    })));
//  
//    it('has hours "connected" to meridian', async(inject(() {
//      dom.Element element = createTimepicker();
//      
//      var up = getHoursButton(element, true);
//      var down = getHoursButton(element, false);
//  
//      // AM -> PM
//      _scope.context['time'] = newTime(11, 0);
//      _scope.rootScope.apply();
//      expect(getTimeState(element)).toEqual(['11', '00', 'AM']);
//      expect(getModelState()).toEqual([11, 0]);
//  
//      doClick(up);
//      expect(getTimeState(element)).toEqual(['12', '00', 'PM']);
//      expect(getModelState()).toEqual([12, 0]);
//  
//      doClick(up);
//      expect(getTimeState(element)).toEqual(['01', '00', 'PM']);
//      expect(getModelState()).toEqual([13, 0]);
//  
//      doClick(down);
//      expect(getTimeState(element)).toEqual(['12', '00', 'PM']);
//      expect(getModelState()).toEqual([12, 0]);
//  
//      doClick(down);
//      expect(getTimeState(element)).toEqual(['11', '00', 'AM']);
//      expect(getModelState()).toEqual([11, 0]);
//  
//      // PM -> AM
//      _scope.context['time'] = newTime(23, 0);
//      _scope.rootScope.apply();
//      expect(getTimeState(element)).toEqual(['11', '00', 'PM']);
//      expect(getModelState()).toEqual([23, 0]);
//  
//      doClick(up);
//      expect(getTimeState(element)).toEqual(['12', '00', 'AM']);
//      expect(getModelState()).toEqual([0, 0]);
//  
//      doClick(up);
//      expect(getTimeState(element)).toEqual(['01', '00', 'AM']);
//      expect(getModelState()).toEqual([01, 0]);
//  
//      doClick(down);
//      expect(getTimeState(element)).toEqual(['12', '00', 'AM']);
//      expect(getModelState()).toEqual([0, 0]);
//  
//      doClick(down);
//      expect(getTimeState(element)).toEqual(['11', '00', 'PM']);
//      expect(getModelState()).toEqual([23, 0]);
//    })));
//  
//    it('changes only the time part when hours change', async(inject(() {
//      _scope.context['time'] = newTime(23, 50);
//      _scope.rootScope.apply();
//  
//      dom.Element element = createTimepicker();
//      
//      var date =  _scope.context['time'].getDate();
//      var up = getHoursButton(element, true);
//      doClick(up);
//  
//      expect(getTimeState(element)).toEqual(['12', '50', 'AM']);
//      expect(getModelState()).toEqual([0, 50]);
//      expect(date).toEqual(_scope.context['time'].getDate());
//    })));
//  
//    it('changes only the time part when minutes change', async(inject(() {
//      //element = $compile('<timepicker ng-model="time" minute-step="15"></timepicker>')($rootScope);
//      dom.Element element = createTimepicker('minute-step="15"');
//      _scope.context['time'] = newTime(0, 0);
//      _scope.rootScope.apply();
//  
//      var date =  _scope.context['time'].getDate();
//      var up = getMinutesButton(element, true);
//      doClick(up, 2);
//      expect(getTimeState(element)).toEqual(['12', '30', 'AM']);
//      expect(getModelState()).toEqual([0, 30]);
//      expect(date).toEqual(_scope.context['time'].getDate());
//  
//      var down = getMinutesButton(element, false);
//      doClick(down, 2);
//      expect(getTimeState(element)).toEqual(['12', '00', 'AM']);
//      expect(getModelState()).toEqual([0, 0]);
//      expect(date).toEqual(_scope.context['time'].getDate());
//  
//      doClick(down, 2);
//      expect(getTimeState(element)).toEqual(['11', '30', 'PM']);
//      expect(getModelState()).toEqual([23, 30]);
//      expect(date).toEqual(_scope.context['time'].getDate());
//    })));
//  
//    it('responds properly on "mousewheel" events', async(inject(() {
//      dom.Element element = createTimepicker();
//      
//      var inputs = element.find('input');
//      var hoursEl = inputs.eq(0), minutesEl = inputs.eq(1);
//      var upMouseWheelEvent = wheelThatMouse(1);
//      var downMouseWheelEvent = wheelThatMouse(-1);
//  
//      expect(getTimeState(element)).toEqual(['02', '40', 'PM']);
//      expect(getModelState()).toEqual([14, 40]);
//  
//      // UP
//      hoursEl.trigger( upMouseWheelEvent );
//      _scope.rootScope.apply();
//      expect(getTimeState(element)).toEqual(['03', '40', 'PM']);
//      expect(getModelState()).toEqual([15, 40]);
//  
//      hoursEl.trigger( upMouseWheelEvent );
//      _scope.rootScope.apply();
//      expect(getTimeState(element)).toEqual(['04', '40', 'PM']);
//      expect(getModelState()).toEqual([16, 40]);
//  
//      minutesEl.trigger( upMouseWheelEvent );
//      _scope.rootScope.apply();
//      expect(getTimeState(element)).toEqual(['04', '41', 'PM']);
//      expect(getModelState()).toEqual([16, 41]);
//  
//      minutesEl.trigger( upMouseWheelEvent );
//      _scope.rootScope.apply();
//      expect(getTimeState(element)).toEqual(['04', '42', 'PM']);
//      expect(getModelState()).toEqual([16, 42]);
//  
//      // DOWN
//      minutesEl.trigger( downMouseWheelEvent );
//      _scope.rootScope.apply();
//      expect(getTimeState(element)).toEqual(['04', '41', 'PM']);
//      expect(getModelState()).toEqual([16, 41]);
//  
//      minutesEl.trigger( downMouseWheelEvent );
//      _scope.rootScope.apply();
//      expect(getTimeState(element)).toEqual(['04', '40', 'PM']);
//      expect(getModelState()).toEqual([16, 40]);
//  
//      hoursEl.trigger( downMouseWheelEvent );
//      _scope.rootScope.apply();
//      expect(getTimeState(element)).toEqual(['03', '40', 'PM']);
//      expect(getModelState()).toEqual([15, 40]);
//  
//      hoursEl.trigger( downMouseWheelEvent );
//      _scope.rootScope.apply();
//      expect(getTimeState(element)).toEqual(['02', '40', 'PM']);
//      expect(getModelState()).toEqual([14, 40]);
//    })));
//  
//    it('responds properly on "wheel" events', async(inject(() {
//      dom.Element element = createTimepicker();
//      
//      var inputs = element.find('input');
//      var hoursEl = inputs.eq(0), minutesEl = inputs.eq(1);
//      var upMouseWheelEvent = wheelThatOtherMouse(-1);
//      var downMouseWheelEvent = wheelThatOtherMouse(1);
//  
//      expect(getTimeState(element)).toEqual(['02', '40', 'PM']);
//      expect(getModelState()).toEqual([14, 40]);
//  
//      // UP
//      hoursEl.trigger( upMouseWheelEvent );
//      _scope.rootScope.apply();
//      expect(getTimeState(element)).toEqual(['03', '40', 'PM']);
//      expect(getModelState()).toEqual([15, 40]);
//  
//      hoursEl.trigger( upMouseWheelEvent );
//      _scope.rootScope.apply();
//      expect(getTimeState(element)).toEqual(['04', '40', 'PM']);
//      expect(getModelState()).toEqual([16, 40]);
//  
//      minutesEl.trigger( upMouseWheelEvent );
//      _scope.rootScope.apply();
//      expect(getTimeState(element)).toEqual(['04', '41', 'PM']);
//      expect(getModelState()).toEqual([16, 41]);
//  
//      minutesEl.trigger( upMouseWheelEvent );
//      _scope.rootScope.apply();
//      expect(getTimeState(element)).toEqual(['04', '42', 'PM']);
//      expect(getModelState()).toEqual([16, 42]);
//  
//      // DOWN
//      minutesEl.trigger( downMouseWheelEvent );
//      _scope.rootScope.apply();
//      expect(getTimeState(element)).toEqual(['04', '41', 'PM']);
//      expect(getModelState()).toEqual([16, 41]);
//  
//      minutesEl.trigger( downMouseWheelEvent );
//      _scope.rootScope.apply();
//      expect(getTimeState(element)).toEqual(['04', '40', 'PM']);
//      expect(getModelState()).toEqual([16, 40]);
//  
//      hoursEl.trigger( downMouseWheelEvent );
//      _scope.rootScope.apply();
//      expect(getTimeState(element)).toEqual(['03', '40', 'PM']);
//      expect(getModelState()).toEqual([15, 40]);
//  
//      hoursEl.trigger( downMouseWheelEvent );
//      _scope.rootScope.apply();
//      expect(getTimeState(element)).toEqual(['02', '40', 'PM']);
//      expect(getModelState()).toEqual([14, 40]);
//    })));
  
//    describe('attributes',  () {
////      beforeEach(() {
////        _scope.context['hstep'] = 2;
////        _scope.context['mstep'] = 30;
////        _scope.context['time'] = newTime(14, 0);
////        //element = $compile('<timepicker ng-model="time" hour-step="hstep" minute-step="mstep"></timepicker>')($rootScope);
////        _scope.rootScope.apply();
////      });
//      
//      dom.Element createTimepicker() {
//        _scope.context['hstep'] = 2;
//        _scope.context['mstep'] = 30;
//        _scope.context['time'] = newTime(14, 0);
//        dom.Element element = _.compile('<timepicker ng-model="time" hour-step="hstep" minute-step="mstep"></timepicker>', scope:_scope);
//
//        microLeap();
//        _scope.rootScope.apply();
//        
//        return element;
//      }
//  
//      it('increases / decreases hours by configurable step', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        var up = getHoursButton(element, true);
//        var down = getHoursButton(element, false);
//  
//        expect(getTimeState(element)).toEqual(['02', '00', 'PM']);
//        expect(getModelState()).toEqual([14, 0]);
//  
//        doClick(up);
//        expect(getTimeState(element)).toEqual(['04', '00', 'PM']);
//        expect(getModelState()).toEqual([16, 0]);
//  
//        doClick(down);
//        expect(getTimeState(element)).toEqual(['02', '00', 'PM']);
//        expect(getModelState()).toEqual([14, 0]);
//  
//        doClick(down);
//        expect(getTimeState(element)).toEqual(['12', '00', 'PM']);
//        expect(getModelState()).toEqual([12, 0]);
//  
//        // Change step
//        _scope.context['hstep'] = 3;
//        _scope.rootScope.apply();
//  
//        doClick(up);
//        expect(getTimeState(element)).toEqual(['03', '00', 'PM']);
//        expect(getModelState()).toEqual([15, 0]);
//  
//        doClick(down);
//        expect(getTimeState(element)).toEqual(['12', '00', 'PM']);
//        expect(getModelState()).toEqual([12, 0]);
//      })));
//  
//      it('increases / decreases minutes by configurable step', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        var up = getMinutesButton(element, true);
//        var down = getMinutesButton(element, false);
//  
//        doClick(up);
//        expect(getTimeState(element)).toEqual(['02', '30', 'PM']);
//        expect(getModelState()).toEqual([14, 30]);
//  
//        doClick(up);
//        expect(getTimeState(element)).toEqual(['03', '00', 'PM']);
//        expect(getModelState()).toEqual([15, 0]);
//  
//        doClick(down);
//        expect(getTimeState(element)).toEqual(['02', '30', 'PM']);
//        expect(getModelState()).toEqual([14, 30]);
//  
//        doClick(down);
//        expect(getTimeState(element)).toEqual(['02', '00', 'PM']);
//        expect(getModelState()).toEqual([14, 0]);
//  
//        // Change step
//        _scope.context['mstep'] = 15;
//        _scope.rootScope.apply();
//  
//        doClick(up);
//        expect(getTimeState(element)).toEqual(['02', '15', 'PM']);
//        expect(getModelState()).toEqual([14, 15]);
//  
//        doClick(down);
//        expect(getTimeState(element)).toEqual(['02', '00', 'PM']);
//        expect(getModelState()).toEqual([14, 0]);
//  
//        doClick(down);
//        expect(getTimeState(element)).toEqual(['01', '45', 'PM']);
//        expect(getModelState()).toEqual([13, 45]);
//      })));
//  
//      it('responds properly on "mousewheel" events with configurable steps', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        var inputs = element.find('input');
//        var hoursEl = inputs.eq(0), minutesEl = inputs.eq(1);
//        var upMouseWheelEvent = wheelThatMouse(1);
//        var downMouseWheelEvent = wheelThatMouse(-1);
//  
//        expect(getTimeState(element)).toEqual(['02', '00', 'PM']);
//        expect(getModelState()).toEqual([14, 0]);
//  
//        // UP
//        hoursEl.trigger( upMouseWheelEvent );
//        _scope.rootScope.apply();
//        expect(getTimeState(element)).toEqual(['04', '00', 'PM']);
//        expect(getModelState()).toEqual([16, 0]);
//  
//        minutesEl.trigger( upMouseWheelEvent );
//        _scope.rootScope.apply();
//        expect(getTimeState(element)).toEqual(['04', '30', 'PM']);
//        expect(getModelState()).toEqual([16, 30]);
//  
//        // DOWN
//        minutesEl.trigger( downMouseWheelEvent );
//        _scope.rootScope.apply();
//        expect(getTimeState(element)).toEqual(['04', '00', 'PM']);
//        expect(getModelState()).toEqual([16, 0]);
//  
//        hoursEl.trigger( downMouseWheelEvent );
//        _scope.rootScope.apply();
//        expect(getTimeState(element)).toEqual(['02', '00', 'PM']);
//        expect(getModelState()).toEqual([14, 0]);
//      })));
//      
//      it('responds properly on "wheel" events with configurable steps', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        var inputs = element.find('input');
//        var hoursEl = inputs.eq(0), minutesEl = inputs.eq(1);
//        var upMouseWheelEvent = wheelThatOtherMouse(-1);
//        var downMouseWheelEvent = wheelThatOtherMouse(1);
//  
//        expect(getTimeState(element)).toEqual(['02', '00', 'PM']);
//        expect(getModelState()).toEqual([14, 0]);
//  
//        // UP
//        hoursEl.trigger( upMouseWheelEvent );
//        _scope.rootScope.apply();
//        expect(getTimeState(element)).toEqual(['04', '00', 'PM']);
//        expect(getModelState()).toEqual([16, 0]);
//  
//        minutesEl.trigger( upMouseWheelEvent );
//        _scope.rootScope.apply();
//        expect(getTimeState(element)).toEqual(['04', '30', 'PM']);
//        expect(getModelState()).toEqual([16, 30]);
//  
//        // DOWN
//        minutesEl.trigger( downMouseWheelEvent );
//        _scope.rootScope.apply();
//        expect(getTimeState(element)).toEqual(['04', '00', 'PM']);
//        expect(getModelState()).toEqual([16, 0]);
//  
//        hoursEl.trigger( downMouseWheelEvent );
//        _scope.rootScope.apply();
//        expect(getTimeState(element)).toEqual(['02', '00', 'PM']);
//        expect(getModelState()).toEqual([14, 0]);
//      })));
//  
//      it('can handle strings as steps', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        var upHours = getHoursButton(element, true);
//        var upMinutes = getMinutesButton(element, true);
//  
//        expect(getTimeState(element)).toEqual(['02', '00', 'PM']);
//        expect(getModelState()).toEqual([14, 0]);
//  
//        _scope.context['hstep'] = '4';
//        _scope.context['mstep'] = '20';
//        _scope.rootScope.apply();
//  
//        doClick(upHours);
//        expect(getTimeState(element)).toEqual(['06', '00', 'PM']);
//        expect(getModelState()).toEqual([18, 0]);
//  
//        doClick(upMinutes);
//        expect(getTimeState(element)).toEqual(['06', '20', 'PM']);
//        expect(getModelState()).toEqual([18, 20]);
//      })));
//  
//    });
  
//    describe('12 / 24 hour mode',  () {
//      beforeEach(() {
//        _scope.context['meridian'] = false;
//        _scope.context['time'] = newTime(14, 10);
//        element = $compile('<timepicker ng-model="time" show-meridian="meridian"></timepicker>')($rootScope);
//        _scope.rootScope.apply();
//      });
      
//      dom.Element createTimepicker() {
//        _scope.context['meridian'] = false;
//       _scope.context['time'] = newTime(14, 10);
//        dom.Element element = _.compile('<timepicker ng-model="time" show-meridian="meridian"></timepicker>', scope:_scope);
//
//        microLeap();
//        _scope.rootScope.apply();
//        
//        return element;
//      }
//  
//       getMeridianTd() {
//        return element.find('tr').eq(1).find('td').eq(3);
//      }
//  
//      it('initially displays correct time when `show-meridian` is false', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        expect(getTimeState(element, true)).toEqual(['14', '10']);
//        expect(getModelState()).toEqual([14, 10]);
//        expect(getMeridianTd()).toBeHidden();
//      })));
//  
//      it('toggles correctly between different modes', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        expect(getTimeState(element, true)).toEqual(['14', '10']);
//  
//        _scope.context['meridian'] = true;
//        _scope.rootScope.apply();
//        expect(getTimeState(element)).toEqual(['02', '10', 'PM']);
//        expect(getModelState()).toEqual([14, 10]);
//        expect(getMeridianTd()).not.toBeHidden();
//  
//        _scope.context['meridian'] = false;
//        _scope.rootScope.apply();
//        expect(getTimeState(element, true)).toEqual(['14', '10']);
//        expect(getModelState()).toEqual([14, 10]);
//        expect(getMeridianTd()).toBeHidden();
//      })));
//  
////      it('handles correctly initially empty model on parent element', async(inject(() {
////        dom.Element element = createTimepicker();
////        
////        _scope.context['time'] = null;
////        element = $compile('<span ng-model="time"><timepicker show-meridian="meridian"></timepicker></span>')($rootScope);
////        _scope.rootScope.apply();
////  
////        expect(_scope.context['time']).toBe(null);
////      })));
//    });
  
//    describe('`meridians` attribute', () {
////      beforeEach(inject(() {
////        _scope.context['meridiansArray'] = ['am', 'pm'];
////        element = $compile('<timepicker ng-model="time" meridians="meridiansArray"></timepicker>')($rootScope);
////        _scope.rootScope.apply();
////      }));
//      
//      dom.Element createTimepicker() {
//        _scope.context['meridiansArray'] = ['am', 'pm'];
//        dom.Element element = _.compile('<timepicker ng-model="time" meridians="meridiansArray"></timepicker>', scope:_scope);
//
//        microLeap();
//        _scope.rootScope.apply();
//        
//        return element;
//      }
//  
//      it('displays correctly', async(inject( () {
//        dom.Element element = createTimepicker();
//        
//        expect(getTimeState(element)[2]).toBe('pm');
//      })));
//  
//      it('toggles correctly', async(inject( () {
//        dom.Element element = createTimepicker();
//        
//        _scope.context['time'] = newTime(2, 40);
//        _scope.rootScope.apply();
//        expect(getTimeState(element)[2]).toBe('am');
//      })));
//    });
  
//    describe('setting timepickerConfig steps', () {
//      var originalConfig = {};
//      beforeEach(inject((_$compile_, _$rootScope_, timepickerConfig) {
//        angular.extend(originalConfig, timepickerConfig);
//        timepickerConfig.hourStep = 2;
//        timepickerConfig.minuteStep = 10;
//        timepickerConfig.showMeridian = false;
//        element = $compile('<timepicker ng-model="time"></timepicker>')($rootScope);
//        _scope.rootScope.apply();
//      }));
//      
//      
//      dom.Element createTimepicker() {
//        _scope.context['meridiansArray'] = ['am', 'pm'];
//        dom.Element element = _.compile('<timepicker ng-model="time"></timepicker>', scope:_scope);
//
//        microLeap();
//        _scope.rootScope.apply();
//        
//        return element;
//      }
//      
//      afterEach(inject((timepickerConfig) {
//        // return it to the original state
//        angular.extend(timepickerConfig, originalConfig);
//      }));
//  
//      it('does not affect the initial value', async(inject( () {
//        dom.Element element = createTimepicker();
//        
//        expect(getTimeState(element, true)).toEqual(['14', '40']);
//        expect(getModelState()).toEqual([14, 40]);
//      })));
//  
//      it('increases / decreases hours with configured step', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        var up = getHoursButton(element, true);
//        var down = getHoursButton(element, false);
//  
//        doClick(up, 2);
//        expect(getTimeState(element, true)).toEqual(['18', '40']);
//        expect(getModelState()).toEqual([18, 40]);
//  
//        doClick(down, 3);
//        expect(getTimeState(element, true)).toEqual(['12', '40']);
//        expect(getModelState()).toEqual([12, 40]);
//      })));
//  
//      it('increases / decreases minutes with configured step', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        var up = getMinutesButton(element, true);
//        var down = getMinutesButton(element, false);
//  
//        doClick(up);
//        expect(getTimeState(element, true)).toEqual(['14', '50']);
//        expect(getModelState()).toEqual([14, 50]);
//  
//        doClick(down, 3);
//        expect(getTimeState(element, true)).toEqual(['14', '20']);
//        expect(getModelState()).toEqual([14, 20]);
//      })));
//    });
  
//    describe('setting timepickerConfig meridian labels', () {
//      var originalConfig = {};
//      beforeEach(inject((_$compile_, _$rootScope_, timepickerConfig) {
//        angular.extend(originalConfig, timepickerConfig);
//        timepickerConfig.meridians = ['π.μ.', 'μ.μ.'];
//        timepickerConfig.showMeridian = true;
//        element = $compile('<timepicker ng-model="time"></timepicker>')($rootScope);
//        _scope.rootScope.apply();
//      }));
//      
//      dom.Element createTimepicker() {
//        _scope.context['meridiansArray'] = ['am', 'pm'];
//        dom.Element element = _.compile('<timepicker ng-model="time"></timepicker>', scope:_scope);
//
//        microLeap();
//        _scope.rootScope.apply();
//        
//        return element;
//      }
//      
//      afterEach(inject((timepickerConfig) {
//        // return it to the original state
//        angular.extend(timepickerConfig, originalConfig);
//      }));
//  
//      it('displays correctly', async(inject( () {
//        dom.Element element = createTimepicker();
//        
//        expect(getTimeState(element)).toEqual(['02', '40', 'μ.μ.']);
//        expect(getModelState()).toEqual([14, 40]);
//      })));
//  
//      it('toggles correctly', async(inject( () {
//        dom.Element element = createTimepicker();
//        
//        _scope.context['time'] = newTime(2, 40);
//        _scope.rootScope.apply();
//  
//        expect(getTimeState(element)).toEqual(['02', '40', 'π.μ.']);
//        expect(getModelState()).toEqual([2, 40]);
//      })));
//    });
  
//    describe('user input validation',  () {
//      var changeInputValueTo;
//  
//      beforeEach(inject(($sniffer) {
//        changeInputValueTo =  (inputEl, value) {
//          inputEl.val(value);
//          inputEl.trigger($sniffer.hasEvent('input') ? 'input' : 'change');
//          _scope.rootScope.apply();
//        };
//      }));
//  
//       getHoursInputEl() {
//        return element.find('input').eq(0);
//      }
//  
//       getMinutesInputEl() {
//        return element.find('input').eq(1);
//      }
//  
//      it('has initially the correct time & meridian', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        expect(getTimeState(element)).toEqual(['02', '40', 'PM']);
//        expect(getModelState()).toEqual([14, 40]);
//      })));
//  
//      it('updates hours & pads on input change & pads on blur', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        var el = getHoursInputEl();
//  
//        changeInputValueTo(el, 5);
//        expect(getTimeState(element)).toEqual(['5', '40', 'PM']);
//        expect(getModelState()).toEqual([17, 40]);
//  
//        el.blur();
//        expect(getTimeState(element)).toEqual(['05', '40', 'PM']);
//        expect(getModelState()).toEqual([17, 40]);
//      })));
//  
//      it('updates minutes & pads on input change & pads on blur', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        var el = getMinutesInputEl();
//  
//        changeInputValueTo(el, 9);
//        expect(getTimeState(element)).toEqual(['02', '9', 'PM']);
//        expect(getModelState()).toEqual([14, 9]);
//  
//        el.blur();
//        expect(getTimeState(element)).toEqual(['02', '09', 'PM']);
//        expect(getModelState()).toEqual([14, 9]);
//      })));
//  
//      it('clears model when input hours is invalid & alerts the UI', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        var el = getHoursInputEl();
//  
//        changeInputValueTo(el, 'pizza');
//        expect(_scope.context['time']).toBe(null);
//        expect(el.parent().hasClass('has-error')).toBe(true);
//        expect(element.hasClass('ng-invalid-time')).toBe(true);
//  
//        changeInputValueTo(el, 8);
//        el.blur();
//        _scope.rootScope.apply();
//        expect(getTimeState(element)).toEqual(['08', '40', 'PM']);
//        expect(getModelState()).toEqual([20, 40]);
//        expect(el.parent().hasClass('has-error')).toBe(false);
//        expect(element.hasClass('ng-invalid-time')).toBe(false);
//      })));
//  
//      it('clears model when input minutes is invalid & alerts the UI', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        var el = getMinutesInputEl();
//  
//        changeInputValueTo(el, 'pizza');
//        expect(_scope.context['time']).toBe(null);
//        expect(el.parent().hasClass('has-error')).toBe(true);
//        expect(element.hasClass('ng-invalid-time')).toBe(true);
//  
//        changeInputValueTo(el, 22);
//        expect(getTimeState(element)).toEqual(['02', '22', 'PM']);
//        expect(getModelState()).toEqual([14, 22]);
//        expect(el.parent().hasClass('has-error')).toBe(false);
//        expect(element.hasClass('ng-invalid-time')).toBe(false);
//      })));
//  
//      it('handles 12/24H mode change', async(inject(() {
//        _scope.context['meridian'] = true;
////        element = $compile('<timepicker ng-model="time" show-meridian="meridian"></timepicker>')($rootScope);
//        dom.Element element = _.compile('<timepicker ng-model="time" meridians="meridiansArray"></timepicker>', scope:_scope);
//
//        microLeap();
//        _scope.rootScope.apply();
//  
//        var el = getHoursInputEl();
//  
//        changeInputValueTo(el, '16');
//        expect(_scope.context['time']).toBe(null);
//        expect(el.parent().hasClass('has-error')).toBe(true);
//        expect(element.hasClass('ng-invalid-time')).toBe(true);
//  
//        _scope.context['meridian'] = false;
//        _scope.rootScope.apply();
//        expect(getTimeState(element, true)).toEqual(['16', '40']);
//        expect(getModelState()).toEqual([16, 40]);
//        expect(element.hasClass('ng-invalid-time')).toBe(false);
//      })));
//    });
  
//    describe('when model is not a Date', () {
////      beforeEach(inject(() {
////        eelement = $compile('<timepicker ng-model="time"></timepicker>')($rootScope);
////      }));
//      
//      dom.Element createTimepicker() {
//        _scope.context['meridiansArray'] = ['am', 'pm'];
//        dom.Element element = _.compile('<timepicker ng-model="time"></timepicker>', scope:_scope);
//
//        microLeap();
//        _scope.rootScope.apply();
//        
//        return element;
//      }
//  
//      it('should not be invalid when the model is null', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        _scope.context['time'] = null;
//        _scope.rootScope.apply();
//        expect(element.hasClass('ng-invalid-time')).toBe(false);
//      })));
//  
//      it('should not be invalid when the model is undefined', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        _scope.context['time'] = undefined;
//        _scope.rootScope.apply();
//        expect(element.hasClass('ng-invalid-time')).toBe(false);
//      })));
//  
//      it('should not be invalid when the model is a valid string date representation', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        _scope.context['time'] = 'September 30, 2010 15:30:00';
//        _scope.rootScope.apply();
//        expect(element.hasClass('ng-invalid-time')).toBe(false);
//        expect(getTimeState(element)).toEqual(['03', '30', 'PM']);
//      })));
//  
//      it('should be invalid when the model is not a valid string date representation', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        _scope.context['time'] = 'pizza';
//        _scope.rootScope.apply();
//        expect(element.hasClass('ng-invalid-time')).toBe(true);
//      })));
//  
//      it('should return valid when the model becomes valid', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        _scope.context['time'] = 'pizza';
//        _scope.rootScope.apply();
//        expect(element.hasClass('ng-invalid-time')).toBe(true);
//  
//        _scope.context['time'] = new Date();
//        _scope.rootScope.apply();
//        expect(element.hasClass('ng-invalid-time')).toBe(false);
//      })));
//  
//      it('should return valid when the model is cleared', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        _scope.context['time'] = 'pizza';
//        _scope.rootScope.apply();
//        expect(element.hasClass('ng-invalid-time')).toBe(true);
//  
//        _scope.context['time'] = null;
//        _scope.rootScope.apply();
//        expect(element.hasClass('ng-invalid-time')).toBe(false);
//      })));
//    });
  
//    describe('use with `ng-required` directive', () {
////      beforeEach(inject(() {
////        _scope.context['time'] = null;
////        element = $compile('<timepicker ng-model="time" ng-required="true"></timepicker>')($rootScope);
////        _scope.rootScope.apply();
////      }));
//      
//      dom.Element createTimepicker() {
//        _scope.context['time'] = null;
//        dom.Element element = _.compile('<timepicker ng-model="time" ng-required="true"></timepicker>', scope:_scope);
//  
//        microLeap();
//        _scope.rootScope.apply();
//        
//        return element;
//      }
//  
//      it('should be invalid initially', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        expect(element.hasClass('ng-invalid')).toBe(true);
//      })));
//  
//      it('should be valid if model has been specified', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        _scope.context['time'] = new Date();
//        _scope.rootScope.apply();
//        expect(element.hasClass('ng-invalid')).toBe(false);
//      })));
//    });
  
//    describe('use with `ng-change` directive', () {
////      beforeEach(inject(() {
////        _scope.context['changeHandler'] = jasmine.createSpy('changeHandler');
////        _scope.context['time'] = new Date();
////        element = $compile('<timepicker ng-model="time" ng-change="changeHandler()"></timepicker>')($rootScope);
////        _scope.rootScope.apply();
////      }));
//      
//      dom.Element createTimepicker() {
//        _scope.context['changeHandler'] = jasmine.createSpy('changeHandler');
//       _scope.context['time'] = new Date();
//        dom.Element element = _.compile('<timepicker ng-model="time" ng-change="changeHandler()"></timepicker>', scope:_scope);
//  
//        microLeap();
//        _scope.rootScope.apply();
//        
//        return element;
//      }
//  
//      it('should not be called initially', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        expect(_scope.context['changeHandler']).not.toHaveBeenCalled();
//      })));
//  
//      it('should be called when hours / minutes buttons clicked', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        var btn1 = getHoursButton(element, true);
//        var btn2 = getMinutesButton(element, false);
//  
//        doClick(btn1, 2);
//        doClick(btn2, 3);
//        _scope.rootScope.apply();
//        expect(_scope.context['changeHandler'].callCount).toBe(5);
//      })));
//  
//      it('should not be called when model changes programatically', async(inject(() {
//        dom.Element element = createTimepicker();
//        
//        _scope.context['time'] = new Date();
//        _scope.rootScope.apply();
//        expect(_scope.context['changeHandler']).not.toHaveBeenCalled();
//      })));
//    });
  });
}