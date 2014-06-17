// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.dragdrop;

@Decorator(selector: '[ui-draggable]',
  visibility: Directive.CHILDREN_VISIBILITY)
class DraggableComponent extends AbstractDraggableDroppableComponent {

  @NgOneWay("draggable-enabled")
  set draggable(bool value) {
    if(value!=null) {
      dragEnabled = value;
    }
  }
  @NgOneWay("draggable-data")
  var draggableData;
  
  DragDropConfig ddConfig;
  
  @NgOneWay("ui-draggable")
  set dragdropConfig(var config) {
    if (!(config is DragDropConfig)) {
      return;
    }
    this.config = ddConfig = config as DragDropConfig; 
  }
  @NgCallback("on-drag-success")
  Function onDragSuccessCallback;

  @NgOneWay("allowed-drop-zones")
  set dropZones (var dropZones) {
    this.dropZoneNames = dropZones;
  }
  
  DraggableComponent(html.Element elem, DragDropDataService dragDropService, DragDropConfigService dragDropConfigService)
  : super(elem, dragDropService, dragDropConfigService.dragDropConfig) {
    dragdropConfig = dragDropConfigService.dragDropConfig;
    this.dragEnabled = true;
  }


  @override
  void onDragEndCallback(html.Event event) {
    dragDropService.draggableData = null;
    dragDropService.onDragSuccessCallback = null;
    html.Element dragTarget = event.target;
    dragTarget.classes.remove(ddConfig.onDragStartClass);
  }

  @override
  void onDragStartCallback(html.Event event) {
    dragDropService.draggableData = draggableData;
    dragDropService.onDragSuccessCallback = onDragSuccessCallback;
    html.Element dragTarget = event.target;
    dragTarget.classes.add(ddConfig.onDragStartClass);
  }

}

class DraggableElementHandler {
  
  String defaultCursor;
  AbstractDraggableDroppableComponent draggableComponent;
  DraggableElementHandler(this.draggableComponent ) {
    defaultCursor = draggableComponent.elem.style.cursor;
  }
  
  void refresh() {
    draggableComponent.elem.draggable = draggableComponent._dragEnabled;
    if (draggableComponent.config.dragCursor!=null) {
      draggableComponent.elem.style.cursor = draggableComponent._dragEnabled ? draggableComponent.config.dragCursor : defaultCursor;
    }
  }
}