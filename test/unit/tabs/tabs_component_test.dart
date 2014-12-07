// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular_ui_test;

testTabsComponent() {
  describe("[TabsComponent]", () {
    TestBed _;
    Scope scope;
        
    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    beforeEach(() {
      module((Module _) => _
        ..install(new TabsModule())
      );
      inject((TestBed t) => _ = t);
      //return loadTemplates(['tabs/tab.html', 'tabs/tabset.html']);
    });

    getHtml() {
      return '''
<tabset class="hello" data-pizza="pepperoni">
  <tab heading="First Tab {{first}}" active="actives.one" select="selectFirst()" deselect="deselectFirst()">
    <div id="tab-content">first content is {{first}}</div>
  </tab>
  <tab active="actives.two" select="selectSecond()" deselect="deselectSecond()">
    <tab-heading><b>Second</b> Tab {{second}}</tab-heading>
    <div id="tab-content">second content is {{second}}</div>
  </tab>
</tabset>''';
    }
    
    getScope() {
      return {
        'first': '1',                                                   
        'second': '2',                                                  
        'actives': {},                                                  
        'selectFirst': guinness.createSpy('first select listener'),      
        'selectSecond': guinness.createSpy('second select listener'),    
        'deselectFirst': guinness.createSpy('first deselect listener'),  
        'deselectSecond': guinness.createSpy('second deselect listener')
      };
    }
    
    it('should pass class and other attributes on to tab template', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final tabset = shadowRoot.querySelector('tabset');

      expect(tabset).toHaveClass('hello');
      expect(tabset.attributes['data-pizza']).toEqual('pepperoni');
    }));
    
    it('should create clickable titles', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      final titles = shadowRoot.querySelectorAll('ul.nav-tabs li');
      
      expect(titles.length).toBe(2);
      expect(ngQuery(titles[0] ,'a')[0].text).toEqual('First Tab 1');
      //It should put the tab-heading element into the 'a' title
      expect(ngQuery(titles[1] ,'a')[0].text).toEqual('Second Tab 2');
      expect(ngQuery(titles[1] ,'tab-heading')[0].innerHtml ).toEqual('<b>Second</b> Tab 2');
    }));
    
//    it('should bind tabs content and set first tab active', compileComponent(
//        getHtml(), 
//        getScope(), 
//        (Scope scope, dom.HtmlElement shadowRoot) {
//      final contents = shadowRoot.querySelectorAll('.tab-pane');
//      
//      expect(contents.length).toBe(1);
//      expect(contents[0]).toHaveClass('active');
//      expect(ngQuery(shadowRoot ,'#tab-content')[0].text).toEqual('first content is 1');
//    }));
//    
//    it('should change active on click', compileComponent(
//        getHtml(), 
//        getScope(), 
//        (Scope scope, dom.HtmlElement shadowRoot) {
//      final titles = shadowRoot.querySelectorAll('ul.nav-tabs li');
//      final contents = shadowRoot.querySelectorAll('.tab-pane');
//      
//      ngQuery(titles[1] , 'a')[0].click();
//      microLeap();
//      digest();
//      expect(contents[0]).toHaveClass('active');
//      expect(titles[0]).not.toHaveClass('active');
//      expect(titles[1]).toHaveClass('active');
//    }));
//    
//    it('should call select callback on select', compileComponent(
//        getHtml(), 
//        getScope(), 
//        (Scope scope, dom.HtmlElement shadowRoot) {
//      final titles = shadowRoot.querySelectorAll('ul.nav-tabs li');
//      
//      ngQuery(titles[1] , 'a')[0].click();
//      expect(scope.context['selectSecond']).toHaveBeenCalled();
//      ngQuery(titles[0] , 'a')[0].click();
//      expect(scope.context['selectFirst']).toHaveBeenCalled();
//    }));
//    
//    it('should call deselect callback on deselect', compileComponent(
//        getHtml(), 
//        getScope(), 
//        (Scope scope, dom.HtmlElement shadowRoot) {
//      final titles = shadowRoot.querySelectorAll('ul.nav-tabs li');
//      
//      expect(scope.context['deselectSecond']).not.toHaveBeenCalled();
//      ngQuery(titles[1] , 'a')[0].click();
//      ngQuery(titles[0] , 'a')[0].click();
//      expect(scope.context['deselectSecond']).toHaveBeenCalled();
//      ngQuery(titles[0] , 'a')[0].click();
//      expect(scope.context['deselectFirst']).toHaveBeenCalled();
//    }));
//    
    describe('basics with initial active tab', () {

      Map makeTab([active = false]) {
        return {
          'active': active,
          'select': guinness.createSpy()
        };
      }
      
      getHtml() {
        return '''
<tabset>
  <tab active="tabs[0].active" select="tabs[0].select()">
  </tab>
  <tab active="tabs[1].active" select="tabs[1].select()">
  </tab>
  <tab active="tabs[2].active" select="tabs[2].select()">
  </tab>
  <tab active="tabs[3].active" select="tabs[3].select()">
  </tab>
</tabset>''';
      }
      
      getScope() {
        return {
          'tabs': [ makeTab(), makeTab(), makeTab(true), makeTab() ]
        };
      }

      expectTabActive(dom.Element shadowRoot, Scope scope, Map activeTab) {
        var _titles = shadowRoot.querySelectorAll('ul.nav-tabs li');
        var tabs = shadowRoot.querySelectorAll('tab');
        
        for (var i = 0; i < scope.context['tabs'].length; i++) {
          Map tab = scope.context['tabs'][i];
          if (activeTab == tab) {
            expect(tab['active']).toBe(true);
            //It should only call select ONCE for each select
            expect(tab['select']).toHaveBeenCalled();
            expect(_titles[i]).toHaveClass('active');
            expect(tabs[i].querySelector('.tab-pane')).toHaveClass('active');
          } else {
            expect(tab['active']).toBe(false);
            expect(_titles[i]).not.toHaveClass('active');
          }
        }
      }

      it('should make tab titles and set active tab active', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final titles = shadowRoot.querySelectorAll('ul.nav-tabs li');
        
        expect(titles.length).toBe(scope.context['tabs'].length);
        expectTabActive(shadowRoot, scope, scope.context['tabs'][2]);
      }));
    });
    
    describe('tab callback order', () {
      
      List execOrder;
      
      getHtml() {
        return '''
<tabset class="hello" data-pizza="pepperoni">
  <tab heading="First Tab" active="active" select="execute(\'select1\')" deselect="execute(\'deselect1\')"></tab>
  <tab select="execute(\'select2\')" deselect="execute(\'deselect2\')"></tab>
</tabset>''';
      }
      
      getScope() {
        return {
          'active': true,                                                   
          'execute': (id) => execOrder.add(id)
        };
      }
      
      beforeEach(() {
        execOrder = [];
      });

      it('should call select  for the first tab', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        
        expect(execOrder).toEqual(['deselect1', 'select1']);
      }));

      it('should call deselect, then select', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final titles = shadowRoot.querySelectorAll('ul.nav-tabs li');
        execOrder = [];

        // Select second tab
        titles[1].querySelector('a').click();
        expect(execOrder).toEqual([ 'deselect1', 'select2' ]);

        execOrder = [];

        // Select again first tab
        titles[0].querySelector('a').click();
        expect(execOrder).toEqual([ 'deselect2', 'select1' ]);
      }));
    });
    
    describe('ng-repeat', () {

      Map makeTab([active = false]) {
        return {
          'active': active,
          'select': guinness.createSpy()
        };
      }
      
      getHtml() {
        return r'''
<tabset>
  <tab ng-repeat="t in tabs" active="t.active" select="t.select()">
    <tab-heading><b>heading</b> {{index}}</tab-heading>
    content {{$index}}
  </tab>
</tabset>''';
      }
      
      getScope() {
        return {
          'tabs': [ makeTab(), makeTab(), makeTab(true), makeTab() ]
        };
      }      

      expectTabActive(dom.Element shadowRoot, Scope scope, Map activeTab) {
        var _titles = shadowRoot.querySelectorAll('ul.nav-tabs li');
        var tabs = shadowRoot.querySelectorAll('tab'); // div.tab-content div.tab-pane
        
        for (var i = 0; i < scope.context['tabs'].length; i++) {
          Map tab = scope.context['tabs'][i];
          if (activeTab == tab) {
            expect(tab['active']).toBe(true);
            // It should only call select ONCE for each select
            expect(tab['select']).toHaveBeenCalled();
            expect(_titles[i]).toHaveClass('active');
            expect(tabs[i].querySelector('.tab-pane')).toHaveClass('active');
          } else {
            expect(tab['active']).toBe(false);
            expect(_titles[i]).not.toHaveClass('active');
          }
        }
      }
  
      it('should make tab titles and set active tab active', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        // Extra cycle to draw tab content
        microLeap();
        digest();
        
        var titles = shadowRoot.querySelectorAll('ul.nav-tabs li');
        
        expect(titles.length).toBe(scope.context['tabs'].length);
        expectTabActive(shadowRoot, scope, scope.context['tabs'][2]);
      }));
  
      it('should switch active when clicking', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        // Extra cycle to draw tab content
        microLeap();
        digest();
        
        var titles = shadowRoot.querySelectorAll('ul.nav-tabs li');
        
        titles[3].querySelector('a').click();
        digest();
        
        expectTabActive(shadowRoot, scope, scope.context['tabs'][3]);
      }));
  
      it('should switch active when setting active=true', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        // Extra cycle to draw tab content
        microLeap();
        digest();
        
        scope.apply('tabs[2].active = true');
        expectTabActive(shadowRoot, scope, scope.context['tabs'][2]);
      }));
  
      it('should deselect all when no tabs are active', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        // Extra cycle to draw tab content
        microLeap();
        digest();
        
        for (var i = 0; i < scope.context['tabs'].length; i++) {
          Map tab = scope.context['tabs'][i];
          tab['active'] = false;
        }
        microLeap();
        digest();
        
        expectTabActive(shadowRoot, scope, null); 
        
        final contents = shadowRoot.querySelectorAll('.tab-pane');
        expect(contents.where((dom.Element el) => el.classes.contains('active')).toList().length).toBe(0);
  
        scope.context['tabs'][2]['active'] = true;
        microLeap();
        digest();
        
        expectTabActive(shadowRoot, scope, scope.context['tabs'][2]);
      }));
    });
    
    describe('advanced tab-heading element', () {
//      
//      getHtml() {
//        return r'''
//<tabset>
//  <tab>
//    <tab-heading ng-bind-html="myHtml" ng-show="value">
//    </tab-heading>
//  </tab>
//  <tab><data-tab-heading>1</data-tab-heading></tab>
//  <tab><div data-tab-heading>2</div></tab>
//  <tab><div tab-heading>3</div></tab>
//</tabset>''';
//      }
//      
//      getScope() {
//        return {
//          'myHtml': '<b>hello</b> there!',
//          'value': true
//        };
//      }  
//
//      heading(dom.Element elm) => elm.querySelector('ul li a').children;
//
//      it('should create a heading bound to myHtml', compileComponent(
//          getHtml(), 
//          getScope(), 
//          (Scope scope, dom.HtmlElement shadowRoot) {
//        // Extra cycle to draw tab content
//        microLeap();
//        digest();
//        microLeap();
//        digest();
//     
//        print(shadowRoot.outerHtml);        
//        //expect(heading().eq(0).html()).toBe('<b>hello</b>, there!');
//      }));
//
//      it('should hide and show the heading depending on value', function() {
//        expect(heading().eq(0)).not.toBeHidden();
//        scope.$apply('value = false');
//        expect(heading().eq(0)).toBeHidden();
//        scope.$apply('value = true');
//        expect(heading().eq(0)).not.toBeHidden();
//      });
//
//      it('should have a tab-heading no matter what syntax was used', function() {
//        expect(heading().eq(1).text()).toBe('1');
//        expect(heading().eq(2).text()).toBe('2');
//        expect(heading().eq(3).text()).toBe('3');
//      });
    });
    
    describe('tabset component', () {
      mockTab(TabsetComponent tabSet, [isActive = false]) {
        return new TabComponent(new dom.DivElement(), tabSet)
        ..active = isActive
        ..onSelectCallback = null
        ..onDeselectCallback = null;
      }
      
      TabsetComponent cmp;
      
      beforeEach(() {
        inject((TabsetComponent v) => cmp = v);
      });
      
      describe('select', () {
        it('should mark given tab selected', () {
          var tab = mockTab(cmp);

          cmp.select(tab);
          expect(tab.active).toBe(true);
        });
        
        it('should deselect other tabs', () {
          var tab1 = mockTab(cmp), tab2 = mockTab(cmp), tab3 = mockTab(cmp);

          cmp.addTab(tab1);
          cmp.addTab(tab2);
          cmp.addTab(tab3);

          cmp.select(tab1);
          expect(tab1.active).toBe(true);
          expect(tab2.active).toBe(false);
          expect(tab3.active).toBe(false);

          cmp.select(tab2);
          expect(tab1.active).toBe(false);
          expect(tab2.active).toBe(true);
          expect(tab3.active).toBe(false);

          cmp.select(tab3);
          expect(tab1.active).toBe(false);
          expect(tab2.active).toBe(false);
          expect(tab3.active).toBe(true);
        });
      });
      
      describe('addTab', () {

        it('should append tab', () {
          var tab1 = mockTab(cmp), tab2 = mockTab(cmp);

          expect(cmp.tabs).toEqual([tab1, tab2]);
        });


//        it('should select the first one', () {
//          var tab1 = mockTab(cmp), tab2 = mockTab(cmp);
//
//          expect(tab1.active).toBe(true);
//        });

//        it('should select a tab added that\'s already active', () {
//          var tab1 = mockTab(cmp), tab2 = mockTab(cmp, true);
//          expect(tab1.active).toBe(true);
//
//          cmp.addTab(tab2);
//          expect(tab1.active).toBe(false);
//          expect(tab2.active).toBe(true);
//        });
      });
    });
    
//    describe('remove', () {
//      getHtml() {
//        return '''<tabset><tab heading="1">Hello</tab><tab ng-repeat="i in list" heading="tab {{i}}">content {{i}}</tab></tabset>''';
//      }
//      
//      getScope() {
//        return {};
//      }
//      
//      expectTitles(dom.HtmlElement shadowRoot, titlesArray) {
//        var t = shadowRoot.querySelectorAll('ul.nav-tabs li');
//        expect(t.length).toEqual(titlesArray.length);
//        for (var i=0; i<t.length; i++) {
//          expect(t[i].text.trim()).toEqual(titlesArray[i]);
//        }
//      }
//      expectContents(dom.HtmlElement shadowRoot, contentsArray) {
//        var c = shadowRoot.querySelectorAll('.tab-pane');
//        expect(c.length).toEqual(contentsArray.length);
//        for (var i=0; i<c.length; i++) {
//          expect(c[i].text.trim()).toEqual(contentsArray[i]);
//        }
//      }
//
//      it('should remove title tabs when elements are destroyed and change selection', compileComponent(
//          getHtml(), 
//          getScope(), 
//          (Scope scope, dom.HtmlElement shadowRoot) {
//        
//        expectTitles(shadowRoot, ['1']);
//        expectContents(shadowRoot, ['Hello']);
//
//        scope.apply('list = [1,2,3]');
//        expectTitles(shadowRoot, ['1', 'tab 1', 'tab 2', 'tab 3']);
//        expectContents(shadowRoot, ['Hello', 'content 1', 'content 2', 'content 3']);
//
//        // Select last tab
//        var titles = shadowRoot.querySelectorAll('ul.nav-tabs li a');
//        titles[3].click();
//        print(shadowRoot.outerHtml);
//        
//        var contents = shadowRoot.querySelectorAll('.tab-pane');
//        expect(contents[3]).toHaveClass('active');
//        expect(titles[3]).toHaveClass('active');
//
//        // Remove last tab
//        scope.$apply('list = [1,2]');
//        expectTitles(shadowRoot, ['1', 'tab 1', 'tab 2']);
//        expectContents(shadowRoot, ['Hello', 'content 1', 'content 2']);
//
//        // "tab 2" is now selected
//        expect(titles().eq(2)).toHaveClass('active');
//        expect(contents().eq(2)).toHaveClass('active');
//
//        // Select 2nd tab ("tab 1")
//        titles().find('a').eq(1).click();
//        expect(titles().eq(1)).toHaveClass('active');
//        expect(contents().eq(1)).toHaveClass('active');
//
//        // Remove 2nd tab
//        scope.$apply('list = [2]');
//        expectTitles(shadowRoot, ['1', 'tab 2']);
//        expectContents(shadowRoot, ['Hello', 'content 2']);
//
//        // New 2nd tab is now selected
//        expect(titles().eq(1)).toHaveClass('active');
//        expect(contents().eq(1)).toHaveClass('active');
//      }));

//      it('should not select tabs when being destroyed', inject(function($controller, $compile, $rootScope){
//        var selectList = [],
//            deselectList = [],
//            getTab = function(active){
//              return {
//                active: active,
//                select : function(){
//                  selectList.push('select');
//                },
//                deselect : function(){
//                  deselectList.push('deselect');
//                }
//              };
//            };
//
//        scope = $rootScope.$new();
//        scope.tabs = [
//          getTab(true),
//          getTab(false)
//        ];
//        elm = $compile([
//          '<tabset>',
//          '  <tab ng-repeat="t in tabs" active="t.active" select="t.select()" deselect="t.deselect()">',
//          '    <tab-heading><b>heading</b> {{index}}</tab-heading>',
//          '    content {{$index}}',
//          '  </tab>',
//          '</tabset>'
//        ].join('\n'))(scope);
//        scope.$apply();
//
//        // The first tab is selected the during the initial $digest.
//        expect(selectList.length).toEqual(1);
//
//        // Destroy the tabs - we should not trigger selection/deselection any more.
//        scope.$destroy();
//        expect(selectList.length).toEqual(1);
//        expect(deselectList.length).toEqual(0);
//      }));
//    });
  });
}