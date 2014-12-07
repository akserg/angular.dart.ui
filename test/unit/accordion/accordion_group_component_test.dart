// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular_ui_test;

testAccordionGroupComponent() {
  describe("[Accordion Group Component]", () {
        
    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    beforeEach(() {
      module((Module _) => _
        ..install(new AccordionModule())
      );
      //return loadTemplates(['/accordion/accordion.html', 'accordion/accordion_group.html']);
    });
    
    dom.Element findGroupLink(List groups, int index) {
      return groups[index].querySelector('.accordion-toggle');
    };
    
    dom.Element findGroupBody(List groups, int index) {
      return groups[index].querySelector('.panel-body');
    };
    
    describe('with static panels', () {
      
      getHtml() {
        return r'''
<accordion>
  <accordion-group heading="title 1">Content 1</accordion-group>
  <accordion-group heading="title 2">Content 2</accordion-group>
</accordion>''';
      }
      
      it('adds a the specified panel to the collection', compileComponent(
          getHtml(), 
          {}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var groups = shadowRoot.querySelectorAll('accordion-group');

        expect(groups.length).toEqual(2);
        expect(groups[0].attributes['heading']).toEqual('title 1');
        expect(findGroupBody(groups, 0).text.trim()).toEqual('Content 1');
        expect(groups[1].attributes['heading']).toEqual('title 2');
        expect(findGroupBody(groups, 1).text.trim()).toEqual('Content 2');
      }));
      
      it('should change selected element on click', compileComponent(
          getHtml(), 
          {}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var groups = shadowRoot.querySelectorAll('accordion-group');
        
        findGroupLink(groups, 0).click();
        digest();
        AccordionGroupComponent group0 = ngProbe(groups[0]).directives.firstWhere((d) => d is AccordionGroupComponent);
        AccordionGroupComponent group1 = ngProbe(groups[1]).directives.firstWhere((d) => d is AccordionGroupComponent);
        expect(group0.isOpen).toBe(true);
        expect(group1.isOpen).toBe(false);

        findGroupLink(groups, 1).click();
        digest();
        
        expect(group0.isOpen).toBe(false);
        expect(group1.isOpen).toBe(true);
      }));
      
      it('should toggle element on click', compileComponent(
          getHtml(), 
          {}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var groups = shadowRoot.querySelectorAll('accordion-group');
        AccordionGroupComponent group0 = ngProbe(groups[0]).directives.firstWhere((d) => d is AccordionGroupComponent);
        AccordionGroupComponent group1 = ngProbe(groups[1]).directives.firstWhere((d) => d is AccordionGroupComponent);
        
        findGroupLink(groups, 0).click();
        digest();
        expect(group0.isOpen).toBe(true);
        findGroupLink(groups, 0).click();
        digest();
        expect(group0.isOpen).toBe(false);
      }));
    });
    
    describe('with dynamic panels', () {
      getHtml() {
        return r'''
<accordion>
  <accordion-group ng-repeat="group in groups" heading="{{group.name}}">{{group.content}}</accordion-group>
</accordion>
''';
      }
      
      getModel() {
        return [
          {'name': 'title 1', 'content': 'Content 1'},
          {'name': 'title 2', 'content': 'Content 2'}
        ];
      }
      
      it('should have no panels initially', compileComponent(
          getHtml(), 
          {}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var groups = shadowRoot.querySelectorAll('accordion-group');
        
        expect(groups.length).toEqual(0);
      }));
      
      it('should have a panel for each model item', compileComponent(
          getHtml(), 
          {}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        
        scope.context['groups'] = getModel();
        digest();

        var groups = shadowRoot.querySelectorAll('accordion-group');
        AccordionGroupComponent group0 = ngProbe(groups[0]).directives.firstWhere((d) => d is AccordionGroupComponent);
        AccordionGroupComponent group1 = ngProbe(groups[1]).directives.firstWhere((d) => d is AccordionGroupComponent);
        
        expect(groups.length).toEqual(2);
        expect(groups[0].attributes['heading']).toEqual('title 1');
        expect(groups[0].text.trim()).toEqual('Content 1');
        expect(groups[1].attributes['heading']).toEqual('title 2');
        expect(groups[1].text.trim()).toEqual('Content 2');
      }));
      
//      it('should react properly on removing items from the model', compileComponent(
//          getHtml(), 
//          {}, 
//          (Scope scope, dom.HtmlElement shadowRoot) {
//            
//        scope.context['groups'] = getModel();
//        digest();
//        var groups = shadowRoot.querySelectorAll('accordion-group');
//        expect(groups.length).toEqual(2);
//
//        scope.context['groups'].removeAt(0);
//        digest();
//        groups = shadowRoot.querySelectorAll('accordion-group');
//        expect(groups.length).toEqual(1);
//      }));
    });
    
    describe('is-open attribute', () {
      getHtml() {
              return r'''
<accordion>
  <accordion-group heading="title 1" is-open="open.first">Content 1</accordion-group>
  <accordion-group heading="title 2" is-open="open.second">Content 2</accordion-group>
</accordion>''';
      };
      
      getScope() {
        return {'open': { 'first': false, 'second': true }};
      }
      
      it('should open the panel with isOpen set to true', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var groups = shadowRoot.querySelectorAll('accordion-group');
        AccordionGroupComponent group0 = ngProbe(groups[0]).directives.firstWhere((d) => d is AccordionGroupComponent);
        AccordionGroupComponent group1 = ngProbe(groups[1]).directives.firstWhere((d) => d is AccordionGroupComponent);
            
        expect(group0.isOpen).toBe(false);
        expect(group1.isOpen).toBe(true);
      }));
      
      it('should toggle variable on element click', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var groups = shadowRoot.querySelectorAll('accordion-group');
        AccordionGroupComponent group0 = ngProbe(groups[0]).directives.firstWhere((d) => d is AccordionGroupComponent);
        AccordionGroupComponent group1 = ngProbe(groups[1]).directives.firstWhere((d) => d is AccordionGroupComponent);
            
        findGroupLink(groups, 0).click();
        digest();
        expect(scope.context['open']['first']).toBe(true);

        findGroupLink(groups, 0).click();
        digest();
        expect(scope.context['open']['second']).toBe(false);
      }));
    });
    
    describe('is-open attribute with dynamic content', () {
      getHtml() {
                    return r'''
<accordion>
  <accordion-group heading="title 1" is-open="open1"><div ng-repeat="item in items">{{item}}</div></accordion-group>
  <accordion-group heading="title 2" is-open="open2">Static content</accordion-group>
</accordion>''';
      }
      
      getScope() {
        return {
          'items': ['Item 1', 'Item 2', 'Item 3'],
          'open1': true,
          'open2': false
        };
      }

      it('should have visible panel body when the group with isOpen set to true', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        dom.document.body.append(shadowRoot);
        digest();
        microLeap();
        var groups = shadowRoot.querySelectorAll('accordion-group');
        
        expect(groups[0].querySelector('.panel-collapse').clientHeight).not.toBe(0);
//        expect(groups[1].querySelector('.panel-collapse').clientHeight).toBe(18);
        shadowRoot.remove();
      }));
    });
    
    describe('is-open attribute with dynamic groups', () {
      getHtml() {
        return r'''
<accordion>
  <accordion-group ng-repeat="group in groups" heading="{{group.name}}" is-open="group.open">{{group.content}}</accordion-group>
</accordion>''';
      }
      
      getScope() {
        return {
          'groups': [
            {'name': 'title 1', 'content': 'Content 1', 'open': false},
            {'name': 'title 2', 'content': 'Content 2', 'open': true}
          ]
        };
      }

      it('should have visible group body when the group with isOpen set to true', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        
        
        var groups = shadowRoot.querySelectorAll('accordion-group');
        AccordionGroupComponent group0 = ngProbe(groups[0]).directives.firstWhere((d) => d is AccordionGroupComponent);
        AccordionGroupComponent group1 = ngProbe(groups[1]).directives.firstWhere((d) => d is AccordionGroupComponent);

        expect(group0.isOpen).toBe(false);
        expect(group1.isOpen).toBe(true);
      }));

      it('should toggle element on click', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        microLeap();
                
        var groups = shadowRoot.querySelectorAll('accordion-group');
        AccordionGroupComponent group0 = ngProbe(groups[0]).directives.firstWhere((d) => d is AccordionGroupComponent);
        AccordionGroupComponent group1 = ngProbe(groups[1]).directives.firstWhere((d) => d is AccordionGroupComponent);

        findGroupLink(groups, 0).click();
        digest();
        expect(group0.isOpen).toBe(true);
        expect(scope.context['groups'][0]['open']).toBe(true);

        findGroupLink(groups, 0).click();
        digest();
        expect(group0.isOpen).toBe(false);
        expect(scope.context['groups'][0]['open']).toBe(false);
      }));
    });
    
    describe('`is-disabled` attribute', () {
      
      getHtml() {
        return r'''
<accordion>
  <accordion-group heading="title 1" is-disabled="disabled">Content 1</accordion-group>
</accordion>''';
      }
      
      getScope() {
        return { 'disabled': true };
      }

      it('should open the panel with isOpen set to true', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var group = shadowRoot.querySelector('accordion-group');
        AccordionGroupComponent groupBody = ngProbe(group).directives.firstWhere((d) => d is AccordionGroupComponent);
        
        expect(groupBody.isOpen).toBeFalsy();
      }));

      it('should not toggle if disabled', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var group = shadowRoot.querySelector('accordion-group');
        AccordionGroupComponent groupBody = ngProbe(group).directives.firstWhere((d) => d is AccordionGroupComponent);
        
        group.querySelector('.accordion-toggle').click();
        digest();
        expect(groupBody.isOpen).toBeFalsy();
      }));

      it('should toggle after enabling', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var group = shadowRoot.querySelector('accordion-group');
        AccordionGroupComponent groupBody = ngProbe(group).directives.firstWhere((d) => d is AccordionGroupComponent);
        
        scope.context['disabled'] = false;
        digest();
        expect(groupBody.isOpen).toBeFalsy();

        group.querySelector('.accordion-toggle').click();
        digest();
        expect(groupBody.isOpen).toBeTruthy();
      }));
    });
    
    describe('accordion-heading element', () {
      getHtml() {
        return r'''
<accordion>
  <accordion-group heading="I get overridden">
    <accordion-heading>123</accordion-heading>
    Body
  </accordion-group>
</accordion>''';
      }

      it('transcludes the <accordion-heading> content into the heading link', compileComponent(
          getHtml(), 
          {}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        dom.document.body.append(shadowRoot);
        digest();
        microLeap();
        var group = shadowRoot.querySelector('accordion-group');
        expect(group.querySelector('.accordion-toggle').text).toEqual('123');
      }));
    });
  });
}
