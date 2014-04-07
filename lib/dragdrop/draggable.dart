// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.dragdrop;

@NgDirective(selector: '[ui-draggable]')


class DraggableComponent {

  html.Element _elem;
  DragDropDataService _dragDropService;
  DragDropConfig _dragDropConfig;
  bool _enabled = true;

  @NgOneWay("draggable-enabled")
  set draggable(bool value) {
    if(value!=null) {
      _enabled = value;
      _elem.draggable = _enabled;
    }
  }
  @NgOneWay("draggable-data")
  var draggableData;
  @NgOneWay("dragdrop-config")
  set dragdropConfig(DragDropConfig config) {
    _dragDropConfig = config;
  }
  @NgCallback("on-drag-success")
  Function onDragSuccessCallback;

  DraggableComponent(this._elem, this._dragDropService, DragDropConfigService dragDropConfigService) {
    _dragDropConfig = dragDropConfigService.config;
    _elem.draggable = _enabled;

    _elem.onDragStart.listen((html.MouseEvent event) {
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
    _elem.onDragEnd.listen(_onDragEnd);

    _elem.onTouchStart.listen(_onDragStart);
    _elem.onTouchEnd.listen(_onDragEnd);
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
