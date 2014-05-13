part of angular.ui.typeahead.tests;

void typeaheadPopupTests() {

  beforeEach(setUpInjector);
  afterEach(tearDownInjector);

  TestBed _;
  Injector injector;
  Scope rootScope;
  TemplateCache cache;
  Compiler compile;
  dom.Element element;
  dom.Element shadowElement;

  void loadTemplatesToCache() {
    addToTemplateCache(cache, 'packages/angular_ui/typeahead/typeahead-popup.html');
    addToTemplateCache(cache, 'packages/angular_ui/typeahead/typeahead-match.html');
  }

  void compileElement(String htmlText) {
    List<dom.Node> elements = $(htmlText);
    compile(elements, injector.get(DirectiveMap))(injector, elements);
    microLeap();
    rootScope.rootScope.apply();
    element = elements[0];

    try {
      shadowElement = getFirstUList(element.shadowRoot);
    } catch(e, s) {
      shadowElement = null;
    }
  }

  beforeEach(module((Module module){
    module.install(new TypeaheadModule());

    return (Injector _injector, Scope scope, Compiler compiler, TemplateCache templateCache, TestBed testBed) {
      injector = _injector;
      rootScope = scope;
      compile = compiler;
      cache = templateCache;
      _ = testBed;

      loadTemplatesToCache();
    };
  }));



//  it('should render initial results', async(inject((){
//    rootScope.context['matches'] = ['foo', 'bar', 'baz'];
//    rootScope.context['active'] = 1;
//
//    compileElement('<typeahead-popup matches="matches" active="active" select="select(activeIdx)"></typeahead-popup>');
//    var liElems = shadowElement.children.where((element) => element is dom.LIElement);
//
//    expect(liElems.length).toBe(3);
//    expect(liElems.elementAt(0)).not.toHaveClass('active');
//    expect(liElems.elementAt(1)).toHaveClass('active');
//    expect(liElems.elementAt(2)).not.toHaveClass('active');
//  })));

//  it('should change active item on mouseenter', async(inject((){
//    rootScope.context['matches'] = ['foo', 'bar', 'baz'];
//    rootScope.context['active'] = 1;
//
//    compileElement('<typeahead-popup matches="matches" active="active" select="select(activeIdx)"></typeahead-popup>');
//    var liElems = shadowElement.children.where((element) => element is dom.LIElement);
//
//    expect(liElems.elementAt(1)).toHaveClass('active');
//    expect(liElems.elementAt(2)).not.toHaveClass('active');
//
//    _.triggerEvent(liElems.elementAt(2), "mouseenter");
//
//    expect(liElems.elementAt(1)).not.toHaveClass('active');
//    expect(liElems.elementAt(2)).toHaveClass('active');
//  })));

//  it('should select an item on mouse click', async(inject((){
//    rootScope.context['matches'] = ['foo', 'bar', 'baz'];
//    rootScope.context['active'] = 1;
//    rootScope.context['select'] = jasmine.createSpy('select');
//
//    compileElement('<typeahead-popup matches="matches" active="active" select="select(activeIdx)"></typeahead-popup>');
//    var liElems = shadowElement.children.where((element) => element is dom.LIElement);
//    liElems.elementAt(2).click();
//    expect(rootScope.context['select']).toHaveBeenCalledWith(2);
//  })));

  it('should remove list if no matches', async(inject((){
    rootScope.context['matches'] = [];
    rootScope.context['active'] = 1;
    rootScope.context['select'] = jasmine.createSpy('select');

    compileElement('<typeahead-popup matches="matches" active="active" select="select(activeIdx)"></typeahead-popup>');
    expect(shadowElement).toBeNull();
  })));

  it('should remove list if null matche list', async(inject((){
    rootScope.context['matches'] = null;
    rootScope.context['active'] = 1;
    rootScope.context['select'] = jasmine.createSpy('select');

    compileElement('<typeahead-popup matches="matches" active="active" select="select(activeIdx)"></typeahead-popup>');
    expect(shadowElement).toBeNull();
  })));
}
