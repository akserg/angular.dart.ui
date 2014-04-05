// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.dragdrop;

@NgDirective(
    selector: '[ui-draggable]'
)
class DraggableComponent {

  html.Element _elem;
  UIDragDropService _dragDropService;
  @NgOneWay("ui-draggable-data")
  var draggableData = "data from draggable object";
  
  
  DraggableComponent(this._elem, this._dragDropService) {
    _elem.draggable = true;
    
    _elem.onDragStart.listen(_onDragStart);
    _elem.onDragEnd.listen(_onDragEnd);
    
    _elem.onTouchStart.listen(_onDragStart);
    _elem.onTouchEnd.listen(_onDragEnd);
  }
  
  void _onDragStart(html.Event event) {
    print("drag start");
    html.Element dragTarget = event.target;
    dragTarget.classes.add('moving');
    _dragDropService.draggableData = draggableData;
    //event.dataTransfer.effectAllowed = 'move';
    //event.dataTransfer.setData('text/html', dragTarget.innerHtml);
  }

  void _onDragEnd(html.Event event) {
    print("drag end");
    html.Element dragTarget = event.target;
    dragTarget.classes.remove('moving');
    _dragDropService.draggableData = null;
    //var cols = document.queryAll('#columns .column');
    //for (var col in cols) {
    //  col.classes.remove('over');
    // }
  }
  
}