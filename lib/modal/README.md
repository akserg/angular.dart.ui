**Modal** is a service to quickly create Angular Dart powered modal windows.
Creating custom modals is straightforward: create a partial view, its controller and reference them when using the service.

The **Modal** service has only one method: `open(options, scope)` where available options are like follows:

* `templateUrl` - a path to a template representing modal's content
* `template` - inline template representing the modal's content
* `backdrop` - controls presence of a backdrop. Allowed values: true (default), false (no backdrop), `'static'` - backdrop is present but modal window is not closed when clicking outside of the modal window.
* `keyboard` - indicates whether the dialog should be closable by hitting the ESC key, defaults to true
* `windowClass` - additional CSS class(es) to be added to a modal window template
* `size` - optional size of modal window. Allowed values: `'sm'` (small) or `'lg'` (large). Requires Bootstrap 3.1.0 or later

* `scope` - a scope instance to be used for the modal's content

The `open` method returns a modal instance, an object with the following properties:

* `close(result)` - a method that can be used to close a modal, passing a result
* `dismiss(reason)` - a method that can be used to dismiss a modal, passing a reason
* `result` - a promise that is resolved when a modal is closed and rejected when a modal is dismissed
* `opened` - a promise that is resolved when a modal gets opened after downloading content's template and resolving all variables
