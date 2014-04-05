// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.dragdrop;

import 'package:angular/angular.dart';
import 'dart:html' as html;

part 'draggable.dart';
part 'droppable.dart';

@NgInjectableService()
class DragDropDataService {
  var draggableData;
}

@NgInjectableService()
class DragDropConfig {
  DataTransferEffect dragEffect = DataTransferEffect.MOVE;
  DataTransferEffect dropEffect = DataTransferEffect.MOVE;
  String onDragStartClass = "ui-drag-start";
  String onDragEnterClass = "ui-drag-enter";
  String onDragOverClass = "ui-drag-over";
}

class DataTransferEffect {

  static const COPY = const DataTransferEffect('copy');
  static const LINK = const DataTransferEffect('link');
  static const MOVE = const DataTransferEffect('move');
  static const NONE = const DataTransferEffect('none');
  static const values = const <DataTransferEffect>[COPY, LINK, MOVE, NONE];
    
  final String name;
  const DataTransferEffect(this.name);
}

class DragDropModule extends Module {
  DragDropModule() {
    type(DragDropDataService);
    type(DragDropConfig);
    type(DraggableComponent);
    type(DroppableComponent);
  }
}