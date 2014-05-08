part of angular.ui.typeahead;

@Component(
    selector: 'typeahead-popup',
    templateUrl: 'packages/angular_ui/typeahead/typeahead-popup.html',
    publishAs: 'ctrl',
    applyAuthorStyles: true,
    map: const {
        'matches': '=>matches',
        'active': '=>active',
        'select': '&selectEventHandler'
    })
class TypeaheadPopup {

  var matches;
  var active;
  Function selectEventHandler;

  TypeaheadPopup(Scope scope) {

  }

  bool get isOpen => (matches != null) && (matches.length != 0);

  bool isActive(index) => index == active;

  selectActive(index) => active = index;

  void selectMatch(index) {
    selectEventHandler({'activeIdx' : index});
  }
}