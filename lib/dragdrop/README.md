Angular Dart **Drag&Drop** directives.

The **ui-draggable** directive identifies the draggable object.
Available settings:
 - `allowed-drop-zones`: String or array of Strings. Specify the drop-zones to which this component can drop.
 - `draggable-enabled`: bool value. whether the object is draggable. Default is true.
 - `draggable-data`: the data that has to be dragged. It can be any JS object.
 - `ui-draggable`: an instance of DragDropConfig class. It permits to configure how the drag&drop look&feel (cursor, drag image, custom classes to add on drag/drop events)
 - `on-drag-success`: callback function called when the drag action ends with a valid drop action. It is activated after the `on-drop-success` callback

The **ui-droppable** directive identifies the drop target object.
Available settings:

 - `drop-zones`: String or array of Strings. It permits to specify the drop zones associated with this component. By default, if the `drop-zones` attribute is not specified, the droppable component accepts drop operations by all the draggable components that do not specify the `allowed-drop-zones`
 - `on-drop-success`: callback function called when the drop action completes correctly. It is activated before the `on-drag-success` callback.
 - `ui-droppable`: an instance of DragDropConfig class. It permits to configure how the drag&drop look&feel (cursor, drag image, custom classes to add on drag/drop events)

