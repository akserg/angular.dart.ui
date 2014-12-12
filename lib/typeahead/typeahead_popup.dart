part of angular.ui.typeahead;

@Component(
  selector: 'typeahead-popup',
//  templateUrl: 'packages/angular_ui/typeahead/typeahead-popup.html',
  template: r'''
<ul class="dropdown-menu" ng-if="isOpen" ng-style="{top: position.top+'px', left: position.left+'px'}" style="display: block" role="listbox" aria-hidden="{{!isOpen}}">
    <li id="{{match.id}}" ng-repeat="match in matches" ng-class="{active: isActive($index)}" ng-mouseenter="selectActive($index)" ng-click="selectMatch($index)" role="option">
        <typeahead-match index="$index" match="match" query="query" template-url="templateUrl"></typeahead-match>
    </li>
</ul>''',
  useShadowDom: false,
  map: const {
    'matches': '=>matches',
    'active': '<=>active',
    'select': '&selectEventHandler',
    'position': '=>position',
    'template-url': '=>templateUrl',
    'query': '=>query'
  }
)
// <div typeahead-match index="$index" match="match" query="query" template-url="templateUrl"></div>
//@Component(selector: '[typeahead-popup]',
//  templateUrl: 'packages/angular_ui/typeahead/typeahead-popup.html',
//  publishAs: 'ctrl',
//  useShadowDom: false,
//  map: const {
//    'matches': '=>matches',
//    'active': '<=>active',
//    'select': '&selectEventHandler',
//    'position': '=>position',
//    'template-url': '=>templateUrl',
//    'query': '=>query'
//})
class TypeaheadPopup {

  List matches;
  int active;
  Function selectEventHandler;
  Rect _position;
  String templateUrl;
  String query;

  TypeaheadPopup();

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

@Injectable()
class TemplateBasedComponent implements DetachAware {

  final ViewFactoryCache _viewCache;

  Scope _viewScope;
  View _view;

  TemplateBasedComponent(this._viewCache);

  void detach() {
    _cleanUp();
  }

  void loadView(dom.Element element, Injector injector, Scope scope, String templateUrl, Object locals, [bool replace = false]) {
    DirectiveMap directives = injector.get(DirectiveMap);
    _viewCache.fromUrl(templateUrl, directives).then((ViewFactory viewFactory) {
      _cleanUp();
      // create a new scope
      DirectiveInjector directiveInjector = injector.get(DirectiveInjector);
      _viewScope = scope.createChild(locals);
       _view = viewFactory(_viewScope, directiveInjector);
       
       if(replace) {
         element.replaceWith(_view.nodes.firstWhere((e) { 
           return !(e is dom.Text); 
         }));
       } else {
         _view.nodes.forEach((e) { 
           return element.append(e); 
         });
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


@Decorator(
  selector : 'typeahead-match',
  map: const {
    'index': '=>!index',
    'match': '=>!match',
    'query': '=>!query',
    'template-url': '=>!templateUrl'
  }
)
@Decorator(selector : '[typeahead-match]',
  map: const {
    'index': '=>!index',
    'match': '=>!match',
    'query': '=>!query',
    'template-url': '=>!templateUrl'
  }
)
class TypeaheadMatch extends TemplateBasedComponent implements AttachAware, ScopeAware {
  static const String DEFAULT_MATCHED_ITEM_TEMPLATE = 'packages/angular_ui/typeahead/typeahead-match.html';

  final Injector _injector;
  final dom.Element _element;

  Scope scope;

  int index;
  var match;
  String query;
  String _templateUrl = DEFAULT_MATCHED_ITEM_TEMPLATE;

  TypeaheadMatch(this._element, this._injector, ViewFactoryCache viewCache) : super(viewCache);

  set templateUrl(String value) => _templateUrl = (value == null || value.isEmpty)? DEFAULT_MATCHED_ITEM_TEMPLATE: value;

  void attach() {
    loadView(_element, _injector, scope, _templateUrl, {'match': match, 'index':index, 'query':query}, true);
  }
}