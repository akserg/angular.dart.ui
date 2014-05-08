// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void gridTests() {

  
  describe('', () {
    TestBed _;
    Scope scope;
//    Timeout timeout;
//    dom.Element elmBody, elm;
    
    beforeEach(() {
      setUpInjector();
      module((Module module) {
        module.install(new TimeoutModule());
        module.install(new GridModule());
      });
      inject((TestBed tb, Scope s) { //, Timeout t) {
        _ = tb;
        scope = s;
//        timeout = t;
      });
    });
    
    afterEach(tearDownInjector);
    
//    Scope getElementScope(dom.Element el) {
//      Popover popover = (ngProbe(elm).directives as List).firstWhere((e) => e is Popover);
//      return popover.scope;
//    }
    
    dom.Element compileElement([html = null]) {
      scope.context['myItems'] = [
        {'id':1, 'name':'John'},
        {'id':2, 'name':'Marry'}
      ];
      dom.Element elm = _.compile(html != null ? html : '<table tr-ng-grid="" items="myItems"></table>');
      
      microLeap();
      scope.apply();
      
      return elm;
    };
    
//    void cleanup() {
//      microLeap();
//      timeout.flush();
//    }
    
    it('should be initialised with default classes', async(inject(() {
      dom.Element table = compileElement();
      
      expect(table.classes.contains('tr-ng-grid')).toBeTruthy();
      expect(table.classes.contains('table')).toBeTruthy();
      expect(table.classes.contains('table-bordered')).toBeTruthy();
      expect(table.classes.contains('table-hover')).toBeTruthy();
//      expect(table.classes.contains('ng-isolate-scope')).toBeTruthy();
    })));
    
    it('should have head, footer and body', async(inject(() {
      dom.Element table = compileElement();
      
      expect(table.children.length).toBe(3);
      expect(ngQuery(table, 'thead').length).toBe(1);
      expect(ngQuery(table, 'tfoot').length).toBe(1);
      expect(ngQuery(table, 'tbody').length).toBe(1);
    })));
    
//    it('should have head containes tr-ng-grid-header', async(inject(() {
//      dom.Element table = compileElement();
//      
//      expect(ngQuery(table, '.tr-ng-grid-header').length).toBe(1);
//    })));
    
  });
}