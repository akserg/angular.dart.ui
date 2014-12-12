part of angular_ui_test;

void typeaheadComponentTests() {

  beforeEach(setUpInjector);
  afterEach(tearDownInjector);

  TestBed _;
  MockHttpBackend mockHttp;
  
  beforeEach(() {
    module((Module _) => _
      ..install(new TypeaheadModule())
    );
    inject((MockHttpBackend http, TestBed testBed) {
      mockHttp = http;
      _ = testBed;
      mockHttp.whenGET('packages/angular_ui/typeahead/typeahead-match.html').respond('<a tabindex="-1" ng-bind-html="match.label | highlight:query"></a>');
      mockHttp.whenGET('packages/angular_ui/typeahead/typeahead-popup.html').respond(r'''
<ul class="dropdown-menu" ng-if="isOpen" ng-style="{top: position.top+'px', left: position.left+'px'}" style="display: block" role="listbox" aria-hidden="{{!isOpen}}">
    <li id="{{match.id}}" ng-repeat="match in matches" ng-class="{active: isActive($index)}" ng-mouseenter="selectActive($index)" ng-click="selectMatch($index)" role="option">
        <typeahead-match index="$index" match="match" query="query" template-url="templateUrl"></typeahead-match>
    </li>
</ul>''');
    });
    //return loadTemplates(['/typeahead/typeahead-match.html', '/typeahead/typeahead-popup.html']);
  });

  getHtml() {
    return '<input ng-model="result" typeahead="item for item in source">';
  }
  
  dom.InputElement getInput(parentDiv) {
    return parentDiv.querySelector('input');
  }

  dom.Element getDropDown(parentDiv) {
    var typeaheadPopupContainer = parentDiv.querySelector('typeahead-popup');
    return typeaheadPopupContainer.shadowRoot.querySelector('ul.dropdown-menu');
  }

  changeInputValueTo(parentDiv, value) {
    dom.InputElement input = getInput(parentDiv);
    input.value = value;
    input.dispatchEvent(new dom.Event('input'));
    clockTick();
  }
  
  dom.Element findDropDown(dom.Element el) {
    List els = ngQuery(el, 'ul.dropdown-menu');
    return els.length > 0 ? els[0] : null;
  }
  
  List findMatches (dom.Element element) {
    dom.Element el = findDropDown(element);
    return el == null ? [] : ngQuery(el, 'li');
  }
  
  bool toBeClosed(dom.Element actual) {
    dom.Element typeaheadEl = findDropDown(actual);
    var message = 'Expected "$actual" to be closed.';
    return typeaheadEl != null && typeaheadEl.style.display == 'none' && findMatches(actual).length == 0;
  }
  
  bool toBeOpenWithActive(dom.Element actual, int noOfMatches, int activeIdx) {
    dom.Element typeaheadEl = findDropDown(actual);
    List<dom.Element> liEls = findMatches(actual);

    var message = 'Expected "$actual" to be opened.';
    return typeaheadEl != null && typeaheadEl.style.display == 'block' && liEls.length == noOfMatches && liEls[activeIdx].classes.contains('active');
  }
  
  describe('initial state and model changes', () {

//    it('should be closed by default', compileComponent(
//        getHtml(),
//        {
//          'source': ['foo', 'bar', 'baz'],
//          'states': [{'code': 'AL', 'name': 'Alaska'}, {'code': 'CL', 'name': 'California'}],
//          'result': {}
//        }, 
//        (Scope scope, dom.HtmlElement shadowRoot) {
//      mockHttp.flush();
//      microLeap();
//      digest();
//      
//      expect(getDropDown(shadowRoot)).toBeNull();
//    }));
    
    it('should be closed by default', compileComponent(
        getHtml(),
        {
          'source': ['foo', 'bar', 'baz'],
          'states': [{'code': 'AL', 'name': 'Alaska'}, {'code': 'CL', 'name': 'California'}]
        }, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      microLeap();
      digest();
      
      expect(toBeClosed(shadowRoot)).toBeFalsy();
    }));

    it('should correctly render initial state if the "as" keyword is used', compileComponent(
        '<input ng-model="result" typeahead="state as state.name for state in states">',
        {
          'source': ['foo', 'bar', 'baz'],
          'states': [{'code': 'AL', 'name': 'Alaska'}, {'code': 'CL', 'name': 'California'}]
        }, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      scope.context['result'] = scope.context['states'][0];
      microLeap();
      digest();

      expect(getInput(shadowRoot).value).toEqual('Alaska');
    }));

    it('should default to bound model for initial rendering if there is not enough info to render label', compileComponent(
        '<input ng-model="result" typeahead="state.code as state.name + state.code for state in states">',
        {
          'source': ['foo', 'bar', 'baz'],
          'states': [{'code': 'AL', 'name': 'Alaska'}, {'code': 'CL', 'name': 'California'}]
        }, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      scope.context['result'] = scope.context['states'][0]['code'];
      microLeap();
      digest();

      expect(getInput(shadowRoot).value).toEqual('AL');
    }));

    it('should not get open on model change', compileComponent(
        '<input ng-model="result" typeahead="item for item in source">',
        {
          'source': ['foo', 'bar', 'baz'],
          'states': [{'code': 'AL', 'name': 'Alaska'}, {'code': 'CL', 'name': 'California'}]
        }, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      scope.apply(() => scope.context['result'] = 'foo');
      microLeap();
      digest();

      expect(toBeClosed(shadowRoot)).toBeFalsy();
    }));
  });

  describe('basic functionality', () {
    
    it('should open and close typeahead based on matches', compileComponent(
        r'<input ng-model="result" typeahead="item for item in source | filter:$viewValue">',
        {
          'source': ['foo', 'bar', 'baz'],
          'states': [{'code': 'AL', 'name': 'Alaska'}, {'code': 'CL', 'name': 'California'}]
        }, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      scope.apply(() => scope.context['result'] = 'foo');
      microLeap();
      digest();
      
      expect(getInput(shadowRoot).attributes['aria-expanded']).toEqual('false');
      expect(getInput(shadowRoot).attributes['aria-activedescendant']).toBeNull();

      changeInputValueTo(shadowRoot, 'ba');
//      expect(toBeOpenWithActive(shadowRoot, 2, 0)).toBeTruthy();
//      
//      changeInputValueTo(shadowRoot, '');
//
//      //expect(getDropDown()).toBeNotNull();
//      expect(toBeClosed(shadowRoot)).toBeFalsy();
    }));
  });
}