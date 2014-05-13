part of angular.ui.typeahead;

class TypeaheadMatchItem {
  String id;
  String label;
  var model;

  TypeaheadMatchItem(this.id, this.label, this.model);
}

@Component(selector: 'typeahead-popup',
  templateUrl: 'packages/angular_ui/typeahead/typeahead-popup.html',
  publishAs: 'ctrl',
  applyAuthorStyles: true,
  map: const {
    'matches': '=>matches',
    'active': '<=>active',
    'select': '&selectEventHandler',
    'position': '=>position',
    'template-url': '=>templateUrl',
    'query': '=>query'
})
class TypeaheadPopup {

  final Scope scope;

  List<TypeaheadMatchItem> matches;
  int active;
  Function selectEventHandler;
  Rect _position;
  String templateUrl;
  String query;

  TypeaheadPopup(this.scope);

  get position => _position;
  set position(value) => _position = value;

  bool get isOpen => (matches != null) && (matches.length != 0);

  bool isActive(index) => index == active;

  selectActive(index) => active = index;

  void selectMatch(index) {
    selectEventHandler({
        'activeIdx' : index
    });
  }
}

class TemplateBasedComponent implements DetachAware {

  final ViewCache _viewCache;

  Scope _viewScope;
  View _view;

  TemplateBasedComponent(this._viewCache);

  void detach() {
    _cleanUp();
  }

  void loadView(dom.Element element, Injector injector, Scope scope, String templateUrl, Map locals, [bool replace = false]) {
    var newDirectives = injector.get(DirectiveMap);
    _viewCache.fromUrl(templateUrl, newDirectives).then((ViewFactory viewFactory){
      _cleanUp();
      var map = new PrototypeMap(scope.context);
      map.addAll(locals);

      _viewScope = scope.createChild(map);
      _view = viewFactory(
          injector.createChild([new Module()..bind(Scope, toValue: _viewScope)]));

      if(replace) {

        element.replaceWith(_view.nodes.firstWhere((e) => !(e is dom.Text)));
      } else {
        _view.nodes.forEach((e) => element.append(e));
      }
    });

  }

  _cleanUp() {
    if (_view == null)
      return;

    _view.nodes.forEach((node) => node.remove());
    _viewScope.destroy();

    _view = null;
    _viewScope = null;
  }
}


@Decorator(selector : '[typeahead-match]',
  map: const {
    'index': '=>!index',
    'match': '=>!match',
    'query': '=>!query',
    'template-url': '=>!templateUrl'
  })
class TypeaheadMatch extends TemplateBasedComponent implements AttachAware {
  static const String DEFAULT_MATCHED_ITEM_TEMPLATE = 'packages/angular_ui/typeahead/typeahead-match.html';

  final Injector _injector;
  final dom.Element _element;

  Scope _scope;

  String index;
  var match;
  String query;
  String _templateUrl = DEFAULT_MATCHED_ITEM_TEMPLATE;

  TypeaheadMatch(this._element, this._injector, this._scope, ViewCache viewCache) : super(viewCache);

  set templateUrl(String value) => _templateUrl = (value == null || value.isEmpty)? DEFAULT_MATCHED_ITEM_TEMPLATE: value;

  void attach() {
    loadView(_element, _injector, _scope, _templateUrl, {'match': match, 'index': index, 'query': query}, true);
  }



}