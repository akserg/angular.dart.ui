// Copyright (C) 2013 - 2016 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular_ui_test;

testContentAppendComponent() {
  describe("[ContentAppendComponent]", () {
    TestBed _;
    Scope scope;
        
    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    beforeEach(() {
      module((Module _) => _
        ..install(new ContentAppendModule())
      );
    });
    
    String getHtml() {
      return '<content-append node="node"></content-append>';
    };

    it('It should ignore null values', compileComponent(
        getHtml(), 
        {'node': null}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      expect(shadowRoot.children[0].childNodes.length).toBe(0);
    }));
    
    it('It should append a String', compileComponent(
        getHtml(), 
        {'node': 'Hello'}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      scope.context['node'] = 'Hello';
      expect(shadowRoot.children[0].childNodes.length).toBe(1);
      expect(shadowRoot.children[0].text).toEqual('Hello');
    }));
    
    it('It should append an Element', compileComponent(
        getHtml(), 
        {'node': new dom.Element.html("<div id='inner'>HelloFromInner</div>")}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      expect(shadowRoot.children[0].children.length).toBe(1);
      expect(shadowRoot.querySelector('#inner').text).toEqual('HelloFromInner');
    }));
  });
}
