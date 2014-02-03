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
class AccordionGroupComponent {
  @NgTwoWay('is-open') bool isOpen = false;
  @NgAttr('heading') String heading;
  Scope scope;

  AccordionGroupComponent(this.scope, AccordionComponent accordion) {

    _log.fine('AccordionGroupComponent');
    accordion.addGroup(this);

    scope.$watch(() => isOpen, (value) {
      //_log.finer('watch: $value');

      if(value != null && value == true) {
        accordion.closeOthers(this);
      }
    });
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
