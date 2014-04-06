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
  @NgCallback("on-drag-success")
  Function onDragSuccessCallback;

  DraggableComponent(this._elem, this._dragDropService, this._dragDropConfig) {
    _elem.draggable = _enabled;

    _elem.onDragStart.listen((html.MouseEvent event) {
      _onDragStart(event);
      event.dataTransfer.effectAllowed = _dragDropConfig.dragEffect.name;
      event.dataTransfer.setData('text/html', '');
    });
    _elem.onDragEnd.listen(_onDragEnd);

    _elem.onTouchStart.listen(_onDragStart);
    _elem.onTouchEnd.listen(_onDragEnd);
  }

  void _onDragStart(html.Event event) {
    if(!_enabled) {
      return;
    }
    print("drag start");
    html.Element dragTarget = event.target;
    dragTarget.classes.add(_dragDropConfig.onDragStartClass);
    _dragDropService.draggableData = draggableData;
    _dragDropService.onDragSuccessCallback = onDragSuccessCallback;
  }

  void _onDragEnd(html.Event event) {
    if(!_enabled) {
      return;
    }
    print("drag end");
    html.Element dragTarget = event.target;
    dragTarget.classes.remove(_dragDropConfig.onDragStartClass);
    _dragDropService.draggableData = null;
    _dragDropService.onDragSuccessCallback = null;
  }

}
