// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular_ui_test;

testPaginationComponent() {
  describe("[PaginationComponent]", () {
    TestBed _;
    Scope scope;
        
    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    beforeEach(() {
      module((Module _) => _
        ..install(new PaginationModule())
      );
      return loadTemplates(['/pagination/pagination.html']);
    });
    
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
    
    void setItemsPerPage(scope, int value) {
      scope.context['perPage'] = value;
    }

    /*****************/
    String getHtml() {
      return '<pagination total-items="total" page="currentPage"></pagination>';
    };
    
    Map getScope() {
      return {'total': 47, 'currentPage': 3};
    }
    
    /*********************/
    int getPaginationBarSize(pagination) {
      return pagination.querySelectorAll('li').length;
    }
    
    dom.Element getPaginationEl(pagination, index) {
      return pagination.querySelectorAll('li').elementAt(index);
    }
    
    String getPaginationElText(pagination, index) {
      return getPaginationEl(pagination, index).firstChild.text;
    }
    
    void clickPaginationEl(pagination, index) {
      getPaginationEl(pagination, index).querySelector('a').click();
    }
    
    /****************/
    
    it('has a "pagination" css class', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pagination = shadowRoot.querySelector('pagination > ul');
      
      expect(pagination).toHaveClass('pagination');
    }));
    
    it('contains num-pages + 2 li elements', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pagination = shadowRoot.querySelector('pagination > ul');
      
      expect(getPaginationBarSize(pagination)).toBe(7);
      expect(getPaginationElText(pagination, 0)).toEqual('Previous');
      expect(getPaginationElText(pagination, 6)).toEqual('Next');
    }));
    
    it('has the number of the page as text in each page item', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pagination = shadowRoot.querySelector('pagination > ul');
      
      for (var i = 1; i <= 5; i++) {
        expect(getPaginationElText(pagination, i)).toEqual('$i');
      }
    }));
    
    it('sets the current page to be active', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pagination = shadowRoot.querySelector('pagination > ul');
      
      expect(getPaginationEl(pagination, getCurrentPage(scope))).toHaveClass('active');
    }));

    it('disables the "previous" link if current page is 1', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pagination = shadowRoot.querySelector('pagination > ul');
      
      updateCurrentPage(scope, 1);
      expect(getPaginationEl(pagination, 0)).toHaveClass('disabled');
    }));

    it('disables the "next" link if current page is last', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pagination = shadowRoot.querySelector('pagination > ul');
      
      updateCurrentPage(scope, 5);
      expect(getPaginationEl(pagination, 6)).toHaveClass('disabled');
    }));

    it('changes currentPage if a page link is clicked', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pagination = shadowRoot.querySelector('pagination > ul');
      
      clickPaginationEl(pagination, 2);
      expect(getCurrentPage(scope)).toBe(2);
    }));

    it('changes currentPage if the "previous" link is clicked', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pagination = shadowRoot.querySelector('pagination > ul');
      
      clickPaginationEl(pagination, 0);
      expect(getCurrentPage(scope)).toBe(2);
    }));

    it('changes currentPage if the "next" link is clicked', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pagination = shadowRoot.querySelector('pagination > ul');
      
      clickPaginationEl(pagination, 6);
      expect(getCurrentPage(scope)).toBe(4);
    }));
    
    it('does not change the current page on "previous" click if already at first page', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pagination = shadowRoot.querySelector('pagination > ul');
      
      updateCurrentPage(scope, 1);
      clickPaginationEl(pagination, 0);
      expect(getCurrentPage(scope)).toBe(1);
    }));

    it('does not change the current page on "next" click if already at last page', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pagination = shadowRoot.querySelector('pagination > ul');
      
      updateCurrentPage(scope, 5);
      clickPaginationEl(pagination, 6);
      expect(getCurrentPage(scope)).toBe(5);
    }));

    it('changes the number of pages when `total-items` changes', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pagination = shadowRoot.querySelector('pagination > ul');
      
      scope.apply(() => setTotalItems(scope, 78)); // 8 pages

      expect(getPaginationBarSize(pagination)).toBe(10);
      expect(getPaginationElText(pagination, 0)).toEqual('Previous');
      expect(getPaginationElText(pagination, 9)).toEqual('Next');
    }));

    it('does not "break" when `total-items` is undefined', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pagination = shadowRoot.querySelector('pagination > ul');
      
      scope.apply(() => setTotalItems(scope, null));

      expect(getPaginationBarSize(pagination)).toBe(3); // Previous, 1, Next
      expect(getPaginationEl(pagination, 0)).toHaveClass('disabled');
      expect(getPaginationEl(pagination, 1)).toHaveClass('active');
      expect(getPaginationEl(pagination, 2)).toHaveClass('disabled');
    }));

    it('does not "break" when `total-items` is negative', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pagination = shadowRoot.querySelector('pagination > ul');
      
      scope.apply(() => setTotalItems(scope, -1));

      expect(getPaginationBarSize(pagination)).toBe(3); // Previous, 1, Next
      expect(getPaginationEl(pagination, 0)).toHaveClass('disabled');
      expect(getPaginationEl(pagination, 1)).toHaveClass('active');
      expect(getPaginationEl(pagination, 2)).toHaveClass('disabled');
    }));
    
    it('does not change the current page when `total-items` changes but is valid', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var pagination = shadowRoot.querySelector('pagination > ul');
      
      scope.apply(() {
        setCurrentPage(scope, 1);
        setTotalItems(scope, 18);
      }); // 2 pages

      expect(getCurrentPage(scope)).toBe(1);
    }));
    describe('`items-per-page`', () {
      
      String getHtml() {
        return '<pagination total-items="total" items-per-page="perPage" page="selectedPage"></pagination>';
      };
      
      Map getScope() {
        return {'total': 47, 'perPage': 5, 'selectedPage': 3};
      }
          
      it('changes the number of pages', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        expect(getPaginationBarSize(pagination)).toBe(12);
        expect(getPaginationElText(pagination, 0)).toEqual('Previous');
        expect(getPaginationElText(pagination, 11)).toEqual('Next');
      }));

      it('changes the number of pages when changes', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        scope.apply(() => setItemsPerPage(scope, 20));

        expect(getPaginationBarSize(pagination)).toBe(5);
        expect(getPaginationElText(pagination, 0)).toEqual('Previous');
        expect(getPaginationElText(pagination, 4)).toEqual('Next');
      }));

      it('selects the last page when current page is too big', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        scope.apply(() => setItemsPerPage(scope, 30));

        expect(scope.context['selectedPage']).toBe(2);
        expect(getPaginationBarSize(pagination)).toBe(4);
        expect(getPaginationElText(pagination, 0)).toEqual('Previous');
        expect(getPaginationElText(pagination, 3)).toEqual('Next');
      }));

      it('displays a single page when it is negative', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        scope.apply(() => setItemsPerPage(scope, -1));

        expect(getPaginationBarSize(pagination)).toBe(3);
        expect(getPaginationElText(pagination, 0)).toEqual('Previous');
        expect(getPaginationElText(pagination, 1)).toEqual('1');
        expect(getPaginationElText(pagination, 2)).toEqual('Next');
      }));
    });
    
    describe('executes  `on-select-page` expression', () {
      
      String getHtml() {
        return '<pagination total-items="total" page="currentPage" on-select-page="selectPageHandler()"></pagination>';
      };
      
      Map getScope() {
        return {'total': 47, 'currentPage': 3, 'selectPageHandler': guinness.createSpy('selectPageHandler')};
      }
          
      it('when an element is clicked', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        clickPaginationEl(pagination, 2);
        expect(scope.context['selectPageHandler']).toHaveBeenCalled();
      }));
    });
    
    describe('when `page` is not a number', () {
      it('handles numerical string', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        updateCurrentPage(scope, '2');
        expect(getPaginationEl(pagination, 2)).toHaveClass('active');

        updateCurrentPage(scope, '04');
        expect(getPaginationEl(pagination, 4)).toHaveClass('active');
      }));

      it('defaults to 1 if non-numeric', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        updateCurrentPage(scope, 'pizza');
        expect(getPaginationEl(pagination, 1)).toHaveClass('active');
      }));
    });
    
    describe('with `max-size` option', (){

      String getHtml() {
        return '<pagination total-items="total" page="currentPage" max-size="maxSize"></pagination>';
      };
      
      Map getScope() {
        return {'total': 98, 'currentPage': 3, 'maxSize': 5};
      }

      it('contains maxsize + 2 li elements', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        expect(getPaginationBarSize(pagination)).toBe(7);
        expect(getPaginationElText(pagination, 0)).toEqual('Previous');
        expect(getPaginationElText(pagination, 6)).toEqual('Next');
      }));

      it('shows the page number even if it can\'t be shown in the middle', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        updateCurrentPage(scope, 1);
        expect(getPaginationEl(pagination, 1)).toHaveClass('active');

        updateCurrentPage(scope, 10);
        expect(getPaginationEl(pagination, 5)).toHaveClass('active');
      }));

      it('shows the page number in middle after the next link is clicked', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        updateCurrentPage(scope, 6);
        clickPaginationEl(pagination, 6);

        expect(getCurrentPage(scope)).toBe(7);
        expect(getPaginationEl(pagination, 3)).toHaveClass('active');
        expect(getPaginationElText(pagination, 3)).toEqual(getCurrentPage(scope).toString());
      }));

      it('shows the page number in middle after the prev link is clicked', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        updateCurrentPage(scope, 7);
        clickPaginationEl(pagination, 0);

        expect(getCurrentPage(scope)).toBe(6);
        expect(getPaginationEl(pagination, 3)).toHaveClass('active');
        expect(getPaginationElText(pagination, 3)).toEqual(getCurrentPage(scope).toString());
      }));

      it('changes pagination bar size when max-size value changed', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        scope.apply(() => scope.context['maxSize'] = 7);
        expect(getPaginationBarSize(pagination)).toBe(9);
      }));

      it('sets the pagination bar size to num-pages, if max-size is greater than num-pages', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        scope.apply(() => scope.context['maxSize'] = 15);
        expect(getPaginationBarSize(pagination)).toBe(12);
      }));

      it('should not change value of max-size expression, if max-size is greater than num-pages', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        scope.apply(() => scope.context['maxSize'] = 15);
        expect(scope.context['maxSize']).toBe(15);
      }));

      it('should not display page numbers, if max-size is zero', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        scope.apply(() => scope.context['maxSize'] = 0);
        expect(getPaginationBarSize(pagination)).toBe(2);
        expect(getPaginationElText(pagination, 0)).toEqual('Previous');
        expect(getPaginationElText(pagination, 1)).toEqual('Next');
      }));
    });
    
    describe('with `max-size` option & no `rotate`', (){
      
      String getHtml() {
        return '<pagination total-items="total" page="currentPage" max-size="maxSize" rotate="rotate"></pagination>';
      };
      
      Map getScope() {
        return {'total': 115, 'currentPage': 7, 'maxSize': 5, 'rotate': false};
      }

      it('contains maxsize + 4 elements', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        expect(getPaginationBarSize(pagination)).toBe(9);
        expect(getPaginationElText(pagination, 0)).toEqual('Previous');
        expect(getPaginationElText(pagination, 1)).toEqual('...');
        expect(getPaginationElText(pagination, 2)).toEqual('6');
        expect(getPaginationElText(pagination, 6)).toEqual('10');
        expect(getPaginationElText(pagination, 7)).toEqual('...');
        expect(getPaginationElText(pagination, 8)).toEqual('Next');
      }));

      it('shows only the next ellipsis element on first page set', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        updateCurrentPage(scope, 3);
        expect(getPaginationElText(pagination, 1)).toEqual('1');
        expect(getPaginationElText(pagination, 5)).toEqual('5');
        expect(getPaginationElText(pagination, 6)).toEqual('...');
      }));

      it('shows only the previous ellipsis element on last page set', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        updateCurrentPage(scope, 12);
        expect(getPaginationElText(pagination, 1)).toEqual('...');
        expect(getPaginationElText(pagination, 2)).toEqual('11');
        expect(getPaginationElText(pagination, 3)).toEqual('12');
      }));

      it('moves to the previous set when first ellipsis is clicked', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        expect(getPaginationElText(pagination, 1)).toEqual('...');

        clickPaginationEl(pagination, 1);

        expect(getCurrentPage(scope)).toEqual(5);
        expect(getPaginationEl(pagination, 5)).toHaveClass('active');
      }));

      it('moves to the next set when last ellipsis is clicked', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        expect(getPaginationElText(pagination, 7)).toEqual('...');

        clickPaginationEl(pagination, 7);

        expect(getCurrentPage(scope)).toEqual(11);
        expect(getPaginationEl(pagination, 2)).toHaveClass('active');
      }));

      it('should not display page numbers, if max-size is zero', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        scope.apply(() => scope.context['maxSize'] = 0);
        expect(getPaginationBarSize(pagination)).toBe(2);
        expect(getPaginationElText(pagination, 0)).toEqual('Previous');
        expect(getPaginationElText(pagination, 1)).toEqual('Next');
      }));
    });
    
    describe('pagination directive with `boundary-links`', (){
      String getHtml() {
        return '<pagination boundary-links="true" total-items="total" page="currentPage"></pagination>';
      };
      
      it('contains num-pages + 4 li elements', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        expect(getPaginationBarSize(pagination)).toBe(9);
        expect(getPaginationElText(pagination, 0)).toEqual('First');
        expect(getPaginationElText(pagination, 1)).toEqual('Previous');
        expect(getPaginationElText(pagination, 7)).toEqual('Next');
        expect(getPaginationElText(pagination, 8)).toEqual('Last');
      }));

      it('has first and last li elements visible', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        expect(getPaginationEl(pagination, 0).style.display).not.toEqual('none');
        expect(getPaginationEl(pagination, 8).style.display).not.toEqual('none');
      }));

      it('disables the "first" & "previous" link if current page is 1', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        updateCurrentPage(scope, 1);

        expect(getPaginationEl(pagination, 0)).toHaveClass('disabled');
        expect(getPaginationEl(pagination, 1)).toHaveClass('disabled');
      }));

      it('disables the "last" & "next" link if current page is num-pages', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        updateCurrentPage(scope, 5);

        expect(getPaginationEl(pagination, 7)).toHaveClass('disabled');
        expect(getPaginationEl(pagination, 8)).toHaveClass('disabled');
      }));

      it('changes currentPage if the "first" link is clicked', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        clickPaginationEl(pagination, 0);
        expect(getCurrentPage(scope)).toBe(1);
      }));

      it('changes currentPage if the "last" link is clicked', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        clickPaginationEl(pagination, 8);
        expect(getCurrentPage(scope)).toBe(5);
      }));

      it('does not change the current page on "first" click if already at first page', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        updateCurrentPage(scope, 1);
        clickPaginationEl(pagination, 0);
        expect(getCurrentPage(scope)).toBe(1);
      }));

      it('does not change the current page on "last" click if already at last page', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        updateCurrentPage(scope, 5);
        clickPaginationEl(pagination, 8);
        expect(getCurrentPage(scope)).toBe(5);
      }));

      it('changes "first" & "last" text from attributes', compileComponent(
          '<pagination boundary-links="true" first-text="<<<" last-text=">>>" total-items="total" page="currentPage"></pagination>', 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        expect(getPaginationElText(pagination, 0)).toEqual('<<<');
        expect(getPaginationElText(pagination, 8)).toEqual('>>>');
      }));

      it('changes "previous" & "next" text from attributes', compileComponent(
          '<pagination boundary-links="true" previous-text="<<" next-text=">>" total-items="total" page="currentPage"></pagination>', 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        expect(getPaginationElText(pagination, 1)).toEqual('<<');
        expect(getPaginationElText(pagination, 7)).toEqual('>>');
      }));

      it('changes "first" & "last" text from interpolated attributes', compileComponent(
          '<pagination boundary-links="true" first-text="{{myFirstText}}" last-text="{{myNextText}}" total-items="total" page="currentPage"></pagination>', 
          {'total': 47, 'currentPage': 3, 'myFirstText': '<<<', 'myNextText': '>>>'}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');

        expect(getPaginationElText(pagination, 0)).toEqual('<<<');
        expect(getPaginationElText(pagination, 8)).toEqual('>>>');
      }));

      it('changes "previous" & "next" text from interpolated attributes', compileComponent(
          '<pagination boundary-links="true" previous-text="{{previousText}}" next-text="{{nextText}}" total-items="total" page="currentPage"></pagination>', 
          {'total': 47, 'currentPage': 3, 'previousText': '<<', 'nextText': '>>'}, 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');

        expect(getPaginationElText(pagination, 1)).toEqual('<<');
        expect(getPaginationElText(pagination, 7)).toEqual('>>');
      }));
    });
    
    describe('pagination directive with just number links', (){
      
      String getHtml() {
        return '<pagination direction-links="false" total-items="total" page="currentPage"></pagination>';
      };

      it('contains num-pages li elements', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        expect(getPaginationBarSize(pagination)).toBe(5);
        expect(getPaginationElText(pagination, 0)).toEqual('1');
        expect(getPaginationElText(pagination, 4)).toEqual('5');
      }));

      it('has the number of the page as text in each page item', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        for(var i = 0; i < 5; i++) {
          expect(getPaginationElText(pagination, i)).toEqual((i+1).toString());
        }
      }));

      it('sets the current page to be active', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        expect(getPaginationEl(pagination, 2)).toHaveClass('active');
      }));

      it('does not disable the "1" link if current page is 1',compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        updateCurrentPage(scope, 1);

        expect(getPaginationEl(pagination, 0)).not.toHaveClass('disabled');
        expect(getPaginationEl(pagination, 0)).toHaveClass('active');
      }));

      it('does not disable the "last" link if current page is last page', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        updateCurrentPage(scope, 5);

        expect(getPaginationEl(pagination, 4)).not.toHaveClass('disabled');
        expect(getPaginationEl(pagination, 4)).toHaveClass('active');
      }));

      it('changes currentPage if a page link is clicked', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        clickPaginationEl(pagination, 1);

        expect(getCurrentPage(scope)).toBe(2);
      }));

      it('changes the number of items when total items changes', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        scope.apply(()=> setTotalItems(scope, 73)); // 8 pages

        expect(getPaginationBarSize(pagination)).toBe(8);
        expect(getPaginationElText(pagination, 0)).toEqual('1');
        expect(getPaginationElText(pagination, 7)).toEqual('8');
      }));
    });
    
    describe('with just boundary & number links', (){
      
      String getHtml() {
        return '<pagination boundary-links="true" direction-links="directions" total-items="total" page="currentPage"></pagination>';
      };
      
      Map getScope() {
        return {'total': 47, 'currentPage': 3, 'directions': false};
      }

      it('contains number of pages + 2 li elements', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        expect(getPaginationBarSize(pagination)).toBe(7);
        expect(getPaginationElText(pagination, 0)).toEqual('First');
        expect(getPaginationElText(pagination, 1)).toEqual('1');
        expect(getPaginationElText(pagination, 5)).toEqual('5');
        expect(getPaginationElText(pagination, 6)).toEqual('Last');
      }));

      it('disables the "first" & activates "1" link if current page is 1', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        updateCurrentPage(scope, 1);

        expect(getPaginationEl(pagination, 0)).toHaveClass('disabled');
        expect(getPaginationEl(pagination, 1)).not.toHaveClass('disabled');
        expect(getPaginationEl(pagination, 1)).toHaveClass('active');
      }));

      it('disables the "last" & "next" link if current page is num-pages', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var pagination = shadowRoot.querySelector('pagination > ul');
        
        updateCurrentPage(scope, 5);

        expect(getPaginationEl(pagination, 5)).toHaveClass('active');
        expect(getPaginationEl(pagination, 5)).not.toHaveClass('disabled');
        expect(getPaginationEl(pagination, 6)).toHaveClass('disabled');
      }));
    });
    
    describe('`num-pages`', (){
      
      String getHtml() {
        return '<pagination total-items="total" page="currentPage" num-pages="numpg"></pagination>';
      };
      
      Map getScope() {
        return {'total': 47, 'currentPage': 3, 'numpg': null};
      }
            
      it('disables the "last" & "next" link if current page is num-pages', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        
        expect(scope.context['numpg']).toBe(5);
      }));

      it('changes when total number of pages change', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        
        scope.apply(()=>setTotalItems(scope, 73)); // 8 pages
        expect(scope.context['numpg']).toBe(8);
      }));

      it('shows minimun one page if total items are not defined and does not break binding', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        
        scope.apply(()=>setTotalItems(scope, null));
        expect(scope.context['numpg']).toBe(1);

        scope.apply(()=>setTotalItems(scope, 73)); // 8 pages
        expect(scope.context['numpg']).toBe(8);
      }));
    });

    describe('setting `paginationConfig`', (){
      
      it('shows minimun one page if total items are not defined and does not break binding', async(inject((PaginationConfig paginationConfig){
        paginationConfig.boundaryLinks = true;
        paginationConfig.directionLinks = true;
        paginationConfig.firstText = 'FI';
        paginationConfig.previousText = 'PR';
        paginationConfig.nextText = 'NE';
        paginationConfig.lastText = 'LA';
        
        compileComponent(getHtml(), getScope(), (Scope scope, dom.HtmlElement shadowRoot) {
          var pagination = shadowRoot.querySelector('pagination > ul');
          
          expect(getPaginationElText(pagination, 0)).toEqual('FI');
          expect(getPaginationElText(pagination, 1)).toEqual('PR');
          expect(getPaginationElText(pagination, 7)).toEqual('NE');
          expect(getPaginationElText(pagination, 8)).toEqual('LA');
        });
      })));

      it('contains number of pages + 2 li elements', async(inject((PaginationConfig paginationConfig){
        paginationConfig.itemsPerPage = 5;
        compileComponent(getHtml(), getScope(), (Scope scope, dom.HtmlElement shadowRoot) {
          var pagination = shadowRoot.querySelector('pagination > ul');
          
          expect(getPaginationBarSize(pagination)).toBe(12);
        });
      })));

      it('should take maxSize defaults into account', async(inject((PaginationConfig paginationConfig){
        paginationConfig.maxSize = 2;
        compileComponent(getHtml(), getScope(), (Scope scope, dom.HtmlElement shadowRoot) {
          var pagination = shadowRoot.querySelector('pagination > ul');

          expect(getPaginationBarSize(pagination)).toBe(4);
        });
      })));
    });
  });    
}
