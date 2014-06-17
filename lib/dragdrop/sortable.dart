// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.dragdrop;

class SortableConfig extends BaseDDConfig {
    String onSortableDraggingClass = "ui-sortable-dragging";
    String onSortableDragEnterClass = "ui-sortable-drag-enter";
}

@Injectable()
class DragDropSortableDataService {
  int index;
  List sortableData;
  
  html.Element _elem;
  SortableConfig _config;
  void element(html.Element elem, SortableConfig config) {
    if (_elem != null) {
      _elem.classes.remove(_config.onSortableDraggingClass);
    }
    if (elem != null) {
      _elem = elem;
      _config = config;
      _elem.classes.add(_config.onSortableDraggingClass);
    }
  }
}

@Decorator(selector: '[ui-sortable]',
    visibility: Directive.CHILDREN_VISIBILITY)
class SortableComponent extends AbstractDraggableDroppableComponent {
 
  DragDropSortableDataService sortableDataService;
  SortableConfig _sortableConfig;
  List _sortableData = [];
  
  @NgTwoWay('ui-sortable-data')
  List get sortableData => _sortableData;
  set sortableData (var sortableData) {
    if (sortableData is List) {
      _sortableData = sortableData as List;
      onSortableDataChange();
    }
  }

  @NgOneWay("ui-sortable")
  set sortableConfig(var config) {
    if (!(config is SortableConfig)) {
      return;
    }
    this.config = _sortableConfig = config as SortableConfig; 
  }
  
  @NgOneWay('ui-sortable-zones')
  set sortableZones (var dropZones) {
    this.dropZoneNames = dropZones;
  }
  List<String> get sortableZones => this._dropZoneNames;
  
  SortableComponent(html.Element elem, DragDropDataService dragDropService, DragDropConfigService dragDropConfigService, 
      DragDropSortableDataService sortableDataService, Scope scope)
  : super(elem, dragDropService, dragDropConfigService.dragDropConfig) {
   this.sortableDataService = sortableDataService;
   this.sortableConfig = dragDropConfigService.sortableConfig;
   //print('SortableComponent started');
   
   //disable drag&drop effects on this element
   {
     this.config = new BaseDDConfig();
   }
   
   scope.watch(elem.attributes['ui-sortable-data'], (oldValue, newValue) {
     onSortableDataChange();
   }, collection: true); 

  }

  @override
  void onDragEnterCallback(html.Event event) {
    
    _log.finer('drag node [' + sortableDataService.index.toString() + '] over parent node');
    _sortableData.add(sortableDataService.sortableData.removeAt(sortableDataService.index));
    sortableDataService.sortableData = _sortableData;
    sortableDataService.index = 0;

  }
  
  void onSortableDataChange() {
    this.dropEnabled = _sortableData.isEmpty;
    _log.finer("collection is changed, drop enabled: " + this.dropEnabled.toString());
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
    _log.finer('dragging elem with index ' + index.toString());
    sortableDataService.sortableData = sortableComponent._sortableData;
    sortableDataService.index = index;
    sortableDataService.element(elem, sortableComponent._sortableConfig);
    //html.Element dragTarget = event.target;
   //dragTarget.classes.add(sortableComponent._sortableConfig.onSortableDraggingClass);
  }
  
  @override
  void onDragLeaveCallback(html.Event event) {
    //html.Element dragTarget = event.target;
    //dragTarget.classes.remove(sortableComponent._sortableConfig.onSortableDraggingClass);
  }
  
  @override
  void onDragEndCallback(html.Event event) {
    sortableDataService.sortableData = null;
    sortableDataService.index = null;
    sortableDataService.element(null, sortableComponent._sortableConfig);
    //html.Element dragTarget = event.target;
    //dragTarget.classes.remove(sortableComponent._sortableConfig.onSortableDraggingClass);
  }
  
  @override
  void onDragEnterCallback(html.Event event) {
    //elem.classes.add(sortableComponent._sortableConfig.onSortableDraggingClass);
    sortableDataService.element(elem, sortableComponent._sortableConfig);
    /*
    print("-------------------------------------------------------");
    print("sortableDataService = " + sortableDataService.toString());
    print("sortableComponent = " + sortableComponent.toString());
    print("_sortableData = " + sortableComponent._sortableData.toString());
    print("index = " + index.toString());
    print("sortableDataService.index = " + sortableDataService.index.toString());
    print("sortableDataService.sortableData = " + sortableDataService.sortableData.toString());
   */
    if ((index != sortableDataService.index) || (sortableDataService.sortableData != sortableComponent._sortableData)) {
      _log.finer('drag node [' + index.toString() + '] over node [' + sortableDataService.index.toString() + ']');
              sortableComponent._sortableData.insert(index, sortableDataService.sortableData.removeAt(sortableDataService.index));
              sortableDataService.sortableData = sortableComponent._sortableData;
              sortableDataService.index = index;
              //elem.classes.add(sortableComponent._sortableConfig.onSortableDragEnterClass);
        }
    //print("-------------------------------------------------------");
  }
}
