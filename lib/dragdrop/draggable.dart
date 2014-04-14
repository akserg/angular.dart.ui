// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.dragdrop;

@NgDirective(selector: '[ui-draggable]',
  visibility: NgDirective.CHILDREN_VISIBILITY)
class DraggableComponent {

  html.Element _draggableElement;
  DraggableElementHandler draggableHandler;
  DragDropDataService _dragDropService;
  DragDropConfig _dragDropConfig;
  bool _enabled = true;

  @NgOneWay("draggable-enabled")
  set draggable(bool value) {
    if(value!=null) {
      _enabled = value;
      draggableHandler.refresh();
    }
  }
  @NgOneWay("draggable-data")
  var draggableData;
  
  @NgOneWay("dragdrop-config")
  set dragdropConfig(DragDropConfig config) {
    _dragDropConfig = config;
    draggableHandler.refresh();
  }
  @NgCallback("on-drag-success")
  Function onDragSuccessCallback;

  DraggableComponent(this._draggableElement, this._dragDropService, DragDropConfigService dragDropConfigService) {
    draggableHandler = new DraggableElementHandler(this);
    dragdropConfig = dragDropConfigService.config;

    _draggableElement.onDragStart.listen((html.MouseEvent event) {
      _onDragStart(event);
      //workaround to avoid NullPointerException during unit testing
      if (event.dataTransfer!=null) {
        event.dataTransfer.effectAllowed = _dragDropConfig.dragEffect.name;
        event.dataTransfer.setData('text/html', '');
        
        if (_dragDropConfig.dragImage!=null) {
          DragImage dragImage = _dragDropConfig.dragImage;
          event.dataTransfer.setDragImage(dragImage.imageElement, dragImage.x_offset, dragImage.y_offset);
        }
        
      }
    });
    _draggableElement.onDragEnd.listen(_onDragEnd);

    _draggableElement.onTouchStart.listen(_onDragStart);
    _draggableElement.onTouchEnd.listen(_onDragEnd);
  }

  void _onDragStart(html.Event event) {
    print("drag start called. Is it enabled?: " + _enabled.toString());
    if(!_enabled) {
      return;
    }
    print("drag start: " + event.type);
    html.Element dragTarget = event.target;
    dragTarget.classes.add(_dragDropConfig.onDragStartClass);
    _dragDropService.draggableData = draggableData;
    _dragDropService.onDragSuccessCallback = onDragSuccessCallback;
  }

  void _onDragEnd(html.Event event) {
    print("drag end");
    html.Element dragTarget = event.target;
    dragTarget.classes.remove(_dragDropConfig.onDragStartClass);
    _dragDropService.draggableData = null;
    _dragDropService.onDragSuccessCallback = null;
  }

}

class DraggableElementHandler {
  
  String defaultCursor;
  DraggableComponent draggableComponent;
  DraggableElementHandler(this.draggableComponent ) {
    defaultCursor = draggableComponent._draggableElement.style.cursor;
  }
  
  void refresh() {
    draggableComponent._draggableElement.draggable = draggableComponent._enabled;
    if (draggableComponent._dragDropConfig.dragCursor!=null) {
      draggableComponent._draggableElement.style.cursor = draggableComponent._enabled ? draggableComponent._dragDropConfig.dragCursor : defaultCursor;
    }
  }
}