// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void tabsTests() {
  
  List<Element> titles(Element elm) {
    return elm.children[0].shadowRoot.querySelectorAll('ul.nav-tabs li');
    //return ngQuery(elm, 'ul.nav-tabs li');
  }
  
  List<Element> contents(Element elm) {
    return ngQuery( elm , '.tab-pane' );
  }

  void expectTitles(Element elm, titlesArray) {
    List<Element> t = titles(elm);
    expect(t.length).toEqual(titlesArray.length);
    for (int i=0; i<t.length; i++) {
      expect(ngQuery(t[i] ,'tab-heading')[0].innerHtml.trim()).toEqual(titlesArray[i]);
    }
  }
  
  describe('Testing Tabs:', () {
    TestBed _;
    Scope scope;
    
    beforeEach(setUpInjector);
    beforeEach(module((Module module) {
      module.install(new TabsModule());
    }));
    beforeEach(inject((TestBed tb) => _ = tb));
    beforeEach(inject((Scope s) => scope = s));
    beforeEach(inject((TemplateCache cache) {
      addToTemplateCache(cache, 'packages/angular_ui/tabs/tab.html');
      addToTemplateCache(cache, 'packages/angular_ui/tabs/tabset.html');
    }));
    
    afterEach(tearDownInjector);
    
    dom.Element createElement() {
      
      scope.context['first'] = '1';
      scope.context['second'] = '2';
      scope.context['actives'] = {};
      scope.context['selectFirst'] = jasmine.createSpy('first select listener');
      scope.context['selectSecond'] = jasmine.createSpy('second select listener');
      scope.context['deselectFirst'] = jasmine.createSpy('first deselect listener');
      scope.context['deselectSecond'] = jasmine.createSpy('second deselect listener');
      
      String html =
      '''<div>
            <tabset class="hello" data-pizza="pepperoni">
              <tab heading="First Tab {{first}}" active="actives.one" select="selectFirst()" deselect="deselectFirst()">
                <div id="tab-content">first content is {{first}}</div>
              </tab>
              <tab active="actives.two" select="selectSecond()" deselect="deselectSecond()">
                <tab-heading><b>Second</b> Tab {{second}}</tab-heading>
                <div id="tab-content">second content is {{second}}</div>
              </tab>
            </tabset>
          </div>''';
      dom.Element element = _.compile(html.trim());
      
      //Doing it twice or it doesn't work... why!?
      microLeap();
      scope.rootScope.apply();
      microLeap();
      scope.rootScope.apply();
      
      return element;
    };
    
    it('should create clickable titles', async(inject(() {
      ElementList<Element> t = titles(createElement());
      expect(t.length).toBe(2);
      //print(t[0].outerHtml);
      expect(renderedText( ngQuery(t[0] ,'a')[0] )).toEqual('First Tab 1');
      //It should put the tab-heading element into the 'a' title
      //print( ngQuery(t[1] ,'tab-heading')[0].innerHtml );
      //expect( ngQuery(t[1] ,'a')[0].children[0].shadowRoot .is('tab-heading')).toBe(true);
      expect(renderedText( ngQuery(t[1] ,'a')[0] )).toEqual('Second Tab 2');
      expect( ngQuery(t[1] ,'tab-heading')[0].innerHtml ).toEqual('<b>Second</b> Tab 2');
    })));

    it('should bind tabs content and set first tab active', async(inject(() {
      Element elems = createElement();
      
      expect(contents(elems).length).toBe(1);
      expect(contents(elems)[0]).toHaveClass('active');
      print(ngQuery(elems ,'tab')[0].getDestinationInsertionPoints()[0].text);
      expect( renderedText ( ngQuery(elems ,'#tab-content')[0] ) ).toEqual('first content is 1');
      
      //expect(contents(elems)[1]).not.toHaveClass('active');
      //expect(scope.context['actives.one).toBe(true);
      //expect(scope.context['actives.two).toBe(false);
    })));
    
    it('should change active on click', async(inject(() {
      Element elems = createElement();
      ngQuery(titles(elems)[1] , 'a')[0].click();
      expect(contents(elems)[0]).toHaveClass('active');
      expect(titles(elems)[0]).not.toHaveClass('active');
      expect(titles(elems)[1]).toHaveClass('active');
      //expect($rootscope.context['actives.one).toBe(false);
      //expect($rootscope.context['actives.two).toBe(true);
    })));

    
    it('should call select callback on select', async(inject(() {
      Element elems = createElement();
      ngQuery(titles(elems)[1] , 'a')[0].click();
      expect(scope.context['selectSecond']).toHaveBeenCalled();
      ngQuery(titles(elems)[0] , 'a')[0].click();
      expect(scope.context['selectFirst']).toHaveBeenCalled();
    })));

   
    it('should call deselect callback on deselect', async(inject(() {
      Element elems = createElement();
      expect(scope.context['deselectSecond']).not.toHaveBeenCalled();
      ngQuery(titles(elems)[1] , 'a')[0].click();
      ngQuery(titles(elems)[0] , 'a')[0].click();
      expect(scope.context['deselectSecond']).toHaveBeenCalled();
      ngQuery(titles(elems)[0] , 'a')[0].click();
      expect(scope.context['deselectFirst']).toHaveBeenCalled();
    })));

  });
  
}
