part of angular.ui.typeahead.tests;

void typeaheadComponentTests() {

  beforeEach(setUpInjector);
  afterEach(tearDownInjector);

  TestBed _;
  Injector injector;
  Scope rootScope;
  TemplateCache cache;
  Compiler compile;
  dom.Element parentDiv;

  void loadTemplatesToCache() => addToTemplateCache(cache, 'packages/angular_ui/typeahead/typeahead-popup.html');

  void compileElement(String htmlText) {
    List<dom.Node> elements = $(htmlText);
    compile(elements, injector.get(DirectiveMap))(injector, elements);
    microLeap();
    rootScope.rootScope.apply();
    parentDiv = elements[0];
  }

  beforeEach(module((Module module) {
    module.install(new TypeaheadModule());

    return (Injector _injector, Scope scope, Compiler compiler, TemplateCache templateCache, TestBed testBed) {
      injector = _injector;
      rootScope = scope;
      compile = compiler;
      cache = templateCache;
      _ = testBed;

      loadTemplatesToCache();

      rootScope.context['source'] = ['foo', 'bar', 'baz'];
      rootScope.context['states'] = [{
          'code': 'AL', 'name': 'Alaska'
      }, {
          'code': 'CL', 'name': 'California'
      }];
    };
  }));

  dom.InputElement getInput() {
    return parentDiv.querySelector('input');
  }

  dom.Element getDropDown() {
    var typeaheadPopupContainer = parentDiv.querySelector('typeahead-popup');
    return typeaheadPopupContainer.shadowRoot.querySelector('ul.dropdown-menu');
  };

  changeInputValueTo(value) {
    getInput().value = value;
    _.triggerEvent(getInput(), 'input');
  }

  describe('initial state and model changes', () {

    it('should be closed by default', async(inject(() {
      compileElement('<div><input ng-model="result" typeahead="item for item in source"></input></div>');

      expect(getDropDown()).toBeNull();
    })));

    it('should correctly render initial state if the "as" keyword is used', async(inject((){
      rootScope.context['result'] = rootScope.context['states'][0];

      compileElement('<div><input ng-model="result" typeahead="state as state.name for state in states"></input></div>');
      expect(getInput().value).toEqual('Alaska');
    })));

    it('should default to bound model for initial rendering if there is not enough info to render label', async(inject((){
      rootScope.context['result'] = rootScope.context['states'][0]['code'];

      compileElement('<div><input ng-model="result" typeahead="state.code as state.name + state.code for state in states"></input></div>');
      expect(getInput().value).toEqual('AL');

    })));

    it('should not get open on model change', async(inject((){
      compileElement('<div><input ng-model="result" typeahead="item for item in source"></input></div>');

      rootScope.apply(()=>rootScope.context['result'] = 'foo');

      expect(getDropDown()).toBeNull();
    })));
  });

  describe('basic functionality', () {
    it('should open and close typeahead based on matches', async(inject((){
      compileElement(r'<div><input ng-model="result" typeahead="item for item in source | filter:$viewValue"></input></div>');

      expect(getInput().attributes['aria-expanded']).toBeFalsy();
      expect(getInput().attributes['aria-activedescendant']).toBeNull();

      changeInputValueTo('ba');

      expect(getDropDown()).toBeNotNull();
    })));
  });
}