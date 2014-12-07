// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular_ui_test;

testPagerComponent() {
  describe("[PagerComponent]", () {
    TestBed _;
    Scope scope;
        
    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    beforeEach(() {
      module((Module _) => _
        ..install(new PaginationModule())
      );
      return loadTemplates(['/pagination/pager.html']);
    });

    /*****************/
    String getHtml() {
      return '<pager total-items="total" page="currentPage"></pager>';
    };
    
    Map getScope() {
      return {'total': 47, 'currentPage': 3};
    }
    
    /*********************/
    int getPaginationBarSize(pager) {
      return pager.querySelectorAll('li').length;
    }
    
    dom.Element getPaginationEl(pager, index) {
      return pager.querySelectorAll('li').elementAt(index);
    }
    
    String getPaginationElText(pager, index) {
      return getPaginationEl(pager, index).firstChild.text;
    }
    
    void clickPaginationEl(pager, index) {
      getPaginationEl(pager, index).querySelector('a').click();
    }
    
    /****************/
    void setTotalItems(scope, value) {
      scope.context['total'] = value;
    }
    
    int getCurrentPage(scope) => scope.context['currentPage'];

    void setCurrentPage(scope, value) {
      scope.context['currentPage'] = value;
    }

    void updateCurrentPage(scope, value) {
      scope.apply(() => setCurrentPage(scope, value));
    }
    
    it('has a "pager" css class', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pager = shadowRoot.querySelector('pager > ul');
      expect(pager).toHaveClass('pager');
    }));
    
    it('contains 2 li elements', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pager = shadowRoot.querySelector('pager > ul');
      expect(getPaginationBarSize(pager)).toBe(2);
      expect(getPaginationElText(pager, 0)).toEqual('« Previous');
      expect(getPaginationElText(pager, 1)).toEqual('Next »');
    }));
    
    it('aligns previous & next page', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pager = shadowRoot.querySelector('pager > ul');
      
      expect(getPaginationEl(pager, 0)).toHaveClass('previous');
      expect(getPaginationEl(pager, 0)).not.toHaveClass('next');

      expect(getPaginationEl(pager, 1)).not.toHaveClass('previous');
      expect(getPaginationEl(pager, 1)).toHaveClass('next');
    }));
    
    it('disables the "previous" link if current page is 1', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pager = shadowRoot.querySelector('pager > ul');
      
      updateCurrentPage(scope, 1);
      expect(getPaginationEl(pager, 0)).toHaveClass('disabled');
    }));
    
    it('disables the "next" link if current page is num-pages', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pager = shadowRoot.querySelector('pager > ul');
      
      updateCurrentPage(scope, 5);
      expect(getPaginationEl(pager, 1)).toHaveClass('disabled');
    }));
    
    it('changes currentPage if the "previous" link is clicked', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pager = shadowRoot.querySelector('pager > ul');
      
      clickPaginationEl(pager, 0);
      expect(getCurrentPage(scope)).toBe(2);
    }));

    it('changes currentPage if the "next" link is clicked', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pager = shadowRoot.querySelector('pager > ul');
      
      clickPaginationEl(pager, 1);
      expect(getCurrentPage(scope)).toBe(4);
    }));
    
    it('does not change the current page on "previous" click if already at first page', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pager = shadowRoot.querySelector('pager > ul');
      
      updateCurrentPage(scope, 1);
      clickPaginationEl(pager, 0);
      expect(getCurrentPage(scope)).toBe(1);
    }));
    
    it('does not change the current page on "next" click if already at last page', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pager = shadowRoot.querySelector('pager > ul');
      
      updateCurrentPage(scope, 5);
      clickPaginationEl(pager, 1);
      expect(getCurrentPage(scope)).toBe(5);
    }));
    
    it('executes the `on-select-page` expression when an element is clicked', compileComponent(
        '<pager total-items="total" page="currentPage" on-select-page="selectPageHandler()"></pager>', 
        {'total': 47, 'currentPage': 3, 'selectPageHandler': guinness.createSpy('selectPageHandler')}, 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pager = shadowRoot.querySelector('pager > ul');
      
      clickPaginationEl(pager, 1);
      expect(scope.context['selectPageHandler']).toHaveBeenCalled();
    }));
    
    it('does not changes the number of pages when `total-items` changes', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pager = shadowRoot.querySelector('pager > ul');
      
      scope.apply(() => setTotalItems(scope, 73)); // 8 pages

      expect(getPaginationBarSize(pager)).toBe(2);
      expect(getPaginationElText(pager, 0)).toEqual('« Previous');
      expect(getPaginationElText(pager, 1)).toEqual('Next »');
    }));
    
    describe('`items-per-page`', () {
      
      String getHtml() {
        return '<pager total-items="total" items-per-page="perPage" page="selectedPage"></pager>';
      };
      
      Map getScope() {
        return {'total': 47, 'perPage': 5, 'selectedPage': 3};
      }
      
      it('does not change the number of pages', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pager = shadowRoot.querySelector('pager > ul');
        
        expect(getPaginationBarSize(pager)).toBe(2);
        expect(getPaginationElText(pager, 0)).toEqual('« Previous');
        expect(getPaginationElText(pager, 1)).toEqual('Next »');
      }));

      it('selects the last page when it is too big', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pager = shadowRoot.querySelector('pager > ul');

        scope.context['perPage'] = 30;
        digest();

        expect(scope.context['selectedPage']).toBe(2);
        expect(getPaginationBarSize(pager)).toBe(2);
        expect(getPaginationEl(pager, 0)).not.toHaveClass('disabled');
        expect(getPaginationEl(pager, 1)).toHaveClass('disabled');
      }));
    });
    
    describe('when `page` is not a number', () {
      it('handles string', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pager = shadowRoot.querySelector('pager > ul');
        
        updateCurrentPage(scope,'1');
        expect(getPaginationEl(pager, 0)).toHaveClass('disabled');

        updateCurrentPage(scope, '05');
        expect(getPaginationEl(pager, 1)).toHaveClass('disabled');
      }));
    });
    
    describe('`num-pages`', () {
      it('equals to total number of pages', compileComponent(
          '<pager total-items="total" num-pages="numpg" page="currentPage"></pager>', 
          {'total': 47, 'currentPage': 3, 'numpg': null}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pager = shadowRoot.querySelector('pager > ul');
        
        expect(scope.context['numpg']).toBe(5);
      }));
    });
    
    describe('setting `pagerConfig`', () {
      
      beforeEach(() {
        inject((PagerConfig p) {
          p.itemsPerPage = 10;
          p.previousText = 'PR';
          p.nextText = 'NE';
          p.align = false;
        });
      });

      it('should change paging text', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pager = shadowRoot.querySelector('pager > ul');
        
        expect(getPaginationElText(pager, 0)).toEqual('PR');
        expect(getPaginationElText(pager, 1)).toEqual('NE');
      }));

      it('should not align previous & next page link', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pager = shadowRoot.querySelector('pager > ul');
        
        expect(getPaginationEl(pager, 0)).not.toHaveClass('previous');
        expect(getPaginationEl(pager, 1)).not.toHaveClass('next');
      }));
    });
    
    describe('override configuration from attributes', () {
      String getHtml() {
        return '<pager align="false" previous-text="<" next-text=">" total-items="total" page="currentPage"></pager>';
      };

      it('contains 2 li elements', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pager = shadowRoot.querySelector('pager > ul');
        
        expect(getPaginationBarSize(pager)).toBe(2);
      }));

      it('should change paging text from attributes', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pager = shadowRoot.querySelector('pager > ul');
        
        expect(getPaginationElText(pager, 0)).toEqual('<');
        expect(getPaginationElText(pager, 1)).toEqual('>');
      }));

      it('should not align previous & next page link', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pager = shadowRoot.querySelector('pager > ul');
        
        expect(getPaginationEl(pager, 0)).not.toHaveClass('previous');
        expect(getPaginationEl(pager, 1)).not.toHaveClass('next');
      }));

      it('changes "previous" & "next" text from interpolated attributes', compileComponent(
          '<pager align="false" previous-text="{{previousText}}" next-text="{{nextText}}" total-items="total" page="currentPage"></pager>', 
          {'total': 47, 'currentPage': 3, 'previousText': '<<', 'nextText': '>>'}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pager = shadowRoot.querySelector('pager > ul');
        

        expect(getPaginationElText(pager, 0)).toEqual('<<');
        expect(getPaginationElText(pager, 1)).toEqual('>>');
      }));
    });
  });
}
