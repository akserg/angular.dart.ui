// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.dragdrop;

import 'package:angular/angular.dart';
import 'dart:html' as html;

part 'draggable.dart';
part 'droppable.dart';

@NgInjectableService()
class UIDragDropService {
  var draggableData;
}

class DragDropModule extends Module {
  DragDropModule() {
    type(UIDragDropService);
    type(DraggableComponent);
    type(DroppableComponent);
  }
}