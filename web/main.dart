// Copyright (C) 2015 Sergey Akopkokhyants.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.demo;

import 'dart:html' as dom;

import 'package:logging/logging.dart';
import 'package:angular2/angular2.dart';

//import 'package:angular_ui/buttons/buttons.dart'; // show buttonBindings;

//part 'accordion/accordion_demo.dart';
//part 'alert/alert_demo.dart';
//part 'buttons/buttons_demo.dart';
//part 'carousel/carousel_demo.dart';
//part 'collapse/collapse_demo.dart';
//part 'dragdrop/dragdrop_demo.dart';
//part 'dragdrop/sortable_demo.dart';
//part 'datepicker/datepicker_demo.dart';
//part 'dropdown_toggle/dropdown_toggle_demo.dart';
//part 'modal/modal_demo_embedded_template.dart';
//part 'modal/modal_demo_embedded_template_static_backdrop.dart';
//part 'modal/modal_demo_template_element.dart';
//part 'modal/modal_demo_template_element_from_other_file.dart';
////part 'modal/modal_demo_template_from_file.dart';
//part 'pagination/pagination_demo.dart';
//part 'progressbar/progressbar_demo.dart';
//part 'tabs/tabs_demo.dart';
//part 'timepicker/timepicker_demo.dart';
//part 'rating/rating_demo.dart';
//part 'tooltip/tooltip_demo.dart';
//part 'popover/popover_demo.dart';
//part 'typeahead/typeahead_demo.dart';

final _log = new Logger('angular.ui.demo');

/**
 * Entry point into app.
 */
main() {
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen((LogRecord r) {
    DateTime now = new DateTime.now();
    dom.window.console.log('${now} [${r.level}] ${r.loggerName}: ${r.message}');
  });
  new Logger("angular.ui")..level = Level.FINER;

  _log.fine('bootstrap');

  bootstrap(DemoApp);
}

@Component(selector: 'demo-app')
@View(
    template: r'''
    <h3>Hello {{name}}!</h3>
    Name: <input type="text" (input)="nameChanged($event)">
    <div class="checkbox">
        <label>
            <input type="checkbox" [checked]="checked" (change)="checkedChanged($event)"> Checkbox
        </label>
    </div>
    ''')
class DemoApp {
  DemoApp() {
    _log.fine('DemoApp');
  }

  String name = "whoever";
  void nameChanged(event) {
    name = event.target.value;
  }

  bool checked = false;
  void checkedChanged(event) {
    checked = event.target.checked;
  }
}
