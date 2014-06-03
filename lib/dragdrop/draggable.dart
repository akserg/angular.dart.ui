// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.dragdrop;

abstract class AbstractDraggableDroppableComponent {

  DraggableElementHandler _draggableHandler;
  List<String> _dropZoneNames = [new math.Random().nextDouble().toString()];
  
  final html.Element elem;
  final DragDropDataService dragDropService;

  BaseDDConfig _config;
  bool _dragEnabled = false;
  bool dropEnabled = false;
  
  get dropZoneNames => _dropZoneNames;
  set dropZoneNames(var names) {
    if (names!=null && (names is String)) {
      this._dropZoneNames = [names];
    } else if (names is List<String>) {
      this._dropZoneNames = names;
    }
  }
  
  get config => _config;
  set config(BaseDDConfig config) {
    this._config = config;
    _draggableHandler.refresh();
  }
  
  get dragEnabled => _dragEnabled;
  set dragEnabled(bool enabled) {
    _dragEnabled = enabled;
    _draggableHandler.refresh();
  }
  
  AbstractDraggableDroppableComponent(this.elem, this.dragDropService, BaseDDConfig config) {
    _draggableHandler = new DraggableElementHandler(this);
    this.config = config;
    
    //drop events
    {
      elem.onDragEnter.listen(_onDragEnter);
      elem.onDragOver.listen((html.MouseEvent event) {
        _onDragOver(event);
        //workaround to avoid NullPointerException during unit testing
        if (event.dataTransfer!=null) {
          event.dataTransfer.dropEffect = config.dropEffect.name;
        }
      });
      elem.onDragLeave.listen(_onDragLeave);
      elem.onTouchEnter.listen(_onDragEnter);
      elem.onTouchLeave.listen(_onDragLeave);
      elem.onDrop.listen(_onDrop);
    }
    
    //drag events
    {
      elem.onDragStart.listen((html.MouseEvent event) {
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
      });
      elem.onDragEnd.listen(_onDragEnd) ;
      
      elem.onTouchStart.listen(_onDragStart) ;
      elem.onTouchEnd.listen(_onDragEnd) ;
    }
  }

  void _onDragEnter(html.Event event) {
    if(!dropEnabled || !isDropAllowed()) {
      return;
    }
    // This is necessary to allow us to drop.
    event.preventDefault();
    elem.classes.add(config.onDragEnterClass);
    onDragEnterCallback(event);
  }

  void _onDragOver(html.Event event) {
    if(!dropEnabled || !isDropAllowed()) {
      return;
    }
    // This is necessary to allow us to drop.
    event.preventDefault();
    elem.classes.add(config.onDragOverClass);
    onDragOverCallback(event);
  }

  void _onDragLeave(html.Event event) {
    if(!dropEnabled || !isDropAllowed()) {
      return;
    }
    elem.classes.remove(config.onDragOverClass);
    elem.classes.remove(config.onDragEnterClass);
    onDragLeaveCallback(event);
  }

  void _onDrop(html.Event event) {
    if(!dropEnabled || !isDropAllowed()) {
      return;
    }
    elem.classes.remove(config.onDragOverClass);
    elem.classes.remove(config.onDragEnterClass);
    onDropCallback(event);
  }
  
  bool isDropAllowed() {
    if (_dropZoneNames.isEmpty && dragDropService.allowedDropZones.isEmpty) {
      return true;
    }
    for (String dragZone in dragDropService.allowedDropZones) {
      if (_dropZoneNames.contains(dragZone)) {
        return true;
      }
    }
    return false;
  }

  void _onDragStart(html.Event event) {
    if(!_dragEnabled) {
      return;
    }
    html.Element dragTarget = event.target;
    dragTarget.classes.add(config.onDragStartClass);
    dragDropService.allowedDropZones = _dropZoneNames;
    onDragStartCallback(event);
  }

  void _onDragEnd(html.Event event) {
    html.Element dragTarget = event.target;
    dragTarget.classes.remove(config.onDragStartClass);
    dragDropService.allowedDropZones = [];
    onDragEndCallback(event);
  }
  
  void onDragEnterCallback(html.Event event) {}
  void onDragOverCallback(html.Event event) {}
  void onDragLeaveCallback(html.Event event) {}
  void onDropCallback(html.Event event)  {}
  void onDragStartCallback(html.Event event) {}
  void onDragEndCallback(html.Event event) {}
  
}


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
  }

  @override
  void onDragStartCallback(html.Event event) {
    dragDropService.draggableData = draggableData;
    dragDropService.onDragSuccessCallback = onDragSuccessCallback;
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