// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.dragdrop;

@NgDirective(selector: '[ui-droppable]')
class DroppableComponent {

  html.Element _elem;
  DragDropDataService _dragDropService;
  DragDropConfig _dragDropConfig;
  List<String> dropZoneNames = [];
  
  @NgOneWay("drop-zones")
  set dropZones (var dropZoneNames) {
    if (dropZoneNames!=null && (dropZoneNames is String)) {
      this.dropZoneNames = [dropZoneNames];
    } else if (dropZoneNames!=null && (dropZoneNames is List<String>)) {
      this.dropZoneNames = dropZoneNames;
    }
  }
  
  @NgCallback("on-drop-success")
  Function onDropSuccessCallback;
  
  @NgOneWay("dragdrop-config")
  set dragdropConfig(DragDropConfig config) {
    _dragDropConfig = config;
  }
  
  DroppableComponent(this._elem, this._dragDropService, DragDropConfigService dragDropConfigService) {
    _dragDropConfig = dragDropConfigService.config;
    _elem.onDragEnter.listen(_onDragEnter);
    _elem.onDragOver.listen((html.MouseEvent event) {
      _onDragOver(event);
      //workaround to avoid NullPointerException during unit testing
      if (event.dataTransfer!=null) {
        event.dataTransfer.dropEffect = _dragDropConfig.dropEffect.name;
      }
    });
    _elem.onDragLeave.listen(_onDragLeave);
    _elem.onTouchEnter.listen(_onDragEnter);
    _elem.onTouchLeave.listen(_onDragLeave);
    _elem.onDrop.listen(_onDrop);
  }

  void _onDragEnter(html.Event event) {
    if(!isAllowedDragZone()) {
      return;
    }
    // This is necessary to allow us to drop.
    event.preventDefault();
    _elem.classes.add(_dragDropConfig.onDragEnterClass);
  }

  void _onDragOver(html.Event event) {
    if(!isAllowedDragZone()) {
      return;
    }
    // This is necessary to allow us to drop.
    event.preventDefault();
    _elem.classes.add(_dragDropConfig.onDragOverClass);
  }

  void _onDragLeave(html.Event event) {
    if(!isAllowedDragZone()) {
      return;
    }
    _elem.classes.remove(_dragDropConfig.onDragOverClass);
    _elem.classes.remove(_dragDropConfig.onDragEnterClass);
  }

  void _onDrop(html.Event event) {
    if(!isAllowedDragZone()) {
      return;
    }
    if (onDropSuccessCallback!=null) {
      onDropSuccessCallback({'data':_dragDropService.draggableData});
    }
    if(_dragDropService.onDragSuccessCallback!=null){
      _dragDropService.onDragSuccessCallback(); 
    }
    _elem.classes.remove(_dragDropConfig.onDragOverClass);
    _elem.classes.remove(_dragDropConfig.onDragEnterClass);
  }
  
  bool isAllowedDragZone() {
    if (dropZoneNames.isEmpty && _dragDropService.allowedDropZones.isEmpty) {
      return true;
    }
    for (String dragZone in _dragDropService.allowedDropZones) {
      if (dropZoneNames.contains(dragZone)) {
        return true;
      }
    }
    return false;
  }
}
