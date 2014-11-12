// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular_ui_test;

testTooltipComponent() {
  describe("[TooltipComponent]", () {
    TestBed _;
    Scope scope;
    Timeout timeout;
        
    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    beforeEach(() {
      module((Module _) => _
        ..install(new TooltipModule())
      );
      inject((TestBed tb) { _ = tb; });
      inject((Timeout t) { timeout = t; });
    });

    String getHtml() {
      return '<span tooltip="tooltip text" tooltip-animation="false">Selector Text</span>';
    };
    
    Tooltip getTooltip(dom.Element elm) {
      return ngProbe(elm).directives.firstWhere((e) => e is Tooltip);
    }
    
    it('should not be open initially', compileComponent(
        getHtml(), 
        {}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var elm = shadowRoot.querySelector('span');
      var tooltip = getTooltip(elm);
      expect(tooltip.tt_isOpen).toBe(false);
      
      // We can only test *that* the tooltip-popup element wasn't created as the
      // implementation is templated and replaced.
      expect(shadowRoot.children.length ).toBe(1);
    }));
    
    it('should open on mouseenter', compileComponent(
        getHtml(), 
        {}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var elm = shadowRoot.querySelector('span');
      var tooltip = getTooltip(elm);
      
      _.triggerEvent(elm, 'mouseenter');
      expect(tooltip.tt_isOpen).toBe(true);
      
      // We can only test *that* the tooltip-popup element was created as the
      // implementation is templated and replaced.
      expect(shadowRoot.children.length).toBe( 2 );
    }));
    
    it('should close on mouseleave', compileComponent(
        getHtml(), 
        {}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var elm = shadowRoot.querySelector('span');
      var tooltip = getTooltip(elm);
      
      _.triggerEvent(elm, 'mouseenter');
      _.triggerEvent(elm, 'mouseleave');
      expect(tooltip.tt_isOpen).toBe(false);
    }));
    
    it('should not animate on animation set to false', compileComponent(
        getHtml(), 
        {}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var elm = shadowRoot.querySelector('span');
      var tooltip = getTooltip(elm);
      
      expect(tooltip.tt_animation).toBe(false);
    }));
    
    it('should have default placement of "top"', compileComponent(
        getHtml(), 
        {}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var elm = shadowRoot.querySelector('span');
      var tooltip = getTooltip(elm);
      
      _.triggerEvent(elm, 'mouseenter');
      expect(tooltip.tt_placement).toEqual('top');
    }));
    
    it('should allow specification of placement', compileComponent(
        '<span tooltip="tooltip text" tooltip-placement="bottom">Selector Text</span>', 
        {}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var elm = shadowRoot.querySelector('span');
      var tooltip = getTooltip(elm);

      _.triggerEvent(elm, 'mouseenter');
      expect(tooltip.tt_placement).toEqual('bottom');
    }));
    
    it('should work inside an ngRepeat', compileComponent(
        '<ul><li ng-repeat="item in items"><span tooltip="{{item.tooltip}}">{{item.name}}</span></li></ul>', 
        {'items':[{ 'name': 'One', 'tooltip': 'First Tooltip' }]}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var elm = shadowRoot.querySelector('ul');
      
      dom.SpanElement tt = ngQuery(elm, 'li > span')[0];
      _.triggerEvent(tt, 'mouseenter');
      expect(tt.text).toEqual(scope.context['items'][0]['name']);
    }));
    
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

    it('should not show tooltips if there is nothing to show', compileComponent(
        '<div><span tooltip="">Selector Text</span></div>', 
        {}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var elm = shadowRoot.querySelector('span');

      _.triggerEvent(elm, 'mouseenter');

      expect(shadowRoot.children.length).toBe(1);
    }));
    
//    it( 'should close the tooltip when its trigger element is destroyed', async(inject(() {
//      Scope scope = compileElement();
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
//      Scope scope = compileElement();
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
          
      it('should not open ', compileComponent(
          '<span tooltip="tooltip text" tooltip-enable="false">Selector Text</span>', 
          {}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var elm = shadowRoot.querySelector('span');
        var tooltip = getTooltip(elm);
      
        _.triggerEvent(elm, 'mouseenter');
        expect(tooltip.tt_isOpen).toBeFalsy();
        expect(shadowRoot.children.length).toBe(1);
      }));
      
      it('should open', compileComponent(
          '<span tooltip="tooltip text" tooltip-enable="true">Selector Text</span>', 
          {}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var elm = shadowRoot.querySelector('span');
        var tooltip = getTooltip(elm);
      
        _.triggerEvent(elm, 'mouseenter');
        digest();
        expect(tooltip.tt_isOpen).toBeTruthy();
        expect(shadowRoot.children.length).toBe(2);
      }));
    });
    
    describe('with specified popup delay', () {
      
      it('should open after timeout', compileComponent(
          '<span tooltip="tooltip text" tooltip-popup-delay="1000">Selector Text</span>', 
          {}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var elm = shadowRoot.querySelector('span');
        var tooltip = getTooltip(elm);

        _.triggerEvent(elm, 'mouseenter');
        expect(tooltip.tt_isOpen).toBe(false);

        timeout.flush();
        expect(tooltip.tt_isOpen).toBe(true);

      }));
      
      it('should not open if mouseleave before timeout', compileComponent(
          '<span tooltip="tooltip text" tooltip-popup-delay="1000">Selector Text</span>', 
          {}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var elm = shadowRoot.querySelector('span');
        var tooltip = getTooltip(elm);
        
        _.triggerEvent(elm, 'mouseenter');
        expect(tooltip.tt_isOpen).toBe(false);

        _.triggerEvent(elm, 'mouseleave');
        timeout.flush();
        expect(tooltip.tt_isOpen).toBe(false);
      }));
      
      it('should use default popup delay if specified delay is not a number', compileComponent(
          '<span tooltip="tooltip text" tooltip-popup-delay="\'text1000\'">Selector Text</span>', 
          {}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var elm = shadowRoot.querySelector('span');
        var tooltip = getTooltip(elm);
        
        _.triggerEvent(elm, 'mouseenter');
        expect(tooltip.tt_isOpen).toBe(true);
      }));
    });
    
    describe( 'with a trigger attribute', () {
      it( 'should use it to show but set the hide trigger based on the map for mapped triggers', compileComponent(
          '<input tooltip="Hello!" tooltip-trigger="focus" />', 
          {}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var elm = shadowRoot.querySelector('input');
        var tooltip = getTooltip(elm);

        expect(tooltip.tt_isOpen).toBeFalsy();
        
        _.triggerEvent(elm, 'focus', 'FocusEvent');
        expect(tooltip.tt_isOpen).toBeTruthy();
        
        _.triggerEvent(elm, 'blur', 'FocusEvent');
        expect(tooltip.tt_isOpen).toBeFalsy();
      }));
      
      it( 'should use it as both the show and hide triggers for unmapped triggers', compileComponent(
          '<input tooltip="Hello!" tooltip-trigger="fakeTriggerAttr" />', 
          {}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var elm = shadowRoot.querySelector('input');
        var tooltip = getTooltip(elm);

        expect(tooltip.tt_isOpen).toBeFalsy();
        _.triggerEvent(elm, 'fakeTriggerAttr', 'Event');
        expect(tooltip.tt_isOpen).toBeTruthy();
        _.triggerEvent(elm, 'fakeTriggerAttr', 'Event');
        expect(tooltip.tt_isOpen).toBeFalsy();
      }));
      
      it('should not share triggers among different element instances', compileComponent(
          '<input tooltip="Hello!" tooltip-trigger="click" /><input tooltip="Hello!" tooltip-trigger="click" />', 
          {}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var elms = shadowRoot.querySelectorAll('input');
        expect(elms.length).toEqual(2);
        
        var tooltip0 = getTooltip(elms[0]);
        var tooltip1 = getTooltip(elms[1]);

        _.triggerEvent(elms[1], 'click');
        expect(tooltip0.tt_isOpen).toBeFalsy();
        expect(tooltip1.tt_isOpen).toBeTruthy();
      }));
    });
    
    describe( 'with an append-to-body attribute', () {
      it( 'should append to the body', compileComponent(
          '<span tooltip="tooltip text" tooltip-append-to-body="true">Selector Text</span>', 
          {}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var elm = shadowRoot.firstChild;
        var tooltip = getTooltip(elm);
                
        var bodyLength = dom.document.body.children.length;
        _.triggerEvent(elm, 'mouseenter');
        
        expect(tooltip.tt_isOpen).toBe(true);
        expect(shadowRoot.children.length ).toBe(1);
        expect(dom.document.body.children.length).toEqual(bodyLength + 1);
      }));
    });
        
//    describe('cleanup', () {
//      
//    });
  });
}
