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

class DragDropModule extends Module {
  DragDropModule() {
    bind(DragDropZonesService);
    bind(DragDropDataService);
    bind(DragDropConfigService);
    bind(DraggableComponent);
    bind(DroppableComponent);
    bind(SortableComponent);
    bind(SortableItemComponent);
    bind(DragDropSortableDataService);
  }
}
