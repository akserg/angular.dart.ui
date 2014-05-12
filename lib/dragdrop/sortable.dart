// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.dragdrop;

class SortableConfig extends AbstractDDConfig {
  SortableConfig() {
    onDragStartClass = "ui-sortable-drag-start";
    onDragEnterClass = "ui-sortable-drag-enter";
    onDragOverClass = "ui-sortable-drag-over";
  }
}

@Decorator(selector: '[ui-sortable]')
class SortableComponent extends AbstractDroppableComponent {
 
  final List<DisposableComponent> disposableComponents = [];
  DragDropConfigService dragDropConfigService;
  List _sortableData = [];
  SortableConfig sortableListConfig;
  
  int dragNodeId;
  
  @NgTwoWay('sortable-data')
  get sortableData => _sortableData;
  set sortableData (var sortableData) {
    if (sortableData is List) {
      _sortableData = sortableData as List;
    }
  }
  
  void updateList() {
    
    for (DisposableComponent comp in disposableComponents) {
      comp.dispose();
    }
    disposableComponents.clear();
    
    int node = 0;
    for(html.Element child in this.elem.children) {
      int currentNodeCount = node;
      print("set " + child.toString() + " as draggable"); 
      
      disposableComponents.add( new SortableDraggableComponent(child, dragDropService, this.sortableListConfig, (html.Event event) {
        dragNodeId = currentNodeCount;
        print('start dragging node [' + dragNodeId.toString() + ']');
      }));
      
      disposableComponents.add( new SortableDroppableComponent(child, dragDropService, this.sortableListConfig, (html.Event event) {
        if (dragNodeId != currentNodeCount) {
          print('drag node [' + dragNodeId.toString() + '] over node [' + currentNodeCount.toString() + ']');
          _sortableData.insert(currentNodeCount, _sortableData.removeAt(dragNodeId));    
          dragNodeId = currentNodeCount;
        }
      }));
      node++;
    }
  }
  
  SortableComponent(html.Element elem, DragDropDataService dragDropService, DragDropConfigService dragDropConfigService)
  : super(elem, dragDropService, dragDropConfigService.dragDropConfig) {
   this.dragDropConfigService = dragDropConfigService;
   this.sortableListConfig = this.dragDropConfigService.sortableConfig;
   this.enabled = false;
   
   this.elem.addEventListener('DOMNodeInserted', (_) {
     print('node added');
     updateList();
   });

  }

  @override
  void onDragEnterCallback(html.Event event) {
  }

  @override
  void onDragLeaveCallback(html.Event event) {
  }

  @override
  void onDragOverCallback(html.Event event) {
  }

  @override
  void onDropCallback(html.Event event) {
  }
  
}

class SortableDraggableComponent extends AbstractDraggableComponent {
  
  Function dragStartCallback;  
  
  SortableDraggableComponent(html.Element elem, DragDropDataService dragDropService, AbstractDDConfig ddConfig, 
      void dragStartCallback(html.Event event)) 
  : super(elem, dragDropService, ddConfig) {
    this.dragStartCallback = dragStartCallback;
  }

  @override
  void onDragEndCallback(html.Event event) {
  }

  @override
  void onDragStartCallback(html.Event event) {
    dragStartCallback(event);
  }

}

class SortableDroppableComponent extends AbstractDroppableComponent {
  
  Function onDragOver;  
  
  SortableDroppableComponent(html.Element elem, DragDropDataService dragDropService, AbstractDDConfig config, void onDragOver(html.Event event))
  : super(elem, dragDropService, config) {
    this.onDragOver = onDragOver;
  }

  @override
  void onDragEnterCallback(html.Event event) {
  }

  @override
  void onDragLeaveCallback(html.Event event) {
  }

  @override
  void onDragOverCallback(html.Event event) {
    onDragOver(event);
  }

  @override
  void onDropCallback(html.Event event) {
  }
  
}
