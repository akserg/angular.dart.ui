// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void accordionTests() {

  describe('Accordion', () {
    
    TestBed _;
    Scope scope;
    dom.Element element;
    
    beforeEach(setUpInjector);
    beforeEach(module((Module module) {
      module.install(new AlertModule());
    }));
    beforeEach(inject((TestBed tb) => _ = tb));
    beforeEach(inject((Scope s) => scope = s));
    
    afterEach(tearDownInjector);
  
    group('Controller', () {
        AccordionComponent ctrl;
        AccordionGroupComponent group1, group2, group3;
        
        void createElements(AccordionConfig config) {
          ctrl = new AccordionComponent( scope, config );
          group1 = new AccordionGroupComponent( scope.createChild(new PrototypeMap(scope.context)), ctrl);
          group1.isOpen = true;
          group2 = new AccordionGroupComponent(scope.createChild(new PrototypeMap(scope.context)), ctrl);
          group2.isOpen = true;
          group3 = new AccordionGroupComponent(scope.createChild(new PrototypeMap(scope.context)), ctrl);
          group3.isOpen = true;
        };
        
        it('adds a the specified panel to the collection', async(inject(() {
          createElements(new AccordionConfig());
          expect(ctrl.groups.length).toBe(3);
          expect(ctrl.groups[0]).toBe(group1);
          expect(ctrl.groups[1]).toBe(group2);
          expect(ctrl.groups[2]).toBe(group3);
          group2.detach();
          expect(ctrl.groups.length).toBe(2);
          expect(ctrl.groups[0]).toBe(group1);
          expect(ctrl.groups[1]).toBe(group3);
        })));
        
        it('should close other panels if close-others attribute is not defined', async(inject(() {
          createElements(new AccordionConfig());
          group2.isOpen = true;
          expect(group1.isOpen).toBe(false);
          expect(group2.isOpen).toBe(true);
          expect(group3.isOpen).toBe(false);
        })));

        
        it('should close other panels if close-others attribute is true', async(inject(() {
          AccordionConfig config = new AccordionConfig();
          config.closeOthers = true;
          createElements(config);
          group3.isOpen = true;
          expect(group1.isOpen).toBe(false);
          expect(group2.isOpen).toBe(false);
          expect(group3.isOpen).toBe(true);
        })));

        
        it('should not close other panels if close-others attribute is false', async(inject(() {
          AccordionConfig config = new AccordionConfig();
          config.closeOthers = false;
          createElements(config);
          
          group1.isOpen = true;
          group2.isOpen = true;
          group3.isOpen = true;
          expect(group1.isOpen).toBe(true);
          expect(group2.isOpen).toBe(true);
          expect(group3.isOpen).toBe(true);
        })));

    });
    
  });
}


