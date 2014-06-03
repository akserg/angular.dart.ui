// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.dragdrop;

class SortableConfig extends BaseDDConfig {
  SortableConfig() {
    onDragStartClass = "ui-sortable-dragging";
    onDragEnterClass = "ui-sortable-drag-enter";
    onDragOverClass = "ui-sortable-dragging";
  }
}

@Injectable()
class DragDropSortableDataService {
  int index;
  List sortableData;
}

@Decorator(selector: '[ui-sortable]',
    visibility: Directive.CHILDREN_VISIBILITY)
class SortableComponent extends AbstractDraggableDroppableComponent {
 
  DragDropConfigService dragDropConfigService;
  DragDropSortableDataService sortableDataService;
  SortableConfig sortableListConfig;
  List _sortableData = [];
  
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
  }
  get sortableZones => this._dropZoneNames;
  
  SortableComponent(html.Element elem, DragDropDataService dragDropService, DragDropConfigService dragDropConfigService, 
      DragDropSortableDataService sortableDataService, Scope scope)
  : super(elem, dragDropService, dragDropConfigService.dragDropConfig) {
   this.sortableDataService = sortableDataService;
   this.dragDropConfigService = dragDropConfigService;
   this.sortableListConfig = this.dragDropConfigService.sortableConfig;
   //print('SortableComponent started');
   
   //disable drag&drop effects on this element
   {
     this.config = new BaseDDConfig();
   }
   
   scope.watch(elem.attributes['ui-sortable-data'], (oldValue, newValue) {
     print("collection is changed");
     this.dropEnabled = _sortableData.isEmpty;
   }, collection: true); 

  }

  @override
  void onDragOverCallback(html.Event event) {
    
    print('drag node [' + sortableDataService.index.toString() + '] over parent node');
    _sortableData.add(sortableDataService.sortableData.removeAt(sortableDataService.index));
    sortableDataService.sortableData = _sortableData;
    sortableDataService.index = 0;

  }
  
}

@Decorator(selector: '[ui-sortable-item]')
class SortableItemComponent extends AbstractDraggableDroppableComponent {
  
  final SortableComponent sortableComponent;
  final DragDropSortableDataService sortableDataService;
  
  @NgOneWay('ui-sortable-item')
  int index;
  
  SortableItemComponent(this.sortableComponent, this.sortableDataService, html.Element elem, DragDropDataService dragDropService, DragDropConfigService ddcService)
    : super(elem, dragDropService, ddcService.sortableConfig) {
    this.dropZoneNames = this.sortableComponent.dropZoneNames;
    this.dragEnabled = true;
    this.dropEnabled = true;
  }
  
  @override
  void onDragStartCallback(html.Event event) {
    print('dragging elem with index ' + index.toString());
    sortableDataService.sortableData = sortableComponent._sortableData;
    sortableDataService.index = index;
  }
  
  @override
  void onDragOverCallback(html.Event event) {
    if ((index != sortableDataService.index) || (sortableDataService.sortableData != sortableComponent._sortableData)) {
              print('drag node [' + index.toString() + '] over node [' + sortableDataService.index.toString() + ']');
              sortableComponent._sortableData.insert(index, sortableDataService.sortableData.removeAt(sortableDataService.index));
              sortableDataService.sortableData = sortableComponent._sortableData;
              sortableDataService.index = index;
        }
  }
}
