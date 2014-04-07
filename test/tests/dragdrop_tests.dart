// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void dragdropTests() {

  describe('Drag&Drop', () {
    
    TestBed _;
    Scope scope;
    DragDropDataService ddDataService;
    DragDropConfig ddConfig;
    
    beforeEach(() {
      setUpInjector();
      module((Module module) {
        module.install(new DragDropModule());
      });
      inject((TestBed tb, Scope s, DragDropDataService injDragDropDataService,DragDropConfig injDragDropConfig) { 
        _ = tb;
        scope = s;
        ddDataService = injDragDropDataService;
        ddConfig = injDragDropConfig;
      });
    });
    
    afterEach(tearDownInjector);
  
    group('Draggable and Droppable directives', () {
      
      var dragData = "Hello World at " + new DateTime.now().toString();
      dom.Element elem;
      
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
            on-drag-success="dragSuccessCallback()">
          </div>
          <div id='dropId'
            ui-droppable 
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
        
        expect(dragElem).not.toHaveClass(ddConfig.onDragStartClass);
        _.triggerEvent(dragElem, 'dragstart', 'MouseEvent');
        expect(dragElem).toHaveClass(ddConfig.onDragStartClass);
        _.triggerEvent(dragElem, 'dragend', 'MouseEvent');
        expect(dragElem).not.toHaveClass(ddConfig.onDragStartClass);
        
      })));

      it('Drag start event should not be activated if drag is not enabled', async(inject(() {
        dom.Element dragElem = ngQuery(createElement(dragEnabled: false), '#dragId')[0];
        
        expect(ddDataService.draggableData).toBeNull();
        expect(dragElem).not.toHaveClass(ddConfig.onDragStartClass);
        _.triggerEvent(dragElem, 'dragstart', 'MouseEvent');
        expect(ddDataService.draggableData).toBeNull();
        expect(dragElem).not.toHaveClass(ddConfig.onDragStartClass);
        
      })));
 
      it('Drop events should add/remove the expected classes to the target element', async(inject(() {
        Function dropSuccessCallback = (){};
        dom.Element dropElem = ngQuery(createElement(dropSuccessCallback:dropSuccessCallback), '#dropId')[0];
        
        expect(dropElem).not.toHaveClass(ddConfig.onDragEnterClass);
        expect(dropElem).not.toHaveClass(ddConfig.onDragOverClass);
        
        _.triggerEvent(dropElem, 'dragenter', 'MouseEvent');
        expect(dropElem).toHaveClass(ddConfig.onDragEnterClass);
        expect(dropElem).not.toHaveClass(ddConfig.onDragOverClass);
 
        _.triggerEvent(dropElem, 'dragover', 'MouseEvent');
        expect(dropElem).toHaveClass(ddConfig.onDragEnterClass);
        expect(dropElem).toHaveClass(ddConfig.onDragOverClass);
        
        _.triggerEvent(dropElem, 'dragleave', 'MouseEvent');
        expect(dropElem).not.toHaveClass(ddConfig.onDragEnterClass);
        expect(dropElem).not.toHaveClass(ddConfig.onDragOverClass);

        _.triggerEvent(dropElem, 'dragover', 'MouseEvent');
        _.triggerEvent(dropElem, 'dragenter', 'MouseEvent');
        _.triggerEvent(dropElem, 'drop', 'MouseEvent');
        expect(dropElem).not.toHaveClass(ddConfig.onDragEnterClass);
        expect(dropElem).not.toHaveClass(ddConfig.onDragOverClass);
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
    });

  });
}

