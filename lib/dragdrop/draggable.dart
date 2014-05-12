// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.dragdrop;

abstract class AbstractDraggableComponent extends DisposableComponent {

  final List<StreamSubscription> subscriptions = [];

  DraggableElementHandler _draggableHandler;
  List<String> allowedDropZones = [];
  
  final html.Element elem;
  final DragDropDataService dragDropService;

  AbstractDDConfig _config;
  bool _enabled = true;
  
  get config => _config;
  set config(AbstractDDConfig config) {
    this._config = config;
    _draggableHandler.refresh();
  }
  
  get enabled => _enabled;
  set enabled(bool enabled) {
    _enabled = enabled;
    _draggableHandler.refresh();
  }
  
  AbstractDraggableComponent(this.elem, this.dragDropService, AbstractDDConfig config) {
    _draggableHandler = new DraggableElementHandler(this);
    this.config = config;
    
    subscriptions.add(elem.onDragStart.listen((html.MouseEvent event) {
      _onDragStart(event);
      //workaround to avoid NullPointerException during unit testing
      if (event.dataTransfer!=null) {
        event.dataTransfer.effectAllowed = this.config.dragEffect.name;
        event.dataTransfer.setData('text/html', '');
        
        if (this.config.dragImage!=null) {
          DragImage dragImage = this.config.dragImage;
          event.dataTransfer.setDragImage(dragImage.imageElement, dragImage.x_offset, dragImage.y_offset);
        }
        
      }
    }) );
    subscriptions.add(elem.onDragEnd.listen(_onDragEnd) );
    
    subscriptions.add(elem.onTouchStart.listen(_onDragStart) );
    subscriptions.add(elem.onTouchEnd.listen(_onDragEnd) );
  }
  
  void _onDragStart(html.Event event) {
    if(!_enabled) {
      return;
    }
    html.Element dragTarget = event.target;
    dragTarget.classes.add(config.onDragStartClass);
    dragDropService.allowedDropZones = allowedDropZones;
    onDragStartCallback(event);
  }

  void _onDragEnd(html.Event event) {
    html.Element dragTarget = event.target;
    dragTarget.classes.remove(config.onDragStartClass);
    dragDropService.allowedDropZones = [];
    onDragEndCallback(event);
  }
  
  @override
  void dispose() {
    for (StreamSubscription subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();
  }
  
  void onDragStartCallback(html.Event event);
  void onDragEndCallback(html.Event event);
}


@Decorator(selector: '[ui-draggable]',
  visibility: Directive.CHILDREN_VISIBILITY)
class DraggableComponent extends AbstractDraggableComponent {

  @NgOneWay("draggable-enabled")
  set draggable(bool value) {
    if(value!=null) {
      enabled = value;
    }
  }
  @NgOneWay("draggable-data")
  var draggableData;
  
  @NgOneWay("ui-draggable")
  set dragdropConfig(var config) {
    if (!(config is DragDropConfig)) {
      return;
    }
    DragDropConfig ddConfig = config as DragDropConfig; 
    this.config = ddConfig;
  }
  @NgCallback("on-drag-success")
  Function onDragSuccessCallback;

  @NgOneWay("allowed-drop-zones")
  set dropZones (var dropZones) {
    if (dropZones!=null && (dropZones is String)) {
      this.allowedDropZones = [dropZones];
    } else if (dropZones!=null && (dropZones is List<String>)) {
      this.allowedDropZones = dropZones;
    }
  }
  
  DraggableComponent(html.Element elem, DragDropDataService dragDropService, DragDropConfigService dragDropConfigService)
  : super(elem, dragDropService, dragDropConfigService.dragDropConfig) {
    dragdropConfig = dragDropConfigService.dragDropConfig;
  }


  @override
  void onDragEndCallback(html.Event event) {
    dragDropService.draggableData = null;
    dragDropService.onDragSuccessCallback = null;
  }

  @override
  void onDragStartCallback(html.Event event) {
    dragDropService.draggableData = draggableData;
    dragDropService.onDragSuccessCallback = onDragSuccessCallback;
  }

}

class DraggableElementHandler {
  
  String defaultCursor;
  AbstractDraggableComponent draggableComponent;
  DraggableElementHandler(this.draggableComponent ) {
    defaultCursor = draggableComponent.elem.style.cursor;
  }
  
  void refresh() {
    draggableComponent.elem.draggable = draggableComponent._enabled;
    if (draggableComponent.config.dragCursor!=null) {
      draggableComponent.elem.style.cursor = draggableComponent._enabled ? draggableComponent.config.dragCursor : defaultCursor;
    }
  }
}