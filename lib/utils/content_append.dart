// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.utils.content_append;

import "package:angular/angular.dart";
import 'dart:html';

class ContentAppendModule extends Module {
  ContentAppendModule() {
    bind(ContentAppendComponent);
  }
}

@Decorator(
    selector: 'content-append'
)
class ContentAppendComponent {
  Element _element;

  @NgOneWay('node')
  set append(var node) {
    if (node != null) {
      if (node is String){
        _element.appendText(node as String);
      } else if (node is Node) {
        _element.append(node as Node);
      }
    }
  }
  
  ContentAppendComponent(this._element);
  
}