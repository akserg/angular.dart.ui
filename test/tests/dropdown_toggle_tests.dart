// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
// 
// Credits: Tonis Pool who wrote and donate that code.
//

part of angular.ui.test;

void dropdownToggleTests() {
  describe('Testing dropdownToggle:', () {
    TestBed _;
    beforeEach(() {
      setUpInjector();
      module((Module module) {
        module.bind(DropdownToggle);
      });
      inject((TestBed tb) { 
        _ = tb;
      });
    });

    afterEach(tearDownInjector);

    dom.Element dropdown() {
      return _.compile('<li class="dropdown"><a dropdown-toggle></a><ul dropdown-toggle><li>Hello</li></ul></li>');
    }

    it('should toggle on `a` click', () {
      dom.Element elm = dropdown();
      expect(elm.classes.contains('open')).toBe(false);
      elm.querySelector('a').click();
      expect(elm.classes.contains('open')).toBe(true);
      elm.querySelector('a').click();
      expect(elm.classes.contains('open')).toBe(false);
    });

    it('should toggle on `ul` click', () {
      dom.Element elm = dropdown();
      expect(elm.classes.contains('open')).toBe(false);
      elm.querySelector('ul').click();
      expect(elm.classes.contains('open')).toBe(true);
      elm.querySelector('ul').click();
      expect(elm.classes.contains('open')).toBe(false);
    });

    it('should close on elm click', () {
      dom.Element elm = dropdown();
      elm.querySelector('a').click();
      elm.click();
      expect(elm.classes.contains('open')).toBe(false);
    });

    it('should close on document click', () {
      dom.Element elm = dropdown();
      elm.querySelector('a').click();
      dom.document.body.click();
      expect(elm.classes.contains('open')).toBe(false);
    });

    it('should only allow one dropdown to be open at once', () {
      dom.Element elm1 = dropdown();
      dom.Element elm2 = dropdown();
      elm1.querySelector('a').click();
      elm2.querySelector('a').click();
      expect(elm1.classes.contains('open')).toBe(false);
      expect(elm2.classes.contains('open')).toBe(true);
    });
  });
}