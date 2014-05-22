// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void contentAppendTests() {

  
  describe('Testing content-append:', () {

    TestBed _;
    Scope scope;
    
    beforeEach(() {
      setUpInjector();
      module((Module module) {
        module.install(new ContentAppendModule());
      });
      inject((TestBed tb, Scope s) { 
        _ = tb;
        scope = s;
      });
    });
    
    afterEach(tearDownInjector);

    group('ContentAppend directive', () {
      
      dom.Element createElement() {
        
        String html =
        '''<div id='main'>
          <content-append node="node"></content-append>
        </div>''';
        dom.Element element = _.compile(html.trim());
        
        microLeap();
        scope.rootScope.apply();
        
        return element;
      };
      
      it('It should ignore null values', async(inject(() {
        scope.context['node'] = null;
        dom.Element elem = createElement();
        expect(elem.children[0].childNodes.length).toBe(0);
      })));
      
      it('It should append a String', async(inject(() {
        scope.context['node'] = 'Hello';
        dom.Element elem = createElement();
        expect(elem.children[0].childNodes.length).toBe(1);
        expect(elem.children[0].text).toEqual('Hello');
      })));
      
      it('It should append an Element', async(inject(() {
        scope.context['node'] = new dom.Element.html("<div id='inner'>HelloFromInner</div>");
        dom.Element elem = createElement();
        expect(elem.children[0].children.length).toBe(1);
        expect(elem.querySelector('#inner').text).toEqual('HelloFromInner');
      })));
      
    });
    
  });
}