// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void alertTests() {

  
  describe('Testing alert:', () {
    TestBed _;
    Scope scope;
    dom.Element element;
    TemplateCache cache;

    beforeEach(() {
      setUpInjector();
      module((Module module) {
        module.install(new AlertModule());
      });
      inject((TestBed tb, Scope s, TemplateCache c) {
        _ = tb;
        scope = s;
        cache = c;
        addToTemplateCache(cache, 'packages/angular_ui/alert/alert.html');
      });
    });
    
    afterEach(tearDownInjector);
    
    List<dom.Element> createAlerts() {
      element = _.compile("<div>" + 
          "<alert ng-repeat='alert in alerts' type='alert.type'" +
            "close='removeAlert(\$index)'>{{alert.msg}}" +
          "</alert>" +
        "</div>");
      scope.context['alerts'] = [
        { 'msg':'foo', 'type':'success'},
        { 'msg':'bar', 'type':'error'},
        { 'msg':'baz'}
      ];

      microLeap();
      scope.rootScope.apply();
      
      return element.querySelectorAll('alert');
    };
    
    dom.Element findCloseButton(index) {
      return element.querySelectorAll('.close')[index];
    }
    
    dom.Element findContent(index) {
      return element.querySelectorAll('alert')[index];
    }
    
    it("should generate alerts using ng-repeat", () {
      var alerts = createAlerts();
      expect(alerts.length).toEqual(3);
    });

    it('should show the alert content', () {
      var alerts = createAlerts();

      for (var i = 0; i < alerts.length; i++) {
        dom.Element el = findContent(i);
        expect(el.text).toEqual(scope.context['alerts'][i]['msg']);
      }
    });
  });
}