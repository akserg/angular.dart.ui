// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.dragdrop;

import 'package:angular/angular.dart';
import 'package:logging/logging.dart' show Logger;
import 'dart:html' as html;
import 'dart:math' as math;

part 'common.dart';
part 'draggable.dart';
part 'droppable.dart';
part 'sortable.dart';

final _log = new Logger('angular.ui.dragdrop');

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

class BaseDDConfig {
  DragImage dragImage;
  DataTransferEffect dragEffect = DataTransferEffect.MOVE;
  DataTransferEffect dropEffect = DataTransferEffect.MOVE;
  String dragCursor = "move";
}

class DragDropConfig extends BaseDDConfig {
    String onDragStartClass = "ui-drag-start";
    String onDragEnterClass = "ui-drag-enter";
    String onDragOverClass = "ui-drag-over";
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
    bind(SortableItemComponent);
    bind(DragDropSortableDataService);
  }
}
