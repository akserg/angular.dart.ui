part of angular_ui_test;

void typeaheadPopupTests() {
  
  describe("[TypeaheadPopupComponent]", () {

    MockHttpBackend mockHttp;
    TestBed _;
    
    beforeEach(setUpInjector);
    afterEach(tearDownInjector);
  
    beforeEach(() {
      module((Module _) => _
        ..install(new TypeaheadModule())
      );
      inject((MockHttpBackend http, TestBed testBed) {
        mockHttp = http;
        _ = testBed;
        mockHttp.whenGET('packages/angular_ui/typeahead/typeahead-match.html').respond('<a tabindex="-1" ng-bind-html="match.label | highlight:query"></a>');
      });
      //return loadTemplates(['/typeahead/typeahead-match.html', '/typeahead/typeahead-popup.html']);
    });
    
    getHtml() {
      return '<typeahead-popup matches="matches" active="active" select="select(activeIdx)"></typeahead-popup>';
    }
    
    it('should render initial results', compileComponent(
        getHtml(), 
        {
          'matches': [new Item('foo'), new Item('bar'), new Item('baz') ],
          'active': 1
        }, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      mockHttp.flush();
      microLeap();
      digest();
      
      var liElems = shadowRoot.querySelectorAll("li");
  
      expect(liElems.length).toBe(3);
      expect(liElems.elementAt(0)).not.toHaveClass('active');
      expect(liElems.elementAt(1)).toHaveClass('active');
      expect(liElems.elementAt(2)).not.toHaveClass('active');
    }));
  
    it('should change active item on mouseenter', compileComponent(
        getHtml(), 
        {
          'matches': [new Item('foo'), new Item('bar'), new Item('baz') ],
          'active': 1
        }, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      mockHttp.flush();
      microLeap();
      digest();
      
      var liElems = shadowRoot.querySelectorAll("li");
      
      expect(liElems.elementAt(1)).toHaveClass('active');
      expect(liElems.elementAt(2)).not.toHaveClass('active');
  
      _.triggerEvent(liElems.elementAt(2), "mouseenter");
  
      expect(liElems.elementAt(1)).not.toHaveClass('active');
      expect(liElems.elementAt(2)).toHaveClass('active');
    }));
  
    it('should select an item on mouse click', compileComponent(
        getHtml(), 
        {
          'matches': [new Item('foo'), new Item('bar'), new Item('baz') ],
          'active': 1,
          'select': guinness.createSpy('select')
        }, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      mockHttp.flush();
      microLeap();
      digest();
      
      var liElems = shadowRoot.querySelectorAll("li");
  
      liElems.elementAt(2).click();
      expect(scope.context['select']).toHaveBeenCalledWith(2);
    }));
  
    it('should remove list if no matches', compileComponent(
        getHtml(), 
        {
          'matches': [],
          'active': 1,
          'select': guinness.createSpy('select')
        }, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      microLeap();
      digest();
      
      var typeaheadPopup = shadowRoot.querySelector('typeahead-popup');
      expect(typeaheadPopup).toBeDefined();
      expect(typeaheadPopup.children.length).toBe(0);
    }));
  
    it('should remove list if null matche list', compileComponent(
        getHtml(), 
        {
          'matches': null,
          'active': 1,
          'select': guinness.createSpy('select')
        }, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      microLeap();
      digest();
      
      var typeaheadPopup = shadowRoot.querySelector('typeahead-popup');
      expect(typeaheadPopup).toBeDefined();
      expect(typeaheadPopup.children.length).toBe(0);
    }));
  });
}

class Item {
  var id, label, model;
  Item(this.id, [this.label = null]) {
    if (label == null) label = id;
    model = this;
  }
}