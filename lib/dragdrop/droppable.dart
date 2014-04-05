// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.dragdrop;

@NgDirective(
    selector: '[ui-droppable]'
)
class DroppableComponent {
  
  html.Element _elem;
  UIDragDropService _dragDropService;
  
  DroppableComponent(this._elem, this._dragDropService) {
    _elem.onDragEnter.listen(_onDragEnter);
    _elem.onDragOver.listen(_onDragOver);
    _elem.onDragLeave.listen(_onDragLeave);
    _elem.onTouchEnter.listen(_onDragEnter);
    _elem.onTouchLeave.listen(_onDragLeave);
    _elem.onDrop.listen(_onDrop);
  }
  
  void _onDragEnter(html.Event event) {
    // This is necessary to allow us to drop.
    event.preventDefault();
    html.Element dropTarget = event.target;
    dropTarget.classes.add('enter');
  }

  void _onDragOver(html.Event event) {
    // This is necessary to allow us to drop.
    event.preventDefault();
    html.Element dropTarget = event.target;
    dropTarget.classes.add('over');
    //event.dataTransfer.dropEffect = 'move';
  }

  void _onDragLeave(html.Event event) {
    html.Element dropTarget = event.target;
    dropTarget.classes.remove('over');
  }
  
  void _onDrop(html.Event event) {
    print("drop event. Receveid data:");
    print(_dragDropService.draggableData);
  }
}