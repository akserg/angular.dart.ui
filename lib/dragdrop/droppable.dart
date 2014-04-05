// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.dragdrop;

@NgDirective(selector: '[ui-droppable]')
class DroppableComponent {

  html.Element _elem;
  DragDropDataService _dragDropService;
  DragDropConfig _dragDropConfig;

  DroppableComponent(this._elem, this._dragDropService, this._dragDropConfig) {
    print("new droppable created " + _elem.toString());
    _elem.onDragEnter.listen(_onDragEnter);
    _elem.onDragOver.listen((html.MouseEvent event) {
      _onDragOver(event);
      event.dataTransfer.dropEffect = _dragDropConfig.dropEffect.name;
    });
    _elem.onDragLeave.listen(_onDragLeave);
    _elem.onTouchEnter.listen(_onDragEnter);
    _elem.onTouchLeave.listen(_onDragLeave);
    _elem.onDrop.listen(_onDrop);
  }

  void _onDragEnter(html.Event event) {
    print("drag enter");
    // This is necessary to allow us to drop.
    event.preventDefault();
    _elem.classes.add(_dragDropConfig.onDragEnterClass);
  }

  void _onDragOver(html.Event event) {
    //print("drag over");
    // This is necessary to allow us to drop.
    event.preventDefault();
    _elem.classes.add(_dragDropConfig.onDragOverClass);
  }

  void _onDragLeave(html.Event event) {
    print("drag leave");
    _elem.classes.remove(_dragDropConfig.onDragOverClass);
    _elem.classes.remove(_dragDropConfig.onDragEnterClass);
  }

  void _onDrop(html.Event event) {
    print("drop. Receveid data:" + _dragDropService.draggableData);
    _elem.classes.remove(_dragDropConfig.onDragOverClass);
    _elem.classes.remove(_dragDropConfig.onDragEnterClass);
  }
}
