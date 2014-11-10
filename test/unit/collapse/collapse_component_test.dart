// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular_ui_test;

testCollapseComponent() {
  describe("[CollapseComponent]", () {
    TestBed _;
    Scope scope;
    Timeout timeout;
        
    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    beforeEach(() {
      module((Module _) => _
        ..install(new CollapseModule())
      );
      inject((Timeout t) => timeout = t);
    });

    String getHtml() {
      return '<div collapse="isCollapsed">Some Content</div>';
    };
        
    describe("[Collapse with static content]", () {
      
      it('should be hidden on initialization if isCollapsed = true without transition', compileComponent(
          getHtml(), 
          {'isCollapsed':true}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var collapse = shadowRoot.querySelector('[collapse]');
        //No animation timeout here
        expect(collapse.style.height).toEqual('0px');
      }));
      
      it('should collapse if isCollapsed = true with animation on subsequent use', compileComponent(
          getHtml(), 
          {'isCollapsed':false}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var collapse = shadowRoot.querySelector('[collapse]');
        scope.context['isCollapsed'] = true;
        digest();
        timeout.flush();
        expect(collapse.style.height).toEqual('0px');
      }));
      
      it('should be shown on initialization if isCollapsed = false without transition', compileComponent(
          getHtml(), 
          {'isCollapsed':false}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var collapse = shadowRoot.querySelector('[collapse]');
        //No animation timeout here
        expect(collapse.style.height).not.toEqual('0px');
      }));
      
//      it('should expand if isCollapsed = false with animation on subsequent use', compileComponent(
//          getHtml(), 
//          {'isCollapsed':false}, 
//          (Scope scope, dom.HtmlElement shadowRoot) {
//        var collapse = shadowRoot.querySelector('[collapse]');
//        scope.context['isCollapsed'] = true;
//        digest();
//        scope.context['isCollapsed'] = false;
//        digest();
//        timeout.flush();
//        expect(collapse.style.height).not.toEqual('0px');
//      }));
      
      it('should expand if isCollapsed = true with animation on subsequent uses', compileComponent(
          getHtml(), 
          {'isCollapsed':false}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var collapse = shadowRoot.querySelector('[collapse]');
        scope.context['isCollapsed'] = true;
        digest();
        scope.context['isCollapsed'] = false;
        digest();
        scope.context['isCollapsed'] = true;
        digest();
        timeout.flush();
        expect(collapse.style.height).toEqual('0px');

        Collapse collapseComponent = ngProbe(collapse).directives.firstWhere((d) => d is Collapse);
        collapseComponent.currentTransition.complete(true);
        expect(collapse.style.height).toEqual('0px');
      }));
    });
    
//    describe("[Collapse with dynamic content]", () {
//      it('should grow accordingly when content size inside collapse increases', compileComponent(
//          '<div collapse="isCollapsed"><p>Initial content</p><div ng-hide="hid">Additional content</div></div>', 
//          {'isCollapsed':true, 'hid':true}, 
//          (Scope scope, dom.HtmlElement shadowRoot) {
//        var collapse = shadowRoot.querySelector('[collapse]');
//        Collapse collapseComponent = ngProbe(collapse).directives.firstWhere((d) => d is Collapse);
//        collapseComponent.isCollapsed = false;
//        digest();
//        var collapseHeight = collapse.clientHeight;
//        scope.context['hid'] = false;
//        digest();
//        expect(collapse.clientHeight).toBeGreaterThan(collapseHeight);
//      }));
//      
//      it('should shrink accordingly when content size inside collapse decreases', compileComponent(
//          '<div collapse="isCollapsed"><p>Initial content</p><div ng-hide="hid">Additional content</div></div>', 
//          {'isCollapsed':false, 'hid':false}, 
//          (Scope scope, dom.HtmlElement shadowRoot) {
//        var collapse = shadowRoot.querySelector('[collapse]');
//        var collapseHeight = collapse.clientHeight;
//        scope.context['hid'] = true;
//        digest();
//        expect(collapse.clientHeight).toBeLessThan(collapseHeight);
//      }));
//    });
  });
}
