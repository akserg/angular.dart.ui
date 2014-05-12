// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void gridTests() {

  
  describe('', () {
    TestBed _;
    Scope scope;
    
    beforeEach(() {
      setUpInjector();
      module((Module module) {
        module.install(new TimeoutModule());
        module.install(new GridModule());
      });
      inject((TestBed tb, Scope s) {
        _ = tb;
        scope = s;
      });
    });
    
    afterEach(tearDownInjector);
    
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
    
    it('should be initialised with default classes', async(inject(() {
      dom.Element table = compileElement();
      
      expect(table.classes.contains('tr-ng-grid')).toBeTruthy();
      expect(table.classes.contains('table')).toBeTruthy();
      expect(table.classes.contains('table-hover')).toBeTruthy();
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