// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular_ui_test;

testDropdownComponent() {
  describe("[DropdownComponent]", () {
    TestBed _;
    Scope scope;
        
    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    beforeEach(() {
      module((Module _) => _
        ..install(new DropdownToggleModule())
      );
      //return loadTemplates(['/alert/alert.html']);
    });

    String getHtml() {
      return '<li class="dropdown"><a dropdown-toggle></a><ul dropdown-toggle><li>Hello</li></ul></li>';
    };
    
    it('should toggle on `a` click', compileComponent(
        getHtml(), 
        {}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var elm = shadowRoot.querySelector('.dropdown');
      expect(elm.classes.contains('open')).toBe(false);
      elm.querySelector('a').click();
      expect(elm.classes.contains('open')).toBe(true);
      elm.querySelector('a').click();
      expect(elm.classes.contains('open')).toBe(false);
    }));

    it('should toggle on `ul` click', compileComponent(
        getHtml(), 
        {}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var elm = shadowRoot.querySelector('.dropdown');
      expect(elm.classes.contains('open')).toBe(false);
      elm.querySelector('ul').click();
      expect(elm.classes.contains('open')).toBe(true);
      elm.querySelector('ul').click();
      expect(elm.classes.contains('open')).toBe(false);
    }));
    
    it('should close on elm click', compileComponent(
        getHtml(), 
        {}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var elm = shadowRoot.querySelector('.dropdown');
      elm.querySelector('a').click();
      elm.click();
      expect(elm.classes.contains('open')).toBe(false);
    }));
    
    it('should close on document click', compileComponent(
        getHtml(), 
        {}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var elm = shadowRoot.querySelector('.dropdown');
      elm.querySelector('a').click();
      dom.document.body.click();
      expect(elm.classes.contains('open')).toBe(false);
    }));
    
    it('should only allow one dropdown to be open at once', compileComponent(
        '''<li class="dropdown"><a dropdown-toggle></a><ul dropdown-toggle><li>Hello</li></ul></li><li class="dropdown">
<a dropdown-toggle></a><ul dropdown-toggle><li>Hello</li></ul></li>''', 
        {}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var elms = shadowRoot.querySelectorAll('.dropdown');
      var elm1 = elms[0];
      var elm2 = elms[1];
      elm1.querySelector('a').click();
      elm2.querySelector('a').click();
      expect(elm1.classes.contains('open')).toBe(false);
      expect(elm2.classes.contains('open')).toBe(true);
    }));
  });
}
