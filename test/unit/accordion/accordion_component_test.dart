// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular_ui_test;

testAccordionComponent() {
  describe("[Accordion Component]", () {
    TestBed _;
    Scope scope;
        
    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    beforeEach(() {
      module((Module _) => _
        ..install(new AccordionModule())
      );
      return loadTemplates(['/accordion/accordion.html', 'accordion/accordion_group.html']);
    });
    
    describe('Accordion', () {
      it('Alone Accordion', compileComponent(
          '<accordion></accordion>', 
          {}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final accordion = shadowRoot.querySelector('accordion');
        print("!!! ${accordion.outerHtml}");
        expect(accordion).toBeDefined();
      }));
      
      it('Accordion with Header', compileComponent(
          '''<accordion>
<accordion-group heading="Static Header, initially expanded">
      This content is straight in the template.
    </accordion-group>
</accordion>''', 
          {}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final accordion = shadowRoot.querySelector('accordion');
        print("!!! ${accordion.outerHtml}");
        expect(accordion).toBeDefined();
      }));
      
      
    });
    
//    describe('addGroup', () {
//      
//    });
    
//    describe('addGroup', () {
//      AccordionComponent ctrl;
//      AccordionGroupComponent group1, group2, group3;
//              
//      void createElements(AccordionConfig config) {
//        ctrl = new AccordionComponent( scope, config );
//        group1 = new AccordionGroupComponent( scope.createChild(new PrototypeMap(scope.context)), ctrl);
//        group1.isOpen = true;
//        group2 = new AccordionGroupComponent(scope.createChild(new PrototypeMap(scope.context)), ctrl);
//        group2.isOpen = true;
//        group3 = new AccordionGroupComponent(scope.createChild(new PrototypeMap(scope.context)), ctrl);
//        group3.isOpen = true;
//      };
//      
//      String getHtml() {
//        return '''
//<accordion>
//  <accordion-group heading="{{group.title}}" ng-repeat="group in groups">
//    {{group.content}}
//  </accordion-group>
//</accordion>''';
//      };
//      
//      Map getScopeContent() {
//        return {'groups': [
//           {
//             'title': 'Dynamic Group Header - 1',
//             'content': 'Dynamic Group Body - 1'
//           },
//           {
//             'title': 'Dynamic Group Header - 2',
//             'content': 'Dynamic Group Body - 2'
//           }
//         ],
//         'items': ['Item 1', 'Item 2', 'Item 3']};
//      };      
//      
////      it('adds a the specified panel to the collection', async(inject(() {
////        createElements(new AccordionConfig());
////        expect(ctrl.groups.length).toBe(3);
////        expect(ctrl.groups[0]).toBe(group1);
////        expect(ctrl.groups[1]).toBe(group2);
////        expect(ctrl.groups[2]).toBe(group3);
////        group2.detach();
////        expect(ctrl.groups.length).toBe(2);
////        expect(ctrl.groups[0]).toBe(group1);
////        expect(ctrl.groups[1]).toBe(group3);
////      })));
//      
//      it("adds a the specified panel to the collection", compileComponent(
//          getHtml(), 
//          getScopeContent(), 
//          (Scope scope, dom.HtmlElement shadowRoot) {
//        final accordions = shadowRoot.querySelectorAll('accordion-group');
//        expect(accordions.length).toEqual(3);
//      }));      
//    });

//    String getHtml() {
//      return "<alert ng-repeat='alert in alerts' type='alert.type'" +
//          "close='removeAlert(\$index)'>{{alert.msg}}" +
//        "</alert>";
//    };
//    
//    Map getScopeContent() {
//      return {'alerts': [
//        { 'msg':'foo', 'type':'success'},
//        { 'msg':'bar', 'type':'error'},
//        { 'msg':'baz'}
//      ]};
//    };
//    
//    it("should generate alerts using ng-repeat", compileComponent(
//        getHtml(), 
//        getScopeContent(), 
//        (Scope scope, dom.HtmlElement shadowRoot) {
//      final alerts = shadowRoot.querySelectorAll('alert');
//      expect(alerts.length).toEqual(3);
//    }));
//    
//    it('should show the alert content', compileComponent(
//        getHtml(), 
//        getScopeContent(), 
//        (Scope scope, dom.HtmlElement shadowRoot) {
//      final alerts = shadowRoot.querySelectorAll('alert');
//
//      for (var i = 0; i < alerts.length; i++) {
//        dom.Element el = shadowRoot.querySelectorAll('alert')[i];
//        expect(el.text).toEqual(scope.context['alerts'][i]['msg']);
//      }
//    }));
  });
}
