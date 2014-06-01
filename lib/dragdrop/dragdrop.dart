// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.dragdrop;

import 'package:angular/angular.dart';
import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:async';

part 'draggable.dart';
part 'droppable.dart';
part 'sortable.dart';

@Injectable()
class DragDropDataService {
  Function onDragSuccessCallback;
  var draggableData;
  List<String> allowedDropZones = [];
}

@Injectable()
class DragDropConfigService {
  DragDropConfig dragDropConfig = new DragDropConfig();
  SortableConfig sortableConfig = new SortableConfig();
}

abstract class AbstractDDConfig {
  DragImage dragImage;
  DataTransferEffect dragEffect = DataTransferEffect.MOVE;
  DataTransferEffect dropEffect = DataTransferEffect.MOVE;
  String dragCursor = "move";
  String onDragStartClass = "";
  String onDragEnterClass = "";
  String onDragOverClass = "";
}

class DragDropConfig extends AbstractDDConfig {
  DragDropConfig() {
    onDragStartClass = "ui-drag-start";
    onDragEnterClass = "ui-drag-enter";
    onDragOverClass = "ui-drag-over";
  }
}

abstract class DisposableComponent {
  void dispose();
}

class DragImage {
  html.Element imageElement;
  int x_offset;
  int y_offset;

  DragImage(this.imageElement, {this.x_offset: 0, this.y_offset: 0}) {}

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
    bind(DragDropDataService);
    bind(DragDropConfigService);
    bind(DraggableComponent);
    bind(DroppableComponent);
    bind(SortableComponent);
    bind(DragDropSortableDataService);
  }
}
