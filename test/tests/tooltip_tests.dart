// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void tooltipTests() {

  
  describe('', () {
    TestBed _;
    Scope scope;
    Timeout timeout;
    dom.Element elmBody, elm;
    
    beforeEach(() {
      setUpInjector();
      module((Module module) {
        module.install(new TimeoutModule());
        module.install(new PositionModule());
        module.install(new TooltipModule());
      });
      inject((TestBed tb, Scope s, Timeout t) {
        _ = tb;
        scope = s;
        timeout = t;
      });
    });
    
    afterEach(tearDownInjector);
    
    compileElement([html = null]) {
      elmBody = _.compile(html != null ? html : '<div><span tooltip="tooltip text" tooltip-animation="false">Selector Text</span></div>');
      
      microLeap();
      scope.apply();
      
      elm = elmBody.tagName == 'SPAN' ? elmBody : ngQuery(elmBody, 'span')[0];
    };
    
    void cleanup() {
      microLeap();
      timeout.flush();
    }
    
    it('should not be open initially', async(inject(() {
      compileElement();
      
      expect(scope.context['tt_isOpen']).toBe(false);
      
      // We can only test *that* the tooltip-popup element wasn't created as the
      // implementation is templated and replaced.
      expect(elmBody.children.length ).toBe(1);
    })));
    
    it('should open on mouseenter', async(inject(() {
      compileElement();
      
      _.triggerEvent(elm, 'mouseenter');
      expect(scope.context['tt_isOpen']).toBe(true);

      // We can only test *that* the tooltip-popup element was created as the
      // implementation is templated and replaced.
      expect(elmBody.children.length).toBe( 2 );
    })));
    
    it('should close on mouseleave', async(inject(() {
      compileElement();
      
      _.triggerEvent(elm, 'mouseenter');
      _.triggerEvent(elm, 'mouseleave');
      expect(scope.context['tt_isOpen']).toBe(false);
      
      cleanup();
    })));
    
    it('should not animate on animation set to false', async(inject(() {
      compileElement();
      
      expect(scope.context['tt_animation']).toBe(false);
    })));
    
    it('should have default placement of "top"', async(inject(() {
      compileElement();
      
      _.triggerEvent(elm, 'mouseenter');
      expect(scope.context['tt_placement']).toEqual('top');
    })));
    
    it('should allow specification of placement', async(inject(() {
      compileElement('<span tooltip="tooltip text" tooltip-placement="bottom">Selector Text</span>');

      _.triggerEvent(elm, 'mouseenter');
      expect(scope.context['tt_placement']).toEqual('bottom');
    })));
    
    it('should work inside an ngRepeat', async(inject(() {

      scope.context['items'] = [
        { 'name': 'One', 'tooltip': 'First Tooltip' }
      ];
      elmBody = _.compile('''
<ul>
  <li ng-repeat="item in items">
    <span tooltip="{{item.tooltip}}">{{item.name}}</span>
  </li>
</ul>
'''.trim());
            
      microLeap();
      scope.apply();
      
      dom.SpanElement tt = ngQuery(elmBody, 'li > span')[0]; // angular.element( elm.find('li > span')[0] );
      
      _.triggerEvent(tt, 'mouseenter');

      expect(tt.text).toEqual(scope.context['items'][0]['name']);
      //expect(tt.scope().tt_content ).toBe( scope.items[0].tooltip );

      _.triggerEvent(tt, 'mouseleave');
    })));
    
//    it('should only have an isolate scope on the popup', async(inject(() {
//      var ttScope;
//
//      scope.tooltipMsg = 'Tooltip Text';
//      scope.alt = 'Alt Message';
//
//      elmBody = $compile( angular.element( 
//        '<div><span alt={{alt}} tooltip="{{tooltipMsg}}" tooltip-animation="false">Selector Text</span></div>'
//      ) )( scope );
//
//      $compile( elmBody )( scope );
//      scope.$digest();
//      elm = elmBody.find( 'span' );
//      elmScope = elm.scope();
//      
//      elm.trigger( 'mouseenter' );
//      expect( elm.attr( 'alt' ) ).toBe( scope.alt );
//
//      ttScope = angular.element( elmBody.children()[1] ).isolateScope();
//      expect( ttScope.placement ).toBe( 'top' );
//      expect( ttScope.content ).toBe( scope.tooltipMsg );
//
//      elm.trigger( 'mouseleave' );
//
//      //Isolate scope contents should be the same after hiding and showing again (issue 1191)
//      elm.trigger( 'mouseenter' );
//
//      ttScope = angular.element( elmBody.children()[1] ).isolateScope();
//      expect( ttScope.placement ).toBe( 'top' );
//      expect( ttScope.content ).toBe( scope.tooltipMsg );
//    })));
    
    it('should not show tooltips if there is nothing to show', async(inject(() {
      compileElement('<div><span tooltip="">Selector Text</span></div>');

      _.triggerEvent(elm, 'mouseenter');

      expect(elmBody.children.length).toBe(1);
    })));
    
//    it( 'should close the tooltip when its trigger element is destroyed', async(inject(() {
//      compileElement();
//      
//      _.triggerEvent(elm, 'mouseenter');
//      expect(scope.context['tt_isOpen']).toBe(true);
//
//      elm.remove();
//      // Stypid Rootscope has empty destroy method.
//      scope.destroy();
//      expect(elmBody.children.length).toBe(0);
//    })));
    
//    it('isolate scope on the popup should always be child of correct element scope', async(inject(() {
//      compileElement();
//      
//      var ttScope;
//      _.triggerEvent(elm, 'mouseenter');
//
//      ttScope = angular.element( elmBody.children()[1] ).isolateScope();
//      expect( ttScope.$parent ).toBe( elmScope );
//
//      elm.trigger( 'mouseleave' );
//
//      // After leaving and coming back, the scope's parent should be the same
//      elm.trigger( 'mouseenter' );
//
//      ttScope = angular.element( elmBody.children()[1] ).isolateScope();
//      expect( ttScope.$parent ).toBe( elmScope );
//
//      elm.trigger( 'mouseleave' );
//    })));
    
    describe('with specified enable expression', () {
      compileElement(value) {
        scope.context['enable'] = value;
        elmBody = _.compile('<div><span tooltip="tooltip text" tooltip-enable="enable">Selector Text</span></div>');
        
        microLeap();
        scope.apply();
        
        elm = elmBody.tagName == 'SPAN' ? elmBody : ngQuery(elmBody, 'span')[0];
      };
          
      it('should not open ', async(inject(() {
        compileElement(false);

        _.triggerEvent(elm, 'mouseenter');
        expect(scope.context['tt_isOpen']).toBeFalsy();
        expect(elmBody.children.length).toBe(1);
      })));
      
      it('should open', async(inject(() {
        compileElement(true);

        _.triggerEvent(elm, 'mouseenter');
        expect(scope.context['tt_isOpen']).toBeTruthy();
        expect(elmBody.children.length).toBe(2);
      })));
    });
    
    describe('with specified popup delay', () {
      compileElement([delay = 1000]) {
        scope.context['delay'] = delay;
        elmBody = _.compile('<span tooltip="tooltip text" tooltip-popup-delay="delay">Selector Text</span>');
        
        microLeap();
        scope.apply();
        
        elm = elmBody.tagName == 'SPAN' ? elmBody : ngQuery(elmBody, 'span')[0];
      };
      
      it('should open after timeout', async(inject(() {
        compileElement();

        _.triggerEvent(elm, 'mouseenter');
        expect(scope.context['tt_isOpen']).toBe(false);

        timeout.flush();
        expect(scope.context['tt_isOpen']).toBe(true);

      })));
      
      it('should not open if mouseleave before timeout', async(inject(() {
        compileElement();
        
        _.triggerEvent(elm, 'mouseenter');
        expect(scope.context['tt_isOpen']).toBe(false);

        _.triggerEvent(elm, 'mouseleave');
        timeout.flush();
        expect(scope.context['tt_isOpen']).toBe(false);
      })));
      
      it('should use default popup delay if specified delay is not a number', async(inject(() {
        compileElement('text1000');
        
        _.triggerEvent(elm, 'mouseenter');
        expect(scope.context['tt_isOpen']).toBe(true);
      })));
    });
    
    describe( 'with a trigger attribute', () {
      compileElement(String html) {
        elmBody = _.compile(html.trim());
        
        microLeap();
        scope.apply();
        
        elm = elmBody.tagName == 'INPUT' ? elmBody : ngQuery(elmBody, 'input')[0];
      };
            
      it( 'should use it to show but set the hide trigger based on the map for mapped triggers', async(inject(() {

        compileElement('<div><input tooltip="Hello!" tooltip-trigger="focus" /></div>');
        
        expect(scope.context['tt_isOpen']).toBeFalsy();
        
        _.triggerEvent(elm, 'focus', 'FocusEvent');
        expect(scope.context['tt_isOpen']).toBeTruthy();
        
        _.triggerEvent(elm, 'blur', 'FocusEvent');
        expect(scope.context['tt_isOpen']).toBeFalsy();
      })));
      
      it( 'should use it as both the show and hide triggers for unmapped triggers', async(inject(() {
        compileElement('<div><input tooltip="Hello!" tooltip-trigger="fakeTriggerAttr" /></div>');

        expect(scope.context['tt_isOpen']).toBeFalsy();
        _.triggerEvent(elm, 'fakeTriggerAttr', 'Event');
        expect(scope.context['tt_isOpen']).toBeTruthy();
        _.triggerEvent(elm, 'fakeTriggerAttr', 'Event');
        expect(scope.context['tt_isOpen']).toBeFalsy();
      })));
      
      it('should not share triggers among different element instances', async(inject(() {

        elmBody = _.compile('''
<div>
  <input tooltip="Hello!" tooltip-trigger="click" />
  <input tooltip="Hello!" tooltip-trigger="click" />
</div>
'''.trim());
                  
        microLeap();
        scope.apply();
        
        elm = elmBody.querySelectorAll('input')[1];

        _.triggerEvent(elm, 'click');
        expect(scope.context['tt_isOpen']).toBeTruthy();
      })));
    });
    
    describe( 'with an append-to-body attribute', () {
      it( 'should append to the body', async(inject(() {
        elmBody = _.compile('<div><span tooltip="tooltip text" tooltip-append-to-body="true">Selector Text</span></div>');
                
        microLeap();
        scope.apply();
        
        elm = elmBody.firstChild;
                
        var bodyLength = dom.document.body.children.length;
        _.triggerEvent(elm, 'mouseenter');
        
        expect(scope.context['tt_isOpen']).toBe(true);
        expect(elmBody.children.length ).toBe(1);
        expect(dom.document.body.children.length).toEqual(bodyLength + 1);
      })));
    });
    
//    describe('cleanup', () {
//      
//    });
  });
}