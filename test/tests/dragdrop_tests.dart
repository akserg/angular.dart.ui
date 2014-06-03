// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void dragdropTests() {

  describe('Drag&Drop - ', () {
    
    TestBed _;
    Scope scope;
    DragDropDataService ddDataService;
    DragDropConfigService ddConfig;
    
    beforeEach(() {
      setUpInjector();
      module((Module module) {
        module.install(new DragDropModule());
      });
      inject((TestBed tb, Scope s, DragDropDataService injDragDropDataService,DragDropConfigService injDragDropConfig) { 
        _ = tb;
        scope = s;
        ddDataService = injDragDropDataService;
        ddConfig = injDragDropConfig;
      });
    });
    
    afterEach(tearDownInjector);

    group('Draggable and Droppable directives -', () {
      
      var dragData = "Hello World at " + new DateTime.now().toString();
      
      dom.Element createElement({bool dragEnabled : true, Function dragSuccessCallback, Function dropSuccessCallback }) {
        
        scope.context['dragEnabled'] = dragEnabled;
        scope.context['dragData'] = dragData;
        scope.context['dragSuccessCallback'] = dragSuccessCallback;
        scope.context['dropSuccessCallback'] = dropSuccessCallback;
        String html =
        '''<div>
          <div id='dragId'
            ui-draggable 
            draggable-enabled="dragEnabled" 
            draggable-data="dragData" 
            allowed-drop-zones="'test1'"
            on-drag-success="dragSuccessCallback()">
          </div>
          <div id='dropId'
            ui-droppable 
            drop-zones="'test1'"
            on-drop-success="dropSuccessCallback(data)">
          </div>
        </div>''';
        dom.Element element = _.compile(html.trim());
        
        microLeap();
        scope.rootScope.apply();
        
        return element;
      };
      
      it('It should add the "draggable" attribute', async(inject(() {
        dom.Element dragElem = ngQuery(createElement(), '#dragId')[0];
        expect(dragElem).toBeNotNull();
        expect(dragElem.attributes['draggable']).toBeTruthy();
      })));
      
      it('The "draggable" attribute must be false if the drag is not enabled', async(inject(() {
        dom.Element dragElem = ngQuery(createElement(dragEnabled: false), '#dragId')[0];
        expect(dragElem).toBeNotNull();
        expect(dragElem.attributes['draggable']).toEqual('false');
      })));
      
      it('Drag events should add/remove the draggable data to/from the DragDropDataService', async(inject(() {
        dom.Element dragElem = ngQuery(createElement(), '#dragId')[0];
        
        expect(ddDataService.draggableData).toBeNull();
        _.triggerEvent(dragElem, 'dragstart', 'MouseEvent');
        expect(ddDataService.draggableData).toBe(dragData);
        _.triggerEvent(dragElem, 'dragend', 'MouseEvent');
        expect(ddDataService.draggableData).toBeNull();
        
      })));
      
      it('Drag events should add/remove the expected classes to the target element', async(inject(() {
        dom.Element dragElem = ngQuery(createElement(), '#dragId')[0];
        
        expect(dragElem).not.toHaveClass(ddConfig.dragDropConfig.onDragStartClass);
        _.triggerEvent(dragElem, 'dragstart', 'MouseEvent');
        expect(dragElem).toHaveClass(ddConfig.dragDropConfig.onDragStartClass);
        _.triggerEvent(dragElem, 'dragend', 'MouseEvent');
        expect(dragElem).not.toHaveClass(ddConfig.dragDropConfig.onDragStartClass);
        
      })));

      it('Drag start event should not be activated if drag is not enabled', async(inject(() {
        dom.Element dragElem = ngQuery(createElement(dragEnabled: false), '#dragId')[0];
        
        expect(ddDataService.draggableData).toBeNull();
        expect(dragElem).not.toHaveClass(ddConfig.dragDropConfig.onDragStartClass);
        _.triggerEvent(dragElem, 'dragstart', 'MouseEvent');
        expect(ddDataService.draggableData).toBeNull();
        expect(dragElem).not.toHaveClass(ddConfig.dragDropConfig.onDragStartClass);
        
      })));
 
      it('Drop events should add/remove the expected classes to the target element', async(inject(() {
        Function dragSuccessCallback = jasmine.createSpy('drag callback');
        Function dropSuccessCallback = jasmine.createSpy('drop callback');
        
        dom.Element elem = createElement(dropSuccessCallback:dropSuccessCallback, dragSuccessCallback:dragSuccessCallback);
        dom.Element dropElem = ngQuery(elem, '#dropId')[0];
        dom.Element dragElem = ngQuery(elem, '#dragId')[0];
        
        expect(dropElem).not.toHaveClass(ddConfig.dragDropConfig.onDragEnterClass);
        expect(dropElem).not.toHaveClass(ddConfig.dragDropConfig.onDragOverClass);
        
        //The drop events should not work before a drag is started on an element with the correct drop-zone
        _.triggerEvent(dropElem, 'dragenter', 'MouseEvent');
        expect(dropElem).not.toHaveClass(ddConfig.dragDropConfig.onDragEnterClass);
        
        _.triggerEvent(dragElem, 'dragstart', 'MouseEvent');
        
        _.triggerEvent(dropElem, 'dragenter', 'MouseEvent');
        expect(dropElem).toHaveClass(ddConfig.dragDropConfig.onDragEnterClass);
        expect(dropElem).not.toHaveClass(ddConfig.dragDropConfig.onDragOverClass);
 
        _.triggerEvent(dropElem, 'dragover', 'MouseEvent');
        expect(dropElem).toHaveClass(ddConfig.dragDropConfig.onDragEnterClass);
        expect(dropElem).toHaveClass(ddConfig.dragDropConfig.onDragOverClass);
        
        _.triggerEvent(dropElem, 'dragleave', 'MouseEvent');
        expect(dropElem).not.toHaveClass(ddConfig.dragDropConfig.onDragEnterClass);
        expect(dropElem).not.toHaveClass(ddConfig.dragDropConfig.onDragOverClass);

        _.triggerEvent(dropElem, 'dragover', 'MouseEvent');
        _.triggerEvent(dropElem, 'dragenter', 'MouseEvent');
        _.triggerEvent(dropElem, 'drop', 'MouseEvent');
        expect(dropElem).not.toHaveClass(ddConfig.dragDropConfig.onDragEnterClass);
        expect(dropElem).not.toHaveClass(ddConfig.dragDropConfig.onDragOverClass);
      })));
      
      it('Drop event should activate the onDropSuccess and onDragSuccess callbacks', async(inject(() {
        Function dragSuccessCallback = jasmine.createSpy('drag callback');
        Function dropSuccessCallback = jasmine.createSpy('drop callback');
            
        dom.Element mainElement = createElement(dropSuccessCallback:dropSuccessCallback, dragSuccessCallback:dragSuccessCallback);
        dom.Element dragElem = ngQuery(mainElement, '#dragId')[0];
        dom.Element dropElem = ngQuery(mainElement, '#dropId')[0];
          
        _.triggerEvent(dragElem, 'dragstart', 'MouseEvent');
        _.triggerEvent(dragElem, 'dragend', 'MouseEvent');
        expect(dragSuccessCallback).not.toHaveBeenCalled();
        expect(dropSuccessCallback).not.toHaveBeenCalled();
        
        _.triggerEvent(dragElem, 'dragstart', 'MouseEvent');
        _.triggerEvent(dropElem, 'drop', 'MouseEvent');
        expect(dropSuccessCallback).toHaveBeenCalledOnce();
        expect(dragSuccessCallback).toHaveBeenCalledOnce();
      })));
      
      it('The onDropSuccess callback should receive the dragged data as paramenter', async(inject(() {
        Function dragSuccessCallback = () {};
        
        bool dropCallbackCalled = false;
        var dropCallbackReceivedData;
        Function dropSuccessCallback = (var data) {
          dropCallbackCalled = true;
          dropCallbackReceivedData = data;
        };
            
        dom.Element mainElement = createElement(dropSuccessCallback:dropSuccessCallback, dragSuccessCallback:dragSuccessCallback);
        dom.Element dragElem = ngQuery(mainElement, '#dragId')[0];
        dom.Element dropElem = ngQuery(mainElement, '#dropId')[0];
          
        _.triggerEvent(dragElem, 'dragstart', 'MouseEvent');
        _.triggerEvent(dropElem, 'drop', 'MouseEvent');
        expect(dropCallbackCalled).toBeTruthy();
        expect(dropCallbackReceivedData).toBe(dragData);
      })));
    

      it('Drop zones should be correctly evaluated by the DroppableComponent', async(inject(() {
        DragDropDataService ddService = new DragDropDataService();
        DroppableComponent droppableComponent = new DroppableComponent(new dom.DivElement(), ddService, new DragDropConfigService());
        
        droppableComponent.dropZones = [];
        ddService.allowedDropZones = [];
        expect(droppableComponent.isDropAllowed()).toBeTruthy();
        
        droppableComponent.dropZones = 'zone1';
        ddService.allowedDropZones = [];
        expect(droppableComponent.isDropAllowed()).toBeFalsy();
  
        droppableComponent.dropZones = [];
        ddService.allowedDropZones = ['zone1'];
        expect(droppableComponent.isDropAllowed()).toBeFalsy();
        
        droppableComponent.dropZones = 'zone1';
        ddService.allowedDropZones = ['zone1','zone3'];
        expect(droppableComponent.isDropAllowed()).toBeTruthy();
        
        droppableComponent.dropZones = ['zone1','zone4'];
        ddService.allowedDropZones = ['zone1','zone3'];
        expect(droppableComponent.isDropAllowed()).toBeTruthy();
        
        droppableComponent.dropZones = ['zone1','zone4'];
        ddService.allowedDropZones = ['zone2'];
        expect(droppableComponent.isDropAllowed()).toBeFalsy();
        
      })));
      
    });
    
    group('Drop Zones -', () {
          
          dom.Element createElement() {
            
            scope.context['dragOneSuccessCallback'] = jasmine.createSpy('drag one callback');
            scope.context['dragTwoSuccessCallback'] = jasmine.createSpy('drag two callback');
            scope.context['dragOneTwoSuccessCallback'] = jasmine.createSpy('drag one-two callback');
            scope.context['dropOneSuccessCallback'] = jasmine.createSpy('drop one callback');
            scope.context['dropTwoSuccessCallback'] = jasmine.createSpy('drop two callback');
            scope.context['dropOneTwoSuccessCallback'] = jasmine.createSpy('drop one-two callback');
            String html =
            '''<div>
              <div id='dragIdOne'
                ui-draggable 
                allowed-drop-zones="'zone-one'"
                on-drag-success="dragOneSuccessCallback()">
              </div>
              <div id='dragIdTwo'
                ui-draggable 
                allowed-drop-zones="'zone-two'"
                on-drag-success="dragTwoSuccessCallback()">
              </div>
              <div id='dragIdOneTwo'
                ui-draggable 
                allowed-drop-zones="['zone-one','zone-two']"
                on-drag-success="dragOneTwoSuccessCallback()">
              </div>
              <div id='dropIdOne'
                ui-droppable 
                drop-zones="'zone-one'"
                on-drop-success="dropOneSuccessCallback(data)">
              </div>
              <div id='dropIdTwo'
                ui-droppable 
                drop-zones="'zone-two'"
                on-drop-success="dropTwoSuccessCallback(data)">
              </div>
              <div id='dropIdOneTwo'
                ui-droppable 
                drop-zones="['zone-one','zone-two']"
                on-drop-success="dropOneTwoSuccessCallback(data)">
              </div>
            </div>''';
            dom.Element element = _.compile(html.trim());
            
            microLeap();
            scope.rootScope.apply();
            
            return element;
          };
          
          it('Drop events should not be activated on the wrong drop-zone', async(inject(() {
            dom.Element mainElement = createElement();
            dom.Element dragElemOne = ngQuery(mainElement, '#dragIdOne')[0];
            dom.Element dropElemTwo = ngQuery(mainElement, '#dropIdTwo')[0];
              
            _.triggerEvent(dragElemOne, 'dragstart', 'MouseEvent');
            
            _.triggerEvent(dropElemTwo, 'dragenter', 'MouseEvent');
            expect(dropElemTwo).not.toHaveClass(ddConfig.dragDropConfig.onDragEnterClass);
            
            _.triggerEvent(dropElemTwo, 'dragover', 'MouseEvent');
            expect(dropElemTwo).not.toHaveClass(ddConfig.dragDropConfig.onDragOverClass);
            
            _.triggerEvent(dragElemOne, 'drop', 'MouseEvent');
            expect(scope.context['dragOneSuccessCallback']).not.toHaveBeenCalled();
            expect(scope.context['dropTwoSuccessCallback']).not.toHaveBeenCalled();
          })));
          
          it('Drop events should be activated on the same drop-zone', async(inject(() {
            dom.Element mainElement = createElement();
            dom.Element dragElemOne = ngQuery(mainElement, '#dragIdOne')[0];
            dom.Element dropElemOne = ngQuery(mainElement, '#dropIdOne')[0];
              
            _.triggerEvent(dragElemOne, 'dragstart', 'MouseEvent');
            
            _.triggerEvent(dropElemOne, 'dragenter', 'MouseEvent');
            expect(dropElemOne).toHaveClass(ddConfig.dragDropConfig.onDragEnterClass);
            
            _.triggerEvent(dropElemOne, 'dragover', 'MouseEvent');
            expect(dropElemOne).toHaveClass(ddConfig.dragDropConfig.onDragOverClass);
            
            _.triggerEvent(dropElemOne, 'drop', 'MouseEvent');
            expect(scope.context['dragOneSuccessCallback']).toHaveBeenCalled();
            expect(scope.context['dropOneSuccessCallback']).toHaveBeenCalled();
          })));
          
          it('Drop events on multiple drop-zone', async(inject(() {
            dom.Element mainElement = createElement();
            dom.Element dragElemOneTwo = ngQuery(mainElement, '#dragIdOneTwo')[0];
            dom.Element dropElemOneTwo = ngQuery(mainElement, '#dropIdOneTwo')[0];
              
            _.triggerEvent(dragElemOneTwo, 'dragstart', 'MouseEvent');
            
            _.triggerEvent(dropElemOneTwo, 'dragenter', 'MouseEvent');
            expect(dropElemOneTwo).toHaveClass(ddConfig.dragDropConfig.onDragEnterClass);
            
            _.triggerEvent(dropElemOneTwo, 'dragover', 'MouseEvent');
            expect(dropElemOneTwo).toHaveClass(ddConfig.dragDropConfig.onDragOverClass);
            
            _.triggerEvent(dropElemOneTwo, 'drop', 'MouseEvent');
            expect(scope.context['dragOneTwoSuccessCallback']).toHaveBeenCalled();
            expect(scope.context['dropOneTwoSuccessCallback']).toHaveBeenCalled();
          })));
          
        });
    
  });
}

