// Copyright (C) 2013 - 2015 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.dbl_click_preventer;

import "package:angular/angular.dart";

import 'timeout.dart';

/**
 * Double Click Preventer Module.
 */
class DblClickPreventerModule extends Module {
  DblClickPreventerModule() {
    install(new TimeoutModule());
    bind(DblClickPreventer);
  }
}

@Injectable()
class DblClickPreventer {
  bool _isNotWaiting = true;
  final Timeout timeout;
  
  DblClickPreventer(this.timeout);
  
  call(Function func, {int delay:500}) {
    if (_isNotWaiting) {
      _isNotWaiting = false;
      func();
      timeout(() {
        _isNotWaiting = true;
      }, delay: delay);
    }
  }
}