// Copyright (c) 2013 - 2014, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void positionTests() {

  group('Testing position:', () {
    // Add injector and configure Modules before tests
    setUp(() {
      setUpInjector();
      dom.window.scrollTo(0, 0);
      module((Module m) => m.install(new PositionModule()));
      //
      var qunit_fixture = new dom.DivElement();
      qunit_fixture.id = "qunit_fixture";
      qunit_fixture.style.top = "0px";
      qunit_fixture.style.left = "0px";
      qunit_fixture.style.zIndex = "1";
      dom.document.body.append(qunit_fixture);
      //
      var el1 = new dom.DivElement();
      el1.style.position = "absolute";
      el1.style.width = "6px";
      el1.style.height = "6px";
      el1.style.lineHeight = "6px";
      qunit_fixture.append(el1);
      //
      var el2 = new dom.DivElement();
      el2.style.position = "absolute";
      el2.style.width = "6px";
      el2.style.height = "6px";
      el2.style.lineHeight = "6px";
      qunit_fixture.append(el2);
      //
      var parent = new dom.DivElement();
      parent.style.position = "absolute";
      parent.style.width = "6px";
      parent.style.height = "6px";
      parent.style.top = "4px";
      parent.style.left = "4px";
      parent.style.lineHeight = "6px";
      qunit_fixture.append(parent);
      //
      var within = new dom.DivElement();
      within.style.position = "absolute";
      within.style.width = "12px";
      within.style.height = "12px";
      within.style.top = "2px";
      within.style.left = "0px";
      within.style.lineHeight = "12px";
      qunit_fixture.append(within);
      //
      var scrollx = new dom.DivElement();
      scrollx.style.top = "0px";
      scrollx.style.left = "0px";
      qunit_fixture.append(scrollx);
      //
      var elx = new dom.DivElement();
      elx.id = "elx";
      elx.style.position = "absolute";
      elx.style.width = "10px";
      elx.style.height = "10px";
      elx.style.lineHeight = "10px";
      scrollx.append(elx);
      //
      var parentx = new dom.DivElement();
      parentx.style.position = "absolute";
      parentx.style.width = "20px";
      parentx.style.height = "20px";
      parentx.style.top = "40px";
      parentx.style.left = "40px";
      scrollx.append(parentx);
      //
      var anonim = new dom.DivElement();
      anonim.style.position = "absolute";
      anonim.style.width = "5000px";
      anonim.style.height = "5000px";
      qunit_fixture.append(anonim);
      //
      var fractions_parent = new dom.DivElement();
      fractions_parent.style.position = "absolute";
      fractions_parent.style.left = "10.7432222px";
      fractions_parent.style.top = "10.532325px";
      fractions_parent.style.height = "30px";
      fractions_parent.style.width = "201px";
      qunit_fixture.append(fractions_parent);
      //
      var fractions_element = new dom.DivElement();
      fractions_parent.append(fractions_element);
    });
    
    // Remove injector after tests
    tearDown(tearDownInjector);
    
    /**
     * Test load Position
     */
    test('should load position', inject((Position position) {
      expect(position, isNot(isEmpty));
//      expect(position.document, isNotNull);
//      expect(position.window, isNotNull);
    }));
    
    /**
     * Test Div Offset
     */
    test('check div inside other div offset value', inject((Position position) {
      var elx = dom.querySelector("#elx");
      expect(elx, isNotNull);
      var of = position.offset(elx);
      expect(of.top, 14);
      expect(of.left, 8);
    }));
    
    test('check div inside other div position value', inject((Position position) {
      var elx = dom.querySelector("#elx");
      expect(elx, isNotNull);
      var of = position.position(elx);
      expect(of.top, 0);
      expect(of.left, 0);
      expect(of.width, 10);
      expect(of.height, 10);
    }));
    
  });
}