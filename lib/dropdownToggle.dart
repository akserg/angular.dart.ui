library angular.ui.dropdownToggle;

import 'dart:html' as dom;
import "package:angular/angular.dart";

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
    this.element.onClick.listen(toggleDropDown);
  }

  void toggleDropDown(dom.MouseEvent event) {
    bool elementWasOpen = (element == _openElement);

    event.preventDefault();
    event.stopPropagation();

    if (_openElement != null) {
      _closeMenu(null);
    }

    if (!elementWasOpen && !element.classes.contains('disabled') && !element.attributes['disabled']) {
      element.parent.classes.add('open');
      _openElement = element;
      _closeMenu = (dom.MouseEvent event) {
        if (event != null) {
          event.preventDefault();
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