// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.dragdrop;


@Decorator(selector: '[ui-droppable]')
class DroppableComponent extends AbstractDraggableDroppableComponent {

  @NgCallback("on-drop-success")
  Function onDropSuccessCallback;
  
  DragDropConfig ddConfig;
  
  @NgOneWay("ui-droppable")
  set dragdropConfig(var config) {
    if (!(config is DragDropConfig)) {
      return;
    }
    this.config = ddConfig = config as DragDropConfig; 
  }
  
  @NgOneWay("drop-zones")
  set dropZones (var dropZoneNames) {
    this.dropZoneNames = dropZoneNames;
  }
  
  DragDropDataService dragDropService;
  
  DroppableComponent(html.Element elem, DragDropZonesService ddZonesService, this.dragDropService, DragDropConfigService dragDropConfigService)
  : super(elem, ddZonesService, dragDropConfigService.dragDropConfig) {
    dragdropConfig = dragDropConfigService.dragDropConfig;
    this.dropEnabled = true;
  }

  @override
  void onDragEnterCallback(html.Event event) {
    elem.classes.add(ddConfig.onDragEnterClass);
  }

  @override
  void onDragLeaveCallback(html.Event event) {
    elem.classes.remove(ddConfig.onDragOverClass);
    elem.classes.remove(ddConfig.onDragEnterClass);
  }

  @override
  void onDragOverCallback(html.Event event) {
    elem.classes.add(ddConfig.onDragOverClass);
  }

  @override
  void onDropCallback(html.Event event) {
    if (onDropSuccessCallback!=null) {
      onDropSuccessCallback({'data':dragDropService.draggableData});
    }
    if(dragDropService.onDragSuccessCallback!=null){
      dragDropService.onDragSuccessCallback(); 
    }
    elem.classes.remove(ddConfig.onDragOverClass);
    elem.classes.remove(ddConfig.onDragEnterClass);
  }

}
