// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular_ui_test;

testTooltipComponent() {
  describe("[TooltipComponent]", () {
    TestBed _;
    Scope scope;
        
    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    beforeEach(() {
      module((Module _) => _
        ..install(new TooltipModule())
      );
      inject((TestBed tb) { _ = tb; });
    });

    String getHtml() {
      return '<span tooltip="tooltip text" tooltip-animation="false">Selector Text</span>';
    };
    
    Scope getElementScope(dom.Element elm) {
      Tooltip tooltip = ngProbe(elm).directives.firstWhere((e) => e is Tooltip);
      return tooltip.scope;
    }
    
    it('should not be open initially', compileComponent(
        getHtml(), 
        {}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var elm = shadowRoot.querySelector('span');
      var elmScope = getElementScope(elm);
      expect(elmScope.context['tt_isOpen']).toBe(false);
      
      // We can only test *that* the tooltip-popup element wasn't created as the
      // implementation is templated and replaced.
      expect(shadowRoot.children.length ).toBe(1);
    }));
    
    it('should open on mouseenter', compileComponent(
        getHtml(), 
        {}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var elm = shadowRoot.querySelector('span');
      var elmScope = getElementScope(elm);
      
      _.triggerEvent(elm, 'mouseenter');
      expect(elmScope.context['tt_isOpen']).toBe(true);
      
      // We can only test *that* the tooltip-popup element was created as the
      // implementation is templated and replaced.
      expect(shadowRoot.children.length).toBe( 2 );
    }));
    
    it('should close on mouseleave', compileComponent(
        getHtml(), 
        {}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var elm = shadowRoot.querySelector('span');
      var elmScope = getElementScope(elm);
      
      _.triggerEvent(elm, 'mouseenter');
      _.triggerEvent(elm, 'mouseleave');
      expect(elmScope.context['tt_isOpen']).toBe(false);
    }));
    
    it('should not animate on animation set to false', compileComponent(
        getHtml(), 
        {}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var elm = shadowRoot.querySelector('span');
      var elmScope = getElementScope(elm);
      
      expect(elmScope.context['tt_animation']).toBe(false);
    }));
    
    it('should have default placement of "top"', compileComponent(
        getHtml(), 
        {}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var elm = shadowRoot.querySelector('span');
      var elmScope = getElementScope(elm);
      
      _.triggerEvent(elm, 'mouseenter');
      expect(elmScope.context['tt_placement']).toEqual('top');
    }));
    
    it('should allow specification of placement', compileComponent(
        '<span tooltip="tooltip text" tooltip-placement="bottom">Selector Text</span>', 
        {}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var elm = shadowRoot.querySelector('span');
      var elmScope = getElementScope(elm);

      _.triggerEvent(elm, 'mouseenter');
      expect(elmScope.context['tt_placement']).toEqual('bottom');
    }));
    
    it('should work inside an ngRepeat', compileComponent(
        '<ul><li ng-repeat="item in items"><span tooltip="{{item.tooltip}}">{{item.name}}</span></li></ul>', 
        {'items':[{ 'name': 'One', 'tooltip': 'First Tooltip' }]}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
          
      print(shadowRoot.outerHtml);
      var elm = shadowRoot.querySelector('ul');
      
      dom.SpanElement tt = ngQuery(elm, 'li > span')[0]; // angular.element( elm.find('li > span')[0] );
      print(tt.outerHtml);
//      
//      _.triggerEvent(tt, 'mouseenter');
//
//      expect(tt.text).toEqual(elmScope.context['items'][0]['name']);
    }));
  });
}
