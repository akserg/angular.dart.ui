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
    
    beforeEach(setUpInjector);
    beforeEach(module((Module module) {
      module.install(new AlertModule());
    }));
    beforeEach(inject((TestBed tb) => _ = tb));
    beforeEach(inject((Scope s) => scope = s));
    beforeEach(inject((TemplateCache c) => cache = c));
    
    afterEach(tearDownInjector);
    
    List<dom.Element> createAlerts() {
      cache.put('packages/angular_ui/alert/alert.html', new HttpResponse(200, '<div class=\'alert\' ng-class=\'"alert-" + (t.type != null ? t.type : "warning")\'><button type=\'button\' class=\'close\' data-dismiss=\'alert\' ng-hide=\'t.showable\' ng-click=\'t.closeHandler()\'>&times;</button><content/></div>'));
      element = _.compile("<div>" + 
          "<alert ng-repeat='alert in alerts' type='alert.type'" +
            "close='removeAlert(\$index)'>{{alert.msg}}" +
          "</alert>" +
        "</div>");
      scope.alerts = [
        { 'msg':'foo', 'type':'success'},
        { 'msg':'bar', 'type':'error'},
        { 'msg':'baz'}
      ];
      scope.$digest();
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

      for (var i = 0, n = alerts.length; i < n; i++) {
        expect(findContent(i).text).toEqual(scope.alerts[i]['msg']);
      }
    });
  });
}