// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular_ui_test;

testPopoverComponent() {
  describe("[PopoverComponent]", () {
    TestBed _;
    Scope scope;
    Timeout timeout;
        
    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    beforeEach(() {
      module((Module _) => _
        ..install(new TimeoutModule())
        ..install(new PositionModule())
        ..install(new PopoverModule())
      );
      inject((TestBed tb) { _ = tb; });
      inject((Timeout t) { timeout = t; });
    });

    String getHtml() {
      return '<span popover="popover text">Selector Text</span>';
    };
    
    Popover getPopover(dom.Element elm) {
      return ngProbe(elm).directives.firstWhere((e) => e is Popover);
    }
    
    it('should not be open initially', compileComponent(
        getHtml(), 
        {}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var elm = shadowRoot.querySelector('span');
      var popover = getPopover(elm);
      
      expect(popover.tt_isOpen).toBe(false);
      
      // We can only test *that* the popover-popup element wasn't created as the
      // implementation is templated and replaced.
      expect(shadowRoot.children.length ).toBe(1);
    }));

    it('should open on click', compileComponent(
        getHtml(), 
        {}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var elm = shadowRoot.querySelector('span');
      var popover = getPopover(elm);
            
      _.triggerEvent(elm, 'click');
      expect(popover.tt_isOpen).toBe(true);

      // We can only test *that* the tooltip-popup element was created as the
      // implementation is templated and replaced.
      expect(shadowRoot.children.length).toBe( 2 );
    }));
    
    it('should close on second click', compileComponent(
        getHtml(), 
        {}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var elm = shadowRoot.querySelector('span');
      var popover = getPopover(elm);
      
      _.triggerEvent(elm, 'click');
      _.triggerEvent(elm, 'click');
      expect(popover.tt_isOpen).toBe(false);
    }));
  });
}
