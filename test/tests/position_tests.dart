// Copyright (c) 2013 - 2014, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void positionTests() {

  
  describe('Testing position:', () {

    TestBed _;
    Position position;
  
    beforeEach(setUpInjector);
    beforeEach(module((Module module) {
      module.install(new PositionModule());
    }));
    beforeEach(inject((TestBed tb) => _ = tb));
    beforeEach(inject((Position p) => position = p));

    afterEach(tearDownInjector);
  
    it('test position', () {
      expect(position).toBeNotNull();
    });
  });
}