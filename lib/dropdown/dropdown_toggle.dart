// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.dropdown_toggle;

import 'dart:html' as dom;
import "package:angular/angular.dart";
import "package:angular_ui/utils/utils.dart";

/**
 * DropdownToggle Module.
 */
class DropdownToggleModule extends Module {
  DropdownToggleModule() {
    bind(DropdownToggle);
  }
}

@Decorator(
    selector: '[dropdown-toggle]'
)
@Decorator(
    selector: '.dropdown-toggle'
)
class DropdownToggle implements ScopeAware {
  static dom.Element _openElement;
  static var _closeMenu = (dom.MouseEvent evt) => {};

  dom.Element element;
  Scope scope;

  DropdownToggle(this.element) {
    this.element.parent.onClick.listen((dom.MouseEvent evt) => _closeMenu(evt));
    this.element.onClick.listen(_toggleDropDown);
  }

  void _toggleDropDown(dom.MouseEvent event) {
    bool elementWasOpen = (element == _openElement);

    event.preventDefault();
    event.stopPropagation();

    if (_openElement != null) {
      _closeMenu(null);
    }

    if (!elementWasOpen && !element.classes.contains('disabled') && !toBool(element.attributes['disabled'])) {
      element.parent.classes.add('open');
      _openElement = element;
      _closeMenu = (dom.MouseEvent event) {
        if (event != null) {
          //event.preventDefault();
          event.stopPropagation();
        }
        element.parent.classes.remove('open');
        _closeMenu = (dom.MouseEvent evt) => {};
        _openElement = null;
      };
      dom.document.onClick.first.then((dom.MouseEvent evt) => _closeMenu(evt));
    }
  }
}