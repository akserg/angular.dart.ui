part of angular.ui.utils;

@NgDirective(
    selector: '[ng-pseudo]',
    map: const { 'ng-pseudo': '@name' }
)
class NgPseudo {
  dom.Element _element;
  set name(n) {
    _element.pseudo = n;
  }

  NgPseudo(dom.Element this._element);
}