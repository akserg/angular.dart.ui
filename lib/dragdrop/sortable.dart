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
  int dragNodeId;
  List sourceList;
}

@Decorator(selector: '[ui-sortable]')
class SortableComponent extends AbstractDroppableComponent {
 
  final List<DisposableComponent> disposableComponents = [];
  DragDropConfigService dragDropConfigService;
  DragDropSortableDataService sortableDataService;
  List _sortableData = [];
  SortableConfig sortableListConfig;
  
  @NgTwoWay('ui-sortable-data')
  get sortableData => _sortableData;
  set sortableData (var sortableData) {
    if (sortableData is List) {
      _sortableData = sortableData as List;
    }
  }
  
  @NgOneWay('ui-sortable-zones')
  set sortableZones (var dropZones) {
    this.dropZoneNames = dropZones;
    updateList();
  }
  get sortableZones => this._dropZoneNames;
  
  void updateList({var ignoreElement}) {
    
    for (DisposableComponent comp in disposableComponents) {
      comp.dispose();
    }
    disposableComponents.clear();
    
    int node = 0;
    for(html.Element child in this.elem.children) {
      if ( child != ignoreElement) {
        int currentNodeCount = node;
        print("update node " + node.toString() + " - html: " + child.outerHtml);
        disposableComponents.add( new SortableDraggableComponent(child, dragDropService, this.sortableListConfig, sortableDataService, currentNodeCount, _sortableData, sortableZones));
        disposableComponents.add( new SortableDroppableComponent(child, dragDropService, this.sortableListConfig, sortableDataService, currentNodeCount, _sortableData, sortableZones));
        node++;
      } else {
        print("ignoring element " + child.outerHtml );
      }
    }
  }
  
  SortableComponent(html.Element elem, DragDropDataService dragDropService, DragDropConfigService dragDropConfigService, DragDropSortableDataService sortableDataService)
  : super(elem, dragDropService, dragDropConfigService.dragDropConfig) {
   this.sortableDataService = sortableDataService;
   this.dragDropConfigService = dragDropConfigService;
   this.sortableListConfig = this.dragDropConfigService.sortableConfig;
   this.enabled = false;
   this.sortableZones = new math.Random().nextDouble().toString();
   
   this.elem.addEventListener('DOMNodeInserted', (_) {
     print('DOMNodeInserted');
     updateList();
   });
   
   this.elem.addEventListener('DOMNodeRemoved', (html.Event event) {
     print('DOMNodeRemoved');
     updateList(ignoreElement: event.target);
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
  
  DragDropSortableDataService sortableDataService;
  int childId;
  List data;
  
  SortableDraggableComponent(html.Element elem, DragDropDataService dragDropService, AbstractDDConfig ddConfig, 
                             DragDropSortableDataService sortableDataService, int childId, List data, List<String> sortableZones) 
  : super(elem, dragDropService, ddConfig) {
    this.sortableDataService = sortableDataService;
    this.childId = childId;
    this.data = data;
    this.dropZoneNames = sortableZones;
  }

  @override
  void onDragEndCallback(html.Event event) {
  }

  @override
  void onDragStartCallback(html.Event event) {
    sortableDataService.dragNodeId = childId;
    sortableDataService.sourceList = data;
    print('start dragging node [' + childId.toString() + ']');
  }

}

class SortableDroppableComponent extends AbstractDroppableComponent {
  
  DragDropSortableDataService sortableDataService;
  int childId;
  List data;
  
  SortableDroppableComponent(html.Element elem, DragDropDataService dragDropService, AbstractDDConfig config,DragDropSortableDataService sortableDataService, int childId, List data, List<String> sortableZones)
  : super(elem, dragDropService, config) {
    this.sortableDataService = sortableDataService;
    this.childId = childId;
    this.data = data;
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
    if ((sortableDataService.dragNodeId != childId) || (sortableDataService.sourceList != data)) {
              print('drag node [' + sortableDataService.dragNodeId.toString() + '] over node [' + childId.toString() + ']');
              data.insert(childId, sortableDataService.sourceList.removeAt(sortableDataService.dragNodeId));    
              sortableDataService.dragNodeId = childId;
              sortableDataService.sourceList = data;
        }
  }

  @override
  void onDropCallback(html.Event event) {
  }
  
}
