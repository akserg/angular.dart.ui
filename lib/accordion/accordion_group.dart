// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.accordion;

@Component(
    selector: 'accordion-group',
    publishAs: 'ctrl',
    visibility: Directive.CHILDREN_VISIBILITY,
    templateUrl: 'packages/angular_ui/accordion/accordion_group.html',
    useShadowDom: false
)
class AccordionGroupComponent implements DetachAware {
  bool _isOpen = false;
  @NgAttr('heading') var heading;
  Scope scope;
  AccordionComponent accordion;

  AccordionGroupComponent(this.scope, this.accordion) {
    _log.fine('AccordionGroupComponent');
    accordion.addGroup(this);
  }

  @NgTwoWay('is-open') get isOpen => _isOpen;
  set isOpen(var newValue) {
    _isOpen = utils.toBool(newValue);
    if (_isOpen) {
      accordion.closeOthers(this);
    }
  }
  
  @override
  void detach() {
    this.accordion.removeGroup(this);
  }
}

/*
 * Use accordion-heading below an accordion-group to provide a heading containing HTML
 * <accordion-group>
 *   <accordion-heading>Heading containing HTML - <img src="..."></accordion-heading>
 * </accordion-group>
 */
@Decorator(
    selector: 'accordion-heading'
)
class AccordionHeadingComponent {
  AccordionHeadingComponent(html.Element elem, AccordionGroupComponent acc) {
    elem.remove();
    acc.heading = elem;
  }
}
