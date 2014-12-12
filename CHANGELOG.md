#Version 0.6.0, (2014/12/12)
- Migration on Angualr Dart 1.0, support Bootstrap 3.3.1 and bug fixes.

#Version 0.5.5, (2014/06/25)

##Bug Fixes
- Modal Dialog with backdrop:'static' cannot be closed by click on button with data-dismiss='modal'

#Version 0.5.4, (2014/06/21)

##Bug Fixes
- Error when using typeahead-on-select=ctrl.setSelectedItem($item, $model, $label)

#Version 0.5.3, (2014/06/18)

##Bug Fixes
- Typeahead placement of suggestion popover offset by approax 200px
- Fix animation toggle and z-index calculation in ModalWindow

#Version 0.5.2, (2014/06/17)

##Features
- Project migrated to follow Dart SDK 1.4.3

##Bug Fixes

- ModalWindow must call dismiss method of top ModalInstance instead of Modal.close.

#Version 0.5.1, (2014/06/06)

##Features
- Project migrated to follow Angular Dart 0.12.0

#Version 0.5.0, (2014/06/05)

##Features
- All components have migrated away from Shadow DOM and applyAuthorStyles.

##Bug Fixes

- ng-click called multiple times
- DatePicker tests fail with UTC+1

#Version 0.4.0, (2014/05/16)

##Features

- Carousel
- Timepicker
- Pagination
- Tooltip
- Popover
- Typehead

##Bug Fixes

- Classes Popover, Tooltip, ModalWindow, DatePicker compiled to JavaScript don't work proper
- Error compiling Pagination component to JavaScript
- Checkbox component doesn't work proper in example

#Version 0.3.0, (2014/04/19)

##Features

- Accordion
- Datepicker (partially implemented)
- Rating
- Tabs
- Drag and Drop support

##Bug Fixes

- Fixed selectors of all components
- Fixed unittest for all components

#Version 0.2.0, (2014/02/13)

##Features

- Collapse
- DropdownToggle
- Alert
- Progressbar
- Modal
- Timeout

##Bug Fixes

- Transition and Collapse are not working as expected

#Version 0.1.0, (2014/01/14)

##Features

- Buttons
- Position
- Transition

