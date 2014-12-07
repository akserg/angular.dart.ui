// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular_ui_test;

testAccordionComponent() {
  describe("[Accordion Component]", () {
        
    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    beforeEach(() {
      module((Module _) => _
        ..install(new AccordionModule())
      );
      //return loadTemplates(['/accordion/accordion.html', 'accordion/accordion_group.html']);
    });
    
    describe('Accordion', () {
      
      AccordionComponent ctrl;
      AccordionGroupComponent group1, group2, group3;
      
      void createElements(AccordionConfig config) {
        ctrl = new AccordionComponent(config);
        group1 = new AccordionGroupComponent(ctrl)
        ..isOpen = true;
        group2 = new AccordionGroupComponent(ctrl)
        ..isOpen = true;
        group3 = new AccordionGroupComponent(ctrl)
        ..isOpen = true;
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
      
      describe('setting accordionConfig', () {
        var originalCloseOthers;
        beforeEach(inject((AccordionConfig accordionConfig) {
          originalCloseOthers = accordionConfig.closeOthers;
          accordionConfig.closeOthers = false;
        }));
        afterEach(inject((AccordionConfig accordionConfig) {
          // return it to the original value
          accordionConfig.closeOthers = originalCloseOthers;
        }));

        it('should not close other panels if accordionConfig.closeOthers is false', () {
          ctrl.closeOthers(group2);
          expect(group1.isOpen).toBe(true);
          expect(group2.isOpen).toBe(true);
          expect(group3.isOpen).toBe(true);
        });
      });
      
      describe('removeGroup', () {
        it('should remove the specified panel', () {
          ctrl.removeGroup(group2);
          expect(ctrl.groups.length).toBe(2);
          expect(ctrl.groups[0]).toBe(group1);
          expect(ctrl.groups[1]).toBe(group3);
        });
      });
    });
  });
}
