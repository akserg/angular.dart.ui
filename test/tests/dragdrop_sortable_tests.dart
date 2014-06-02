// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void dragdropSortableTests() {

  describe('Drag&Drop-Sortable', () {
    
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
    
    afterEach(() {
      tearDownInjector();
      dom.document.body = new dom.BodyElement();
    });

    group('Single List Sortable', () {
      
      dom.Element createElement(List<String> sortableList) {
        
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
        
        //Needed to throw the DOMNodeInserted and DOMNodeRemoved events
        dom.document.body.append(element);
        
        scope.context['data']['sortableList'] = sortableList;

        microLeap();
        scope.rootScope.apply();
        
        return element;
      };
      
      void swapMultiple(List<dom.Element> nodesOne, int firstNodeId, List<dom.Element> nodesTwo, int secondNodeId) {
        _.triggerEvent(nodesOne[firstNodeId], 'dragstart', 'MouseEvent');
        _.triggerEvent(nodesTwo[secondNodeId], 'dragover', 'MouseEvent');
      }
      
      void swap(List<dom.Element> nodes, int firstNodeId, int secondNodeId) {
        swapMultiple(nodes, firstNodeId, nodes, secondNodeId);
      }
      
      it('It should sort in the same list', async(inject(() {
        List<String> values = ['one','two','three','four'];
        dom.Element ulElem = ngQuery(createElement(values), 'ul')[0];
        expect(ulElem).toBeNotNull();
        expect(ulElem.children.length).toBe(4);
        expect(ulElem.children[0].attributes['draggable']).toBeTruthy();
        
        expect(ddsDataService.dragNodeId).toBeNull();
        expect(ddsDataService.sourceList).toBeNull();
        _.triggerEvent(ulElem.children[0], 'dragstart', 'MouseEvent');
        expect(ddsDataService.dragNodeId).toBe(0);
        expect(ddsDataService.sourceList).toBe(values);
        
        swap(ulElem.children, 0, 1);
        expect(values[0]).toBe('two');
        expect(ulElem.children[0].text).toEqual('two');
        expect(values[1]).toBe('one');
        expect(ulElem.children[1].text).toEqual('one');
      })));
      
    });
  });
}

