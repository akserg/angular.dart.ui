// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular_ui_test;

testAlertComponent() {
  describe("[AlertComponent]", () {
    TestBed _;
    Scope scope;
        
    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    beforeEach(() {
      module((Module _) => _
        ..install(new AlertModule())
      );
//      return loadTemplates(['/alert/alert.html']);
    });

    String getHtml() {
      return "<alert ng-repeat='alert in alerts' type='alert.type'" +
          "close='removeAlert(\$index)'>{{alert.msg}}" +
        "</alert>";
    };
    
    Map getScopeContent() {
      return {'alerts': [
        { 'msg':'foo', 'type':'success'},
        { 'msg':'bar', 'type':'error'},
        { 'msg':'baz'}
      ]};
    };
    
    it("should generate alerts using ng-repeat", compileComponent(
        getHtml(), 
        getScopeContent(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final alerts = shadowRoot.querySelectorAll('alert');
      expect(alerts.length).toEqual(3);
    }));
    
    it('should show the alert content', compileComponent(
        getHtml(), 
        getScopeContent(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final alerts = shadowRoot.querySelectorAll('alert');

      for (var i = 0; i < alerts.length; i++) {
        dom.Element el = shadowRoot.querySelectorAll('alert')[i];
        expect(el.text).toEqual(scope.context['alerts'][i]['msg']);
      }
    }));
  });
}
