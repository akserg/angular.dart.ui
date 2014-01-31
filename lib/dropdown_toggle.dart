// Copyright (c) 2013 - 2014, akserg (Sergey Akopkokhyants)
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
//
// Credits: Tonis Pool who wrote and donate that code.
//
library angular.ui.dropdown_toggle;

import 'dart:html' as dom;
import "package:angular/angular.dart";
import "package:angular/utils.dart";

/**
 * DropdownToggle Module.
 */
class DropdownToggleModule extends Module {
  DropdownToggleModule() {
    type(DropdownToggle);
  }
}

@NgDirective(
    selector: '[dropdown-toggle]'
)
class DropdownToggle {
  static dom.Element _openElement;
  static var _closeMenu = (dom.MouseEvent evt) => {};

  dom.Element element;
  Scope scope;

  DropdownToggle(this.element, this.scope) {
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