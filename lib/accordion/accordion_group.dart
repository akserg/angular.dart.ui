// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.accordion;

@NgComponent(
    selector: 'accordion-group',
    publishAs: 'ctrl',
    visibility: NgDirective.CHILDREN_VISIBILITY,
    templateUrl: 'packages/angular_ui/accordion/accordion_group.html',
    applyAuthorStyles: true
)
class AccordionGroupComponent implements NgDetachAware {
  @NgTwoWay('is-open') bool _isOpen = false;
  @NgAttr('heading') String heading;
  Scope scope;
  AccordionComponent accordion;

  AccordionGroupComponent(this.scope, this.accordion) {
    _log.fine('AccordionGroupComponent');
    accordion.addGroup(this);
  }

  get isOpen => _isOpen;
  
  set isOpen(var newValue) {
    _isOpen = utils.toBool(newValue);
    if (_isOpen) {
      accordion.closeOthers(this);
    }
  }
  
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
@NgComponent(
    selector: 'accordion-heading',
    publishAs: 'ctrl',
    template: '<content></content>',
    applyAuthorStyles: true
)
class AccordionHeadingComponent {
  Scope _scope;
  AccordionHeadingComponent(this._scope, AccordionGroupComponent accordionGroup) {
    _log.fine('AccordionHeadingComponent');
  }
}
