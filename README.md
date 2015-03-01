Angular UI [![Build Status](https://travis-ci.org/akserg/angular.dart.ui.svg?branch=master)](https://travis-ci.org/akserg/angular.dart.ui) [![Stories in Ready](https://badge.waffle.io/akserg/angular.dart.ui.svg?label=ready)](http://waffle.io/akserg/angular.dart.ui?milestone=0.6) [![Coverage Status](https://coveralls.io/repos/akserg/angular.dart.ui/badge.svg)](https://coveralls.io/r/akserg/angular.dart.ui) 
===============

Port of Angular-UI to Dart.

Look at [Demo](http://akserg.github.io/angular.dart.ui.demo/index.html) page for this project.

You may be interesting in check out [Material Design Theme](http://akserg.github.io/angular.dart.material.demo) for this project.

## Quick-Start
Include the following code to your `index.html`
```html
<!-- Latest compiled and minified bootsrap CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css">
<!-- Optional bootstrap theme CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap-theme.min.css">
<!-- angular ui CSS -->
<link rel="stylesheet" href="packages/angular_ui/css/angular.css">
<!-- your own CSS file -->
<link rel="stylesheet" href="style.css">
```

Add the follwing css ccode to your `style.css`
```css
.nav, .pagination, .carousel, .panel-title a { cursor: pointer; }
```

Add the angular-ui module in your `main.dart`
```dart
import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'package:angular_ui/angular_ui.dart';

void main() {
  applicationFactory()
    .addModule(new AngularUIModule()) // The angular-ui module
    .addModule(new MainModule()) // Your own module
    .run();
}
```

Use the angular-ui components as descrpied below or in the [demo](http://akserg.github.io/angular.dart.ui.demo/index.html).


##Bootstrap directives and components

- Checkbox and RadioButton
- DropdownToggle
- Collapse
- Alert
- ProgressBar
- Modal
- Accordion
- Rating
- Datepicker (partially implemented)
- Tabs
- Drag and Drop support
- [Carousel](https://github.com/Roba1993/angular.dart.ui/tree/master/lib/carousel)
- Timepicker
- Pagination
- Tooltip
- Popover
- Typehead

*Note: Drag and Drop support is experimental feature and API can be changed at any time in the future.*

##Credits

- [Sergey Akopkokhyants](https://github.com/akserg)
- [Tõnis Pool](https://github.com/poolik).
- [Günter Zöchbauer](https://github.com/zoechi)
- [Francesco Cina](https://github.com/ufoscout)
- [AngularDart project](https://github.com/angular/angular.dart)
- [Neeraj Mittal](https://github.com/neermitt)

Big thanks to [Robert Schütte](https://github.com/Roba1993) for his improvements of documentation.