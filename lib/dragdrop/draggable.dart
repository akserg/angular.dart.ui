// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.dragdrop;

@NgDirective(selector: '[ui-draggable]')


class DraggableComponent {

  html.Element _elem;
  DragDropDataService _dragDropService;
  DragDropConfig _dragDropConfig;

  @NgOneWay("ui-draggable-data")
  var draggableData = "data from draggable object";


  DraggableComponent(this._elem, this._dragDropService, this._dragDropConfig) {
    _elem.draggable = true;

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
    print("drag start");
    html.Element dragTarget = event.target;
    dragTarget.classes.add(_dragDropConfig.onDragStartClass);
    _dragDropService.draggableData = draggableData;
  }

  void _onDragEnd(html.Event event) {
    print("drag end");
    html.Element dragTarget = event.target;
    dragTarget.classes.remove(_dragDropConfig.onDragStartClass);
    _dragDropService.draggableData = null;
  }

}
