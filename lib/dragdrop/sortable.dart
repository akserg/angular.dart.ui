// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.dragdrop;

class SortableConfig extends AbstractDDConfig {
  SortableConfig() {
    onDragStartClass = "ui-sortable-dragging";
    onDragEnterClass = "ui-sortable-drag-enter";
    onDragOverClass = "ui-sortable-dragging";
  }
}

@Injectable()
class DragDropSortableDataService {
  var sortableData;
  List sourceList;
}

@Decorator(selector: '[ui-sortable]',
    visibility: Directive.CHILDREN_VISIBILITY)
class SortableComponent extends AbstractDroppableComponent {
 
  DragDropConfigService dragDropConfigService;
  DragDropSortableDataService sortableDataService;
  SortableConfig sortableListConfig;
  SortableDataComponent sortableDataComponent;
  
  @NgOneWay('ui-sortable-zones')
  set sortableZones (var dropZones) {
    this.dropZoneNames = dropZones;
    refresh();
  }
  get sortableZones => this._dropZoneNames;
  
  SortableComponent(html.Element elem, DragDropDataService dragDropService, DragDropConfigService dragDropConfigService, DragDropSortableDataService sortableDataService)
  : super(elem, dragDropService, dragDropConfigService.dragDropConfig) {
   this.sortableDataService = sortableDataService;
   this.dragDropConfigService = dragDropConfigService;
   this.sortableListConfig = this.dragDropConfigService.sortableConfig;
   this.enabled = false;
   //print('SortableComponent started');
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
    if(this.sortableDataComponent != null) {
      int dragNodeId = sortableDataService.sourceList.indexOf(sortableDataService.sortableData);
      print('drag node [' + dragNodeId.toString() + '] over parent node');
      sortableDataComponent._sortableData.add(sortableDataService.sourceList.removeAt(dragNodeId));
    }
  }
  
  void refresh() {
    if(this.sortableDataComponent != null) {
      this.sortableDataComponent.updateList();
    }
  }
  
}

@Decorator(selector: '[ui-sortable-data]')
class SortableDataComponent {
 
  final SortableComponent sortableComponent;
  final html.Element elem;
  final List<DisposableComponent> disposableComponents = [];
  final DragDropDataService dragDropService;
  final DragDropConfigService dragDropConfigService;
  final DragDropSortableDataService sortableDataService;
  List _sortableData = [];
  
  @NgTwoWay('ui-sortable-data')
  get sortableData => _sortableData;
  set sortableData (var sortableData) {
    if (sortableData is List) {
      _sortableData = sortableData as List;
    }
  }
  
  void updateList({var ignoreElement}) {
    
    for (DisposableComponent comp in disposableComponents) {
      comp.dispose();
    }
    disposableComponents.clear();
    
    int node = 0;
    for(html.Element child in this.elem.children) {
      if ( child != ignoreElement) {
        int currentNodeCount = node;
        //print("update node " + node.toString() + " - html: " + child.outerHtml);
        disposableComponents.add( new SortableDraggableComponent(child, dragDropService, sortableComponent.sortableListConfig, 
            sortableDataService, _sortableData, _sortableData[currentNodeCount], sortableComponent.sortableZones));
        disposableComponents.add( new SortableDroppableComponent(child, dragDropService, sortableComponent.sortableListConfig, 
            sortableDataService, _sortableData, _sortableData[currentNodeCount], sortableComponent.sortableZones));
        node++;
      } else {
        //print("ignoring element " + child.outerHtml );
      }
    }
    this.sortableComponent.enabled = _sortableData.isEmpty;
  }
  
  SortableDataComponent(Scope scope, this.elem, this.dragDropService, this.dragDropConfigService, this.sortableDataService, this.sortableComponent) {
    this.sortableComponent.sortableDataComponent = this;
    
    //print('SortableDataComponent started');
    /*
    scope.watch(elem.attributes['ui-sortable-data'], (oldValue, newValue) {
      print("collection is changed");
      updateList();
    }, collection: true); 
    */
   this.elem.addEventListener('DOMNodeInserted', (_) {
     //print('DOMNodeInserted');
     updateList();
   });
   
   this.elem.addEventListener('DOMNodeRemoved', (html.Event event) {
     //print('DOMNodeRemoved');
     updateList(ignoreElement: event.target);
   });
  }
}

class SortableDraggableComponent extends AbstractDraggableComponent {
  
  DragDropSortableDataService sortableDataService;
  List data;
  var sortableData;
  
  SortableDraggableComponent(html.Element elem, DragDropDataService dragDropService, AbstractDDConfig ddConfig, 
                             DragDropSortableDataService sortableDataService, List data, var sortableData, List<String> sortableZones) 
  : super(elem, dragDropService, ddConfig) {
    this.sortableDataService = sortableDataService;
    this.data = data;
    this.sortableData = sortableData;
    this.dropZoneNames = sortableZones;
  }

  @override
  void onDragEndCallback(html.Event event) {
  }

  @override
  void onDragStartCallback(html.Event event) {
    sortableDataService.sortableData = sortableData;
    sortableDataService.sourceList = data;
    print('start dragging node [' + data.indexOf(sortableData).toString() + ']');
  }

}

class SortableDroppableComponent extends AbstractDroppableComponent {
  
  DragDropSortableDataService sortableDataService;
  List data;
  var sortableData;
  
  SortableDroppableComponent(html.Element elem, DragDropDataService dragDropService, AbstractDDConfig config,
      DragDropSortableDataService sortableDataService, List data, var sortableData, List<String> sortableZones)
  : super(elem, dragDropService, config) {
    this.sortableDataService = sortableDataService;
    this.data = data;
    this.sortableData = sortableData;
    this.dropZoneNames = sortableZones;
  }

  @override
  void onDragEnterCallback(html.Event event) {
  }

  @override
  void onDragLeaveCallback(html.Event event) {
  }

  @override
  void onDragOverCallback(html.Event event) {
    int currentNodeId = data.indexOf(sortableData);
    int dragNodeId = sortableDataService.sourceList.indexOf(sortableDataService.sortableData);
    if ((currentNodeId != dragNodeId) || (sortableDataService.sourceList != data)) {
              print('drag node [' + dragNodeId.toString() + '] over node [' + currentNodeId.toString() + ']');
              data.insert(currentNodeId, sortableDataService.sourceList.removeAt(dragNodeId));
              sortableDataService.sourceList = data;
              //sortableDataService.sortableData = data[currentNodeId];
        }
  }

  @override
  void onDropCallback(html.Event event) {
    sortableDataService.sourceList = null;
    sortableDataService.sortableData = null;
  }
  
}
