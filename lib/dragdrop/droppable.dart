// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.dragdrop;


abstract class AbstractDroppableComponent extends DisposableComponent {
  
  final List<StreamSubscription> subscriptions = [];
  final html.Element elem;
  final DragDropDataService dragDropService;
  List<String> dropZoneNames = [];
  AbstractDDConfig config;
  bool enabled = true;
  
  AbstractDroppableComponent(this.elem, this.dragDropService, this.config) {
    subscriptions.add( elem.onDragEnter.listen(_onDragEnter) );
    subscriptions.add( elem.onDragOver.listen((html.MouseEvent event) {
      _onDragOver(event);
      //workaround to avoid NullPointerException during unit testing
      if (event.dataTransfer!=null) {
        event.dataTransfer.dropEffect = config.dropEffect.name;
      }
    }) );
    subscriptions.add( elem.onDragLeave.listen(_onDragLeave) );
    subscriptions.add( elem.onTouchEnter.listen(_onDragEnter) );
    subscriptions.add( elem.onTouchLeave.listen(_onDragLeave) );
    subscriptions.add( elem.onDrop.listen(_onDrop) );
  }
  
  void _onDragEnter(html.Event event) {
    if(!enabled || !isAllowedDropZone()) {
      return;
    }
    // This is necessary to allow us to drop.
    event.preventDefault();
    elem.classes.add(config.onDragEnterClass);
    onDragEnterCallback(event);
  }

  void _onDragOver(html.Event event) {
    if(!enabled || !isAllowedDropZone()) {
      return;
    }
    // This is necessary to allow us to drop.
    event.preventDefault();
    elem.classes.add(config.onDragOverClass);
    onDragOverCallback(event);
  }

  void _onDragLeave(html.Event event) {
    if(!enabled || !isAllowedDropZone()) {
      return;
    }
    elem.classes.remove(config.onDragOverClass);
    elem.classes.remove(config.onDragEnterClass);
    onDragLeaveCallback(event);
  }

  void _onDrop(html.Event event) {
    if(!enabled || !isAllowedDropZone()) {
      return;
    }
    elem.classes.remove(config.onDragOverClass);
    elem.classes.remove(config.onDragEnterClass);
    onDropCallback(event);
  }
  
  bool isAllowedDropZone() {
    if (dropZoneNames.isEmpty && dragDropService.allowedDropZones.isEmpty) {
      return true;
    }
    for (String dragZone in dragDropService.allowedDropZones) {
      if (dropZoneNames.contains(dragZone)) {
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    for (StreamSubscription subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();
  }
  
  void onDragEnterCallback(html.Event event);
  void onDragOverCallback(html.Event event);
  void onDragLeaveCallback(html.Event event);
  void onDropCallback(html.Event event);

}


@Decorator(selector: '[ui-droppable]')
class DroppableComponent extends AbstractDroppableComponent {

  @NgCallback("on-drop-success")
  Function onDropSuccessCallback;
  
  @NgOneWay("ui-droppable")
  set dragdropConfig(var config) {
    if (!(config is DragDropConfig)) {
      return;
    }
    DragDropConfig ddConfig = config as DragDropConfig; 
    this.config = config;
  }
  
  @NgOneWay("drop-zones")
  set dropZones (var dropZoneNames) {
    if (dropZoneNames!=null && (dropZoneNames is String)) {
      this.dropZoneNames = [dropZoneNames];
    } else if (dropZoneNames!=null && (dropZoneNames is List<String>)) {
      this.dropZoneNames = dropZoneNames;
    }
  }
  
  DroppableComponent(html.Element elem, DragDropDataService dragDropService, DragDropConfigService dragDropConfigService)
  : super(elem, dragDropService, dragDropConfigService.dragDropConfig) {

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
    if (onDropSuccessCallback!=null) {
      onDropSuccessCallback({'data':dragDropService.draggableData});
    }
    if(dragDropService.onDragSuccessCallback!=null){
      dragDropService.onDragSuccessCallback(); 
    }
  }

  @override
  bool isActive() {
    return true;
  }
}
