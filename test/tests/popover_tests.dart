// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void popoverTests() {

  
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
        module.install(new PopoverModule());
      });
      inject((TestBed tb, Scope s, Timeout t) {
        _ = tb;
        scope = s;
        timeout = t;
      });
    });
    
    afterEach(tearDownInjector);
    
    Scope getElementScope(dom.Element el) {
      Popover popover = ngProbe(elm).directives.firstWhere((e) => e is Popover);
      return popover.scope;
    }
    
    Scope compileElement([html = null]) {
      elmBody = _.compile(html != null ? html : '<div><span popover="popover text">Selector Text</span></div>');
      
      microLeap();
      scope.apply();
      
      elm = elmBody.tagName == 'SPAN' ? elmBody : ngQuery(elmBody, 'span')[0];
      
      return getElementScope(elm);
    };
    
    void cleanup() {
      microLeap();
      timeout.flush();
    }
    
    it('should not be open initially', async(inject(() {
      Scope scope = compileElement();
      
      expect(scope.context['tt_isOpen']).toBe(false);
      
      // We can only test *that* the tooltip-popup element wasn't created as the
      // implementation is templated and replaced.
      expect(elmBody.children.length ).toBe(1);
    })));
    
    it('should open on click', async(inject(() {
      Scope scope = compileElement();
      
      _.triggerEvent(elm, 'click');
      expect(scope.context['tt_isOpen']).toBe(true);

      // We can only test *that* the tooltip-popup element was created as the
      // implementation is templated and replaced.
      expect(elmBody.children.length).toBe( 2 );
    })));
    
    it('should close on second click', async(inject(() {
      Scope scope = compileElement();
      
      _.triggerEvent(elm, 'click');
      _.triggerEvent(elm, 'click');
      expect(scope.context['tt_isOpen']).toBe(false);
      
      cleanup();
    })));
  });
}