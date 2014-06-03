// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void dragdropSortableTests() {

  describe('Drag&Drop-Sortable -', () {
    
    TestBed _;
    Scope scope;
    DragDropSortableDataService ddsDataService;
    DragDropConfigService ddConfig;
    
    beforeEach(() {
      setUpInjector();
      module((Module module) {
        module.install(new DragDropModule());
      });
      inject((TestBed tb, Scope s, DragDropSortableDataService injDDSDataService, DragDropConfigService injDragDropConfig) { 
        _ = tb;
        scope = s;
        ddsDataService = injDDSDataService;
        ddConfig = injDragDropConfig;
      });
    });
    
    afterEach(tearDownInjector);

    void swapMultiple(List<dom.Element> nodesOne, int firstNodeId, List<dom.Element> nodesTwo, int secondNodeId) {
      _.triggerEvent(nodesOne[firstNodeId], 'dragstart', 'MouseEvent');
      _.triggerEvent(nodesTwo[secondNodeId], 'dragover', 'MouseEvent');
    }
    
    void swap(List<dom.Element> nodes, int firstNodeId, int secondNodeId) {
      swapMultiple(nodes, firstNodeId, nodes, secondNodeId);
    }
    
    group('Single List Sortable -', () {
      
      dom.Element createElement(List sortableList) {
        
        scope.context['data'] = {
                                 'sortableList' : []
        };
        String html =
        '''<div>
          <ul class="list-group" ui-sortable ui-sortable-data="data.sortableList">
            <li ng-repeat="item in data.sortableList">{{item}}</li>
          </ul>
        </div>''';
        dom.Element element = _.compile(html.trim());
        
        microLeap();
        scope.rootScope.apply();
        
        //Needed to enable the DOMNodeInserted and DOMNodeRemoved events
        dom.document.body.append(element);
        
        scope.context['data']['sortableList'] = sortableList;

        microLeap();
        scope.rootScope.apply();
        
        return element;
      };
      
      it('The elements of the list should be draggable', async(inject(() {
        List<String> values = ['one','two','three','four','five','six'];
        dom.Element ulElem = ngQuery(createElement(values), 'ul')[0];
        expect(ulElem).toBeNotNull();
        expect(ulElem.children.length).toBe(values.length);
        
        for (dom.Element childElem in ulElem.children) {
          expect(childElem.attributes['draggable']).toBeTruthy();
        }
      })));
      
      it('It should sort in the same list', async(inject(() {
        List<String> values = ['one','two','three','four'];
        dom.Element ulElem = ngQuery(createElement(values), 'ul')[0];
        expect(ulElem).toBeNotNull();
        expect(ulElem.children.length).toBe(4);
        
        expect(ddsDataService.sortableData).toBeNull();
        expect(ddsDataService.sourceList).toBeNull();
        _.triggerEvent(ulElem.children[0], 'dragstart', 'MouseEvent');
        expect(ddsDataService.sortableData).toBe(values[0]);
        expect(ddsDataService.sourceList).toBe(values);
        
        swap(ulElem.children, 0, 1);
        expect(values[0]).toBe('two');
        expect(ulElem.children[0].text).toEqual('two');
        expect(values[1]).toBe('one');
        expect(ulElem.children[1].text).toEqual('one');
        
      })));
      
      it('It should add the expected classes on drag events', async(inject(() {
        List<String> values = ['one','two','three','four'];
        dom.Element ulElem = ngQuery(createElement(values), 'ul')[0];
        expect(ulElem).toBeNotNull();
        
        _.triggerEvent(ulElem.children[0], 'dragstart', 'MouseEvent');
        expect(ulElem.children[0]).toHaveClass(ddConfig.sortableConfig.onDragStartClass);
        
        _.triggerEvent(ulElem.children[1], 'dragenter', 'MouseEvent');
        expect(ulElem.children[1]).toHaveClass(ddConfig.sortableConfig.onDragEnterClass);   
        
        _.triggerEvent(ulElem.children[1], 'dragover', 'MouseEvent');
        expect(ulElem.children[1]).toHaveClass(ddConfig.sortableConfig.onDragOverClass);    
        
      })));
      
      it('It should work with arbitrary objects', async(inject(() {
        var elemOne = new dom.DivElement();
        var elemTwo = 'elemTwo';
        var elemThree = {'key':'value'};
        List values = [elemOne, elemTwo, elemThree];
        dom.Element ulElem = ngQuery(createElement(values), 'ul')[0];
        expect(ulElem).toBeNotNull();
        expect(ulElem.children.length).toBe(3);
        
        swap(ulElem.children, 0, 1);
        expect(values[0]).toBe(elemTwo);
        expect(values[1]).toBe(elemOne);
        
        swap(ulElem.children, 1, 2);
        expect(values[1]).toBe(elemThree);
        expect(values[2]).toBe(elemOne);
                
        swap(ulElem.children, 0, 1);
        expect(values[0]).toBe(elemThree);
        expect(values[1]).toBe(elemTwo);    
        
        //ulElem.remove();
      })));   
      
    });
    
    group('Multi List Sortable -', () {
      
      dom.Element createElement(List<String> singleList, List<String> multiOneList, List<String> multiTwoList) {
        
        scope.context['data'] = {
                                 'singleList' : [],
                                 'multiOneList' : [],
                                 'multiTwoList' : [],
        };
        String html =
        '''<div>
          <div id='single'>
            <ul class="list-group" ui-sortable ui-sortable-data="data.singleList">
              <li ng-repeat="item in data.singleList">{{item}}</li>
            </ul>
          </div>
          <div id='multiOne' ui-sortable ui-sortable-zones="'multiList'">
            <ul class="list-group" ui-sortable-data="data.multiOneList" >
              <li ng-repeat="item in data.multiOneList">{{item}}</li>
            </ul>
          </div>
          <div id='multiTwo' ui-sortable ui-sortable-zones="'multiList'">
            <ul class="list-group" ui-sortable-data="data.multiTwoList" >
              <li ng-repeat="item in data.multiTwoList">{{item}}</li>
            </ul>
          </div>
        </div>''';
        dom.Element element = _.compile(html.trim());
        
        microLeap();
        scope.rootScope.apply();
        
        //Needed to enable the DOMNodeInserted and DOMNodeRemoved events
        dom.document.body.append(element);
        
        scope.context['data']['singleList'] = singleList;
        scope.context['data']['multiOneList'] = multiOneList;
        scope.context['data']['multiTwoList'] = multiTwoList;

        microLeap();
        scope.rootScope.apply();
        
        return element;
      };
      
      it('It should sort in the same list', async(inject(() {
        List<String> singleList = ['sOne', 'sTwo', 'sThree']; 
        List<String> multiOneList = ['mOne', 'mTwo', 'mThree']; 
        List<String> multiTwoList = ['mFour', 'mFive', 'mSix'];
        dom.Element ulElem = createElement(singleList, multiOneList, multiTwoList);
        expect(ulElem).toBeNotNull();
        expect(ulElem.children.length).toBe(3);
        
        dom.Element singleElem = ulElem.querySelector('#single ul'); 
        swap(singleElem.children, 0, 1);
        expect(singleList[0]).toBe('sTwo');
        expect(singleElem.children[0].text).toEqual('sTwo');
        expect(singleList[1]).toBe('sOne');
        expect(singleElem.children[1].text).toEqual('sOne');
        
        dom.Element multiOneElem = ulElem.querySelector('#multiOne ul'); 
        swap(multiOneElem.children, 1, 2);
        expect(multiOneList[1]).toBe('mThree');
        expect(multiOneElem.children[1].text).toEqual('mThree');
        expect(multiOneList[2]).toBe('mTwo');
        expect(multiOneElem.children[2].text).toEqual('mTwo');
        
        dom.Element multiTwoElem = ulElem.querySelector('#multiTwo ul'); 
        swap(multiTwoElem.children, 1, 2);
        expect(multiTwoList[1]).toBe('mSix');
        expect(multiTwoElem.children[1].text).toEqual('mSix');
        expect(multiTwoList[2]).toBe('mFive');
        expect(multiTwoElem.children[2].text).toEqual('mFive');
      })));
      
      it('It should be possible to move items from list one to list two', async(inject(() {
        List<String> singleList = ['sOne', 'sTwo', 'sThree']; 
        List<String> multiOneList = ['mOne', 'mTwo', 'mThree']; 
        List<String> multiTwoList = ['mFour', 'mFive', 'mSix'];
        dom.Element ulElem = createElement(singleList, multiOneList, multiTwoList);
        expect(ulElem).toBeNotNull();
        expect(ulElem.children.length).toBe(3);
        
        dom.Element multiOneElem = ulElem.querySelector('#multiOne ul'); 
        dom.Element multiTwoElem = ulElem.querySelector('#multiTwo ul'); 
        swapMultiple(multiOneElem.children, 0, multiTwoElem.children, 0);
        
        expect(multiOneList.length).toBe(2);
        expect(multiTwoList.length).toBe(4);
        
        expect(multiOneList[0]).toBe('mTwo');
        expect(multiTwoList[0]).toBe('mOne');
        expect(multiTwoList[1]).toBe('mFour');
        
      })));
      
      it('It should not be possible to move items between lists not in the same sortable-zone', async(inject(() {
        List<String> singleList = ['sOne', 'sTwo', 'sThree']; 
        List<String> multiOneList = ['mOne', 'mTwo', 'mThree']; 
        List<String> multiTwoList = ['mFour', 'mFive', 'mSix'];
        dom.Element ulElem = createElement(singleList, multiOneList, multiTwoList);
        expect(ulElem).toBeNotNull();
        expect(ulElem.children.length).toBe(3);
        
        dom.Element singleElem = ulElem.querySelector('#single ul'); 
        dom.Element multiOneElem = ulElem.querySelector('#multiOne ul'); 
        swapMultiple(singleElem.children, 0, multiOneElem.children, 0);
        
        expect(singleList.length).toBe(3);
        expect(multiOneList.length).toBe(3);
        
        expect(singleList[0]).toBe('sOne');
        expect(multiOneList[0]).toBe('mOne');
      })));
      
      it('When the list is empty the parent must become droppable', async(inject(() {
        List<String> singleList = ['sOne', 'sTwo', 'sThree']; 
        List<String> multiOneList = []; 
        List<String> multiTwoList = ['mOne', 'mTwo', 'mThree', 'mFour', 'mFive', 'mSix'];
        dom.Element ulElem = createElement(singleList, multiOneList, multiTwoList);
        expect(ulElem).toBeNotNull();
        expect(ulElem.children.length).toBe(3);
        
        dom.Element multiOneElem = ulElem.querySelector('#multiOne');
        dom.Element multiTwoUlElem = ulElem.querySelector('#multiTwo ul'); 
        
        _.triggerEvent(multiTwoUlElem.children[3], 'dragstart', 'MouseEvent');
        _.triggerEvent(multiOneElem, 'drop', 'MouseEvent');
        
        expect(multiOneList.length).toBe(1);
        expect(multiTwoList.length).toBe(5);
        
        expect(multiTwoList[3]).toBe('mFive');
        expect(multiOneList[0]).toBe('mFour');
      })));
      
      it('When the list is NOT empty the parent must NOT be droppable', async(inject(() {
        List<String> singleList = ['sOne', 'sTwo', 'sThree']; 
        List<String> multiOneList = ['mOne']; 
        List<String> multiTwoList = ['mTwo', 'mThree', 'mFour', 'mFive', 'mSix'];
        dom.Element ulElem = createElement(singleList, multiOneList, multiTwoList);
        expect(ulElem).toBeNotNull();
        expect(ulElem.children.length).toBe(3);
        
        dom.Element multiOneElem = ulElem.querySelector('#multiOne');
        dom.Element multiTwoUlElem = ulElem.querySelector('#multiTwo ul'); 
        
        _.triggerEvent(multiTwoUlElem.children[0], 'dragstart', 'MouseEvent');
        _.triggerEvent(multiOneElem, 'drop', 'MouseEvent');
        
        expect(multiOneList.length).toBe(1);
        expect(multiTwoList.length).toBe(5);
        
        expect(multiOneList[0]).toBe('mOne');
        expect(multiTwoList[0]).toBe('mTwo');
        
      })));
    });

  });
}

