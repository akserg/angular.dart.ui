// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.dragdrop;

@Injectable()
class DragDropZonesService {
  List<String> allowedDropZones = [];
}

class DragImage {
  html.Element imageElement;
  int x_offset;
  int y_offset;

  DragImage(this.imageElement, {this.x_offset: 0, this.y_offset: 0}) {}

}

class BaseDDConfig {
  DragImage dragImage;
  DataTransferEffect dragEffect = DataTransferEffect.MOVE;
  DataTransferEffect dropEffect = DataTransferEffect.MOVE;
  String dragCursor = "move";
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

abstract class AbstractDraggableDroppableComponent {

  DraggableElementHandler _draggableHandler;
  List<String> _dropZoneNames = [new math.Random().nextDouble().toString()];
  
  final html.Element elem;
  final DragDropZonesService ddZonesService;

  BaseDDConfig _config;
  bool _dragEnabled = false;
  bool dropEnabled = false;
  
  List<String> get dropZoneNames => _dropZoneNames;
  set dropZoneNames(var names) {
    if (names!=null && (names is String)) {
      this._dropZoneNames = [names];
    } else if (names is List<String>) {
      this._dropZoneNames = names;
    }
  }
  
  BaseDDConfig get config => _config;
  set config(BaseDDConfig config) {
    this._config = config;
    _draggableHandler.refresh();
  }
  
  bool get dragEnabled => _dragEnabled;
  set dragEnabled(bool enabled) {
    _dragEnabled = enabled;
    _draggableHandler.refresh();
  }
  
  AbstractDraggableDroppableComponent(this.elem, this.ddZonesService, BaseDDConfig config) {
    _draggableHandler = new DraggableElementHandler(this);
    this.config = config;
    
    //drop events
    {
      elem.onDragEnter.listen(_onDragEnter);
      elem.onDragOver.listen((html.MouseEvent event) {
        _onDragOver(event);
        //workaround to avoid NullPointerException during unit testing
        if (event.dataTransfer!=null) {
          event.dataTransfer.dropEffect = config.dropEffect.name;
        }
      });
      elem.onDragLeave.listen(_onDragLeave);
      elem.onTouchEnter.listen(_onDragEnter);
      elem.onTouchLeave.listen(_onDragLeave);
      elem.onDrop.listen(_onDrop);
    }
    
    //drag events
    {
      elem.onDragStart.listen((html.MouseEvent event) {
        _onDragStart(event);
        //workaround to avoid NullPointerException during unit testing
        if (event.dataTransfer!=null) {
          event.dataTransfer.effectAllowed = this.config.dragEffect.name;
          event.dataTransfer.setData('text/html', '');
          
          if (this.config.dragImage!=null) {
            DragImage dragImage = this.config.dragImage;
            event.dataTransfer.setDragImage(dragImage.imageElement, dragImage.x_offset, dragImage.y_offset);
          }
          
        }
      });
      elem.onDragEnd.listen(_onDragEnd) ;
      
      elem.onTouchStart.listen(_onDragStart) ;
      elem.onTouchEnd.listen(_onDragEnd) ;
    }
  }

  void _onDragEnter(html.Event event) {
    if(!dropEnabled || !isDropAllowed()) {
      return;
    }
    _log.finer("'dragEnter' event");
    // This is necessary to allow us to drop.
    event.preventDefault();
    onDragEnterCallback(event);
  }

  void _onDragOver(html.Event event) {
    if(!dropEnabled || !isDropAllowed()) {
      return;
    }
    _log.finest("'dragOver' event");
    // This is necessary to allow us to drop.
    event.preventDefault();
    onDragOverCallback(event);
  }

  void _onDragLeave(html.Event event) {
    if(!dropEnabled || !isDropAllowed()) {
      return;
    }
    _log.finer("'dragLeave' event");
    onDragLeaveCallback(event);
  }

  void _onDrop(html.Event event) {
    if(!dropEnabled || !isDropAllowed()) {
      return;
    }
    _log.finer("'drop' event");
    onDropCallback(event);
  }
  
  bool isDropAllowed() {
    if (_dropZoneNames.isEmpty && ddZonesService.allowedDropZones.isEmpty) {
      return true;
    }
    for (String dragZone in ddZonesService.allowedDropZones) {
      if (_dropZoneNames.contains(dragZone)) {
        return true;
      }
    }
    return false;
  }

  void _onDragStart(html.Event event) {
    if(!_dragEnabled) {
      return;
    }
    _log.finer("'dragStart' event");
    ddZonesService.allowedDropZones = _dropZoneNames;
    onDragStartCallback(event);
  }

  void _onDragEnd(html.Event event) {
    _log.finer("'dragEnd' event");
    ddZonesService.allowedDropZones = [];
    onDragEndCallback(event);
  }
  
  void onDragEnterCallback(html.Event event) {}
  void onDragOverCallback(html.Event event) {}
  void onDragLeaveCallback(html.Event event) {}
  void onDropCallback(html.Event event)  {}
  void onDragStartCallback(html.Event event) {}
  void onDragEndCallback(html.Event event) {}
  
}
