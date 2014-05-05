// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void pagerTests() {

  describe('Testing pager:', () {

    Scope rootScope;
    Injector injector;
    Compiler compile;
    TemplateCache cache;
    dom.Element shadowElement;
    dom.Element element;

    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    afterEach(() {
      shadowElement = null;
      element = null;
      rootScope = null;
      cache = null;
      compile = null;
      injector = null;
    });

    void compileElement(String htmlText) {
      List<dom.Node> elements = $(htmlText);
      compile(elements, injector.get(DirectiveMap))(injector, elements);
      microLeap();
      rootScope.rootScope.apply();
      element = elements[0];
      shadowElement = getFirstUList(element.shadowRoot);
    }

    void loadTemplatesToCache() => addToTemplateCache(cache, 'packages/angular_ui/pagination/pager.html');

    void setTotalItems(value) {
      rootScope.context['total'] = value;
    }

    int getCurrentPage() => rootScope.context['currentPage'];

    void setCurrentPage(value) {
      rootScope.context['currentPage'] = value;
    }

    void setItemsPerPage(int value) {
      rootScope.context['perPage'] = value;
    }

    beforeEach(module((Module module) {
      module.install(new PaginationModule());
      return (Injector _injector) {
        injector = _injector;
        compile = injector.get(Compiler);
        rootScope = injector.get(Scope);
        cache = injector.get(TemplateCache);
        loadTemplatesToCache();
        setTotalItems(47);
        setCurrentPage(3);
        compileElement('<pager total-items="total" page="currentPage"></pager>');
      };
    }));


    int getPaginationBarSize() {
      return shadowElement.querySelectorAll('li').length;
    }

    dom.Element getPaginationEl(index) {
      return shadowElement.querySelectorAll('li').elementAt(index);
    }

    String getPaginationElText(index) {
      return getPaginationEl(index).firstChild.text;
    }

    void clickPaginationEl(index) {
      getPaginationEl(index).querySelector('a').click();
    }

    void updateCurrentPage(value) {
      rootScope.apply(() => setCurrentPage(value));
    }


    it('has a "pager" css class', async(inject(() {
      expect(shadowElement).toHaveClass('pager');
    })));

    it('contains 2 li elements', async(inject(() {
      expect(getPaginationBarSize()).toBe(2);
      expect(getPaginationElText(0)).toEqual('« Previous');
      expect(getPaginationElText(1)).toEqual('Next »');
    })));

    it('aligns previous & next page', async(inject(() {
      expect(getPaginationEl(0)).toHaveClass('previous');
      expect(getPaginationEl(0)).not.toHaveClass('next');

      expect(getPaginationEl(1)).not.toHaveClass('previous');
      expect(getPaginationEl(1)).toHaveClass('next');
    })));

    it('disables the "previous" link if current page is 1', async(inject(() {
      updateCurrentPage(1);
      expect(getPaginationEl(0)).toHaveClass('disabled');
    })));

    it('disables the "next" link if current page is num-pages', async(inject(() {
      updateCurrentPage(5);
      expect(getPaginationEl(1)).toHaveClass('disabled');
    })));

    it('changes currentPage if the "previous" link is clicked', async(inject(() {
      clickPaginationEl(0);
      expect(getCurrentPage()).toBe(2);
    })));

    it('changes currentPage if the "next" link is clicked', async(inject(() {
      clickPaginationEl(1);
      expect(getCurrentPage()).toBe(4);
    })));

    it('does not change the current page on "previous" click if already at first page', async(inject(() {
      updateCurrentPage(1);
      clickPaginationEl(0);
      expect(getCurrentPage()).toBe(1);
    })));

    it('does not change the current page on "next" click if already at last page', async(inject(() {
      updateCurrentPage(5);
      clickPaginationEl(1);
      expect(getCurrentPage()).toBe(5);
    })));

    it('executes the `on-select-page` expression when an element is clicked', async(inject(() {
      rootScope.context['selectPageHandler'] = jasmine.createSpy('selectPageHandler');
      compileElement('<pager total-items="total" page="currentPage" on-select-page="selectPageHandler()"></pager>');
      clickPaginationEl(1);
      expect(rootScope.context['selectPageHandler']).toHaveBeenCalled();
    })));

    it('does not changes the number of pages when `total-items` changes', async(inject(() {
      rootScope.apply(() => setTotalItems(73)); // 8 pages

      expect(getPaginationBarSize()).toBe(2);
      expect(getPaginationElText(0)).toEqual('« Previous');
      expect(getPaginationElText(1)).toEqual('Next »');
    })));

    describe('`items-per-page`', () {
      beforeEach(module((Module module) {
        return (Injector _injector) {
          setItemsPerPage(5);
          rootScope.context['selectedPage'] = 3;
          compileElement('<pager total-items="total" items-per-page="perPage" page="selectedPage"></pager>');
        };
      }));

      it('does not change the number of pages', async(inject(() {
        expect(getPaginationBarSize()).toBe(2);
        expect(getPaginationElText(0)).toEqual('« Previous');
        expect(getPaginationElText(1)).toEqual('Next »');
      })));

      it('selects the last page when it is too big', async(inject(() {

        rootScope.apply(() => setItemsPerPage(30));

        expect(rootScope.context['selectedPage']).toBe(2);
        expect(getPaginationBarSize()).toBe(2);
        expect(getPaginationEl(0)).not.toHaveClass('disabled');
        expect(getPaginationEl(1)).toHaveClass('disabled');
      })));

    });

    describe('when `page` is not a number', () {
      it('handles string', async(inject(() {
        updateCurrentPage('1');
        expect(getPaginationEl(0)).toHaveClass('disabled');

        updateCurrentPage('05');
        expect(getPaginationEl(1)).toHaveClass('disabled');
      })));

    });

    describe('`num-pages`', () {
      beforeEach(module((Module module) {
        return (Injector _injector) {
          rootScope.context['numpg'] = null;
          compileElement('<pager total-items="total" num-pages="numpg" page="currentPage"></pager>');
        };
      }));

      it('equals to total number of pages', async(inject(() {
        expect(rootScope.context['numpg']).toBe(5);
      })));
    });

    describe('setting `pagerConfig`', () {
      beforeEach(module((Module module) {
        module.value(PagerConfig, new PagerConfig(10, 'PR', 'NE', false));
      }));

      it('should change paging text', async(inject(() {
        expect(getPaginationElText(0)).toEqual('PR');
        expect(getPaginationElText(1)).toEqual('NE');
      })));

      it('should not align previous & next page link', async(inject(() {
        expect(getPaginationEl(0)).not.toHaveClass('previous');
        expect(getPaginationEl(1)).not.toHaveClass('next');
      })));
    });

    describe('override configuration from attributes', () {
      beforeEach(module((Module module) {
        return (Injector injector) {
          compileElement('<pager align="false" previous-text="<" next-text=">" total-items="total" page="currentPage"></pager>');
        };
      }));

      it('contains 2 li elements', async(inject(() {
        expect(getPaginationBarSize()).toBe(2);
      })));

      it('should change paging text from attributes', async(inject(() {
        expect(getPaginationElText(0)).toEqual('<');
        expect(getPaginationElText(1)).toEqual('>');
      })));

      it('should not align previous & next page link', async(inject(() {
        expect(getPaginationEl(0)).not.toHaveClass('previous');
        expect(getPaginationEl(1)).not.toHaveClass('next');
      })));

      it('changes "previous" & "next" text from interpolated attributes', async(inject(() {
        rootScope.context['previousText'] = '<<';
        rootScope.context['nextText'] = '>>';
        compileElement('<pager align="false" previous-text="{{previousText}}" next-text="{{nextText}}" total-items="total" page="currentPage"></pager>');

        expect(getPaginationElText(0)).toEqual('<<');
        expect(getPaginationElText(1)).toEqual('>>');
      })));
    });
  });

}

void paginationTests() {

  describe('Testing pagination:', () {

    Scope rootScope;
    Injector injector;
    Compiler compile;
    TemplateCache cache;
    dom.Element shadowElement;
    dom.Element element;

    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    afterEach(() {
      shadowElement = null;
      element = null;
      rootScope = null;
      cache = null;
      compile = null;
      injector = null;
    });

    void compileElement(String htmlText) {
      List<dom.Node> elements = $(htmlText);
      compile(elements, injector.get(DirectiveMap))(injector, elements);
      microLeap();
      rootScope.rootScope.apply();
      element = elements[0];
      shadowElement = getFirstUList(element.shadowRoot);
    }

    void loadTemplatesToCache() => addToTemplateCache(cache, 'packages/angular_ui/pagination/pagination.html');

    void setTotalItems(value) { 
      rootScope.context['total'] = value;
    }

    int getCurrentPage() => rootScope.context['currentPage'];

    void setCurrentPage(value) { 
      rootScope.context['currentPage'] = value;
    }

    void setItemsPerPage(int value) {
      rootScope.context['perPage'] = value;
    }

    beforeEach(module((Module module) {
      module.install(new PaginationModule());
      return (Injector _injector) {
        injector = _injector;
        compile = injector.get(Compiler);
        rootScope = injector.get(Scope);
        cache = injector.get(TemplateCache);
        loadTemplatesToCache();
        setTotalItems(47);
        setCurrentPage(3);
        compileElement('<pagination total-items="total" page="currentPage"></pagination>');
      };
    }));


    int getPaginationBarSize() {
      return shadowElement.querySelectorAll('li').length;
    }

    dom.Element getPaginationEl(index) {
      return shadowElement.querySelectorAll('li').elementAt(index);
    }

    String getPaginationElText(index) {
      return getPaginationEl(index).firstChild.text;
    }

    void clickPaginationEl(index) {
      getPaginationEl(index).querySelector('a').click();
    }

    void updateCurrentPage(value) {
      rootScope.apply(() => setCurrentPage(value));
    }

    it('has a "pagination" css class', async(inject(() {
      expect(shadowElement).toHaveClass('pagination');
    })));

    it('contains num-pages + 2 li elements', async(inject(() {
      expect(getPaginationBarSize()).toBe(7);
      expect(getPaginationElText(0)).toEqual('Previous');
      expect(getPaginationElText(6)).toEqual('Next');
    })));

    it('has the number of the page as text in each page item', async(inject(() {
      for (var i = 1; i <= 5; i++) {
        expect(getPaginationElText(i)).toEqual('$i');
      }
    })));

    it('sets the current page to be active', async(inject(() {
      expect(getPaginationEl(getCurrentPage())).toHaveClass('active');
    })));

    it('disables the "previous" link if current page is 1', async(inject(() {
      updateCurrentPage(1);
      expect(getPaginationEl(0)).toHaveClass('disabled');
    })));

    it('disables the "next" link if current page is last', async(inject(() {
      updateCurrentPage(5);
      expect(getPaginationEl(6)).toHaveClass('disabled');
    })));

    it('changes currentPage if a page link is clicked', async(inject(() {
      clickPaginationEl(2);
      expect(getCurrentPage()).toBe(2);
    })));

    it('changes currentPage if the "previous" link is clicked', async(inject(() {
      clickPaginationEl(0);
      expect(getCurrentPage()).toBe(2);
    })));

    it('changes currentPage if the "next" link is clicked', async(inject(() {
      clickPaginationEl(6);
      expect(getCurrentPage()).toBe(4);
    })));

    it('does not change the current page on "previous" click if already at first page', async(inject(() {
      updateCurrentPage(1);
      clickPaginationEl(0);
      expect(getCurrentPage()).toBe(1);
    })));

    it('does not change the current page on "next" click if already at last page', async(inject(() {
      updateCurrentPage(5);
      clickPaginationEl(6);
      expect(getCurrentPage()).toBe(5);
    })));

    it('changes the number of pages when `total-items` changes', async(inject(() {
      rootScope.apply(() => setTotalItems(78)); // 8 pages

      expect(getPaginationBarSize()).toBe(10);
      expect(getPaginationElText(0)).toEqual('Previous');
      expect(getPaginationElText(9)).toEqual('Next');
    })));

    it('does not "break" when `total-items` is undefined', async(inject(() {
      rootScope.apply(() => setTotalItems(null));

      expect(getPaginationBarSize()).toBe(3); // Previous, 1, Next
      expect(getPaginationEl(0)).toHaveClass('disabled');
      expect(getPaginationEl(1)).toHaveClass('active');
      expect(getPaginationEl(2)).toHaveClass('disabled');
    })));

    it('does not "break" when `total-items` is negative', async(inject(() {
      rootScope.apply(() => setTotalItems(-1));

      expect(getPaginationBarSize()).toBe(3); // Previous, 1, Next
      expect(getPaginationEl(0)).toHaveClass('disabled');
      expect(getPaginationEl(1)).toHaveClass('active');
      expect(getPaginationEl(2)).toHaveClass('disabled');
    })));

    it('does not change the current page when `total-items` changes but is valid', async(inject(() {
      rootScope.apply(() {
        setCurrentPage(1);
        setTotalItems(18);
      }); // 2 pages

      expect(getCurrentPage()).toBe(1);
    })));

    describe('`items-per-page`', () {
      beforeEach(module((Module module) {
        return (Injector injector) {
          setItemsPerPage(5);
          rootScope.context['selectedPage'] = 3;
          compileElement('<pagination total-items="total" items-per-page="perPage" page="selectedPage"></pagination>');
        };
      }));

      it('changes the number of pages', async(inject(() {
        expect(getPaginationBarSize()).toBe(12);
        expect(getPaginationElText(0)).toEqual('Previous');
        expect(getPaginationElText(11)).toEqual('Next');
      })));

      it('changes the number of pages when changes', async(inject(() {
        rootScope.apply(() => setItemsPerPage(20));

        expect(getPaginationBarSize()).toBe(5);
        expect(getPaginationElText(0)).toEqual('Previous');
        expect(getPaginationElText(4)).toEqual('Next');
      })));

      it('selects the last page when current page is too big', async(inject(() {
        rootScope.apply(() => setItemsPerPage(30));

        expect(rootScope.context['selectedPage']).toBe(2);
        expect(getPaginationBarSize()).toBe(4);
        expect(getPaginationElText(0)).toEqual('Previous');
        expect(getPaginationElText(3)).toEqual('Next');
      })));

      it('displays a single page when it is negative', async(inject(() {
        rootScope.apply(() => setItemsPerPage(-1));

        expect(getPaginationBarSize()).toBe(3);
        expect(getPaginationElText(0)).toEqual('Previous');
        expect(getPaginationElText(1)).toEqual('1');
        expect(getPaginationElText(2)).toEqual('Next');
      })));
    });

    describe('executes  `on-select-page` expression', () {
      beforeEach(module((Module module){
        return (Injector injector) {
          rootScope.context['selectPageHandler'] = jasmine.createSpy('selectPageHandler');
          compileElement('<pagination total-items="total" page="currentPage" on-select-page="selectPageHandler()"></pagination>');
        };
      }));

      it('when an element is clicked', async(inject(() {
        clickPaginationEl(2);
        expect(rootScope.context['selectPageHandler']).toHaveBeenCalled();
      })));
    });

    describe('when `page` is not a number', (){
      it('handles numerical string', async(inject((){
        updateCurrentPage('2');
        expect(getPaginationEl(2)).toHaveClass('active');

        updateCurrentPage('04');
        expect(getPaginationEl(4)).toHaveClass('active');
      })));

      it('defaults to 1 if non-numeric', async(inject((){
        updateCurrentPage('pizza');
        expect(getPaginationEl(1)).toHaveClass('active');
      })));
    });

    describe('with `max-size` option', (){
      beforeEach(module((Module module){
        return (Injector injector){
          setTotalItems(98); //10 pages
          setCurrentPage(3);
          rootScope.context['maxSize'] = 5;
          compileElement('<pagination total-items="total" page="currentPage" max-size="maxSize"></pagination>');
        };
      }));

      it('contains maxsize + 2 li elements', async(inject((){
        expect(getPaginationBarSize()).toBe(7);
        expect(getPaginationElText(0)).toEqual('Previous');
        expect(getPaginationElText(6)).toEqual('Next');
      })));

      it('shows the page number even if it can\'t be shown in the middle', async(inject((){
        updateCurrentPage(1);
        expect(getPaginationEl(1)).toHaveClass('active');

        updateCurrentPage(10);
        expect(getPaginationEl(5)).toHaveClass('active');
      })));

      it('shows the page number in middle after the next link is clicked', async(inject((){
        updateCurrentPage(6);
        clickPaginationEl(6);

        expect(getCurrentPage()).toBe(7);
        expect(getPaginationEl(3)).toHaveClass('active');
        expect(getPaginationElText(3)).toEqual(getCurrentPage().toString());
      })));

      it('shows the page number in middle after the prev link is clicked', async(inject((){
        updateCurrentPage(7);
        clickPaginationEl(0);

        expect(getCurrentPage()).toBe(6);
        expect(getPaginationEl(3)).toHaveClass('active');
        expect(getPaginationElText(3)).toEqual(getCurrentPage().toString());
      })));

      it('changes pagination bar size when max-size value changed', async(inject((){
        rootScope.apply(() => rootScope.context['maxSize'] = 7);
        expect(getPaginationBarSize()).toBe(9);
      })));

      it('sets the pagination bar size to num-pages, if max-size is greater than num-pages', async(inject((){
        rootScope.apply(() => rootScope.context['maxSize'] = 15);
        expect(getPaginationBarSize()).toBe(12);
      })));

      it('should not change value of max-size expression, if max-size is greater than num-pages', async(inject((){
        rootScope.apply(() => rootScope.context['maxSize'] = 15);
        expect(rootScope.context['maxSize']).toBe(15);
      })));

      it('should not display page numbers, if max-size is zero', async(inject((){
        rootScope.apply(() => rootScope.context['maxSize'] = 0);
        expect(getPaginationBarSize()).toBe(2);
        expect(getPaginationElText(0)).toEqual('Previous');
        expect(getPaginationElText(1)).toEqual('Next');
      })));
    });

    describe('with `max-size` option & no `rotate`', (){
      beforeEach(module((Module module){
        return (Injector injector){
          setTotalItems(115); //12 pages
          setCurrentPage(7);
          rootScope.context['maxSize'] = 5;
          rootScope.context['rotate'] = false;
          compileElement('<pagination total-items="total" page="currentPage" max-size="maxSize" rotate="rotate"></pagination>');
        };
      }));

      it('contains maxsize + 4 elements', async(inject((){
        expect(getPaginationBarSize()).toBe(9);
        expect(getPaginationElText(0)).toEqual('Previous');
        expect(getPaginationElText(1)).toEqual('...');
        expect(getPaginationElText(2)).toEqual('6');
        expect(getPaginationElText(6)).toEqual('10');
        expect(getPaginationElText(7)).toEqual('...');
        expect(getPaginationElText(8)).toEqual('Next');
      })));

      it('shows only the next ellipsis element on first page set', async(inject((){
        updateCurrentPage(3);
        expect(getPaginationElText(1)).toEqual('1');
        expect(getPaginationElText(5)).toEqual('5');
        expect(getPaginationElText(6)).toEqual('...');
      })));

      it('shows only the previous ellipsis element on last page set', async(inject((){
        updateCurrentPage(12);
        expect(getPaginationElText(1)).toEqual('...');
        expect(getPaginationElText(2)).toEqual('11');
        expect(getPaginationElText(3)).toEqual('12');
      })));

      it('moves to the previous set when first ellipsis is clicked', async(inject((){
        expect(getPaginationElText(1)).toEqual('...');

        clickPaginationEl(1);

        expect(getCurrentPage()).toEqual(5);
        expect(getPaginationEl(5)).toHaveClass('active');
      })));

      it('moves to the next set when last ellipsis is clicked', async(inject((){
        expect(getPaginationElText(7)).toEqual('...');

        clickPaginationEl(7);

        expect(getCurrentPage()).toEqual(11);
        expect(getPaginationEl(2)).toHaveClass('active');
      })));

      it('should not display page numbers, if max-size is zero', async(inject((){
        rootScope.apply(() => rootScope.context['maxSize'] = 0);
        expect(getPaginationBarSize()).toBe(2);
        expect(getPaginationElText(0)).toEqual('Previous');
        expect(getPaginationElText(1)).toEqual('Next');
      })));
    });

    describe('pagination directive with `boundary-links`', (){
      beforeEach(module((Module module){
        return (Injector injector){
          compileElement('<pagination boundary-links="true" total-items="total" page="currentPage"></pagination>');
        };
      }));

      it('contains num-pages + 4 li elements', async(inject((){
        expect(getPaginationBarSize()).toBe(9);
        expect(getPaginationElText(0)).toEqual('First');
        expect(getPaginationElText(1)).toEqual('Previous');
        expect(getPaginationElText(7)).toEqual('Next');
        expect(getPaginationElText(8)).toEqual('Last');
      })));

      it('has first and last li elements visible', async(inject((){
        expect(getPaginationEl(0).style.display).not.toEqual('none');
        expect(getPaginationEl(8).style.display).not.toEqual('none');
      })));

      it('disables the "first" & "previous" link if current page is 1', async(inject((){
        updateCurrentPage(1);

        expect(getPaginationEl(0)).toHaveClass('disabled');
        expect(getPaginationEl(1)).toHaveClass('disabled');
      })));

      it('disables the "last" & "next" link if current page is num-pages', async(inject((){
        updateCurrentPage(5);

        expect(getPaginationEl(7)).toHaveClass('disabled');
        expect(getPaginationEl(8)).toHaveClass('disabled');
      })));

      it('changes currentPage if the "first" link is clicked', async(inject((){
        clickPaginationEl(0);
        expect(getCurrentPage()).toBe(1);
      })));

      it('changes currentPage if the "last" link is clicked', async(inject((){
        clickPaginationEl(8);
        expect(getCurrentPage()).toBe(5);
      })));

      it('does not change the current page on "first" click if already at first page', async(inject((){
        updateCurrentPage(1);
        clickPaginationEl(0);
        expect(getCurrentPage()).toBe(1);
      })));

      it('does not change the current page on "last" click if already at last page', async(inject((){
        updateCurrentPage(5);
        clickPaginationEl(8);
        expect(getCurrentPage()).toBe(5);
      })));

      it('changes "first" & "last" text from attributes', async(inject((){
        compileElement('<pagination boundary-links="true" first-text="<<<" last-text=">>>" total-items="total" page="currentPage"></pagination>');

        expect(getPaginationElText(0)).toEqual('<<<');
        expect(getPaginationElText(8)).toEqual('>>>');
      })));

      it('changes "previous" & "next" text from attributes', async(inject((){
        compileElement('<pagination boundary-links="true" previous-text="<<" next-text=">>" total-items="total" page="currentPage"></pagination>');

        expect(getPaginationElText(1)).toEqual('<<');
        expect(getPaginationElText(7)).toEqual('>>');
      })));

      it('changes "first" & "last" text from interpolated attributes', async(inject((){
        rootScope.context['myFirstText']= '<<<';
        rootScope.context['myNextText']= '>>>';
        compileElement('<pagination boundary-links="true" first-text="{{myFirstText}}" last-text="{{myNextText}}" total-items="total" page="currentPage"></pagination>');

        expect(getPaginationElText(0)).toEqual('<<<');
        expect(getPaginationElText(8)).toEqual('>>>');
      })));

      it('changes "previous" & "next" text from interpolated attributes', async(inject((){
        rootScope.context['previousText']= '<<';
        rootScope.context['nextText']= '>>';
        compileElement('<pagination boundary-links="true" previous-text="{{previousText}}" next-text="{{nextText}}" total-items="total" page="currentPage"></pagination>');

        expect(getPaginationElText(1)).toEqual('<<');
        expect(getPaginationElText(7)).toEqual('>>');
      })));
    });

    describe('pagination directive with just number links', (){
      beforeEach(module((Module module){
        return (Injector injector){
          compileElement('<pagination direction-links="false" total-items="total" page="currentPage"></pagination>');
        };
      }));

      it('contains num-pages li elements', async(inject((){
        expect(getPaginationBarSize()).toBe(5);
        expect(getPaginationElText(0)).toEqual('1');
        expect(getPaginationElText(4)).toEqual('5');
      })));

      it('has the number of the page as text in each page item', async(inject((){
        for(var i = 0; i < 5; i++) {
          expect(getPaginationElText(i)).toEqual((i+1).toString());
        }
      })));

      it('sets the current page to be active', async(inject((){
        expect(getPaginationEl(2)).toHaveClass('active');
      })));

      it('does not disable the "1" link if current page is 1', async(inject((){
        updateCurrentPage(1);

        expect(getPaginationEl(0)).not.toHaveClass('disabled');
        expect(getPaginationEl(0)).toHaveClass('active');
      })));

      it('does not disable the "last" link if current page is last page', async(inject((){
        updateCurrentPage(5);

        expect(getPaginationEl(4)).not.toHaveClass('disabled');
        expect(getPaginationEl(4)).toHaveClass('active');
      })));

      it('changes currentPage if a page link is clicked', async(inject((){
        clickPaginationEl(1);

        expect(getCurrentPage()).toBe(2);
      })));

      it('changes the number of items when total items changes', async(inject((){
        rootScope.apply(()=>setTotalItems(73)); // 8 pages

        expect(getPaginationBarSize()).toBe(8);
        expect(getPaginationElText(0)).toEqual('1');
        expect(getPaginationElText(7)).toEqual('8');
      })));
    });

    describe('with just boundary & number links', (){
      beforeEach(module((Module module){
        return (Injector injector){
          rootScope.context['directions'] = false;
          compileElement('<pagination boundary-links="true" direction-links="directions" total-items="total" page="currentPage"></pagination>');
        };
      }));

      it('contains number of pages + 2 li elements', async(inject((){
        expect(getPaginationBarSize()).toBe(7);
        expect(getPaginationElText(0)).toEqual('First');
        expect(getPaginationElText(1)).toEqual('1');
        expect(getPaginationElText(5)).toEqual('5');
        expect(getPaginationElText(6)).toEqual('Last');
      })));

      it('disables the "first" & activates "1" link if current page is 1', async(inject((){
        updateCurrentPage(1);

        expect(getPaginationEl(0)).toHaveClass('disabled');
        expect(getPaginationEl(1)).not.toHaveClass('disabled');
        expect(getPaginationEl(1)).toHaveClass('active');
      })));

      it('disables the "last" & "next" link if current page is num-pages', async(inject((){
        updateCurrentPage(5);

        expect(getPaginationEl(5)).toHaveClass('active');
        expect(getPaginationEl(5)).not.toHaveClass('disabled');
        expect(getPaginationEl(6)).toHaveClass('disabled');
      })));
    });

    describe('`num-pages`', (){
      beforeEach(module((Module module){
        return (Injector injector){
          rootScope.context['numpg'] = null;
          compileElement('<pagination total-items="total" page="currentPage" num-pages="numpg"></pagination>');
        };
      }));

      it('disables the "last" & "next" link if current page is num-pages', async(inject((){
        expect(rootScope.context['numpg']).toBe(5);
      })));

      it('changes when total number of pages change', async(inject((){
        rootScope.apply(()=>setTotalItems(73)); // 8 pages
        expect(rootScope.context['numpg']).toBe(8);
      })));

      it('shows minimun one page if total items are not defined and does not break binding', async(inject((){
        rootScope.apply(()=>setTotalItems(null));
        expect(rootScope.context['numpg']).toBe(1);

        rootScope.apply(()=>setTotalItems(73)); // 8 pages
        expect(rootScope.context['numpg']).toBe(8);
      })));
    });

    describe('setting `paginationConfig`', (){

      it('shows minimun one page if total items are not defined and does not break binding', async(inject((PaginationConfig paginationConfig){
        paginationConfig.boundaryLinks = true;
        paginationConfig.directionLinks = true;
        paginationConfig.firstText = 'FI';
        paginationConfig.previousText = 'PR';
        paginationConfig.nextText = 'NE';
        paginationConfig.lastText = 'LA';
        compileElement('<pagination total-items="total" page="currentPage"></pagination>');
        expect(getPaginationElText(0)).toEqual('FI');
        expect(getPaginationElText(1)).toEqual('PR');
        expect(getPaginationElText(7)).toEqual('NE');
        expect(getPaginationElText(8)).toEqual('LA');
      })));

      it('contains number of pages + 2 li elements', async(inject((PaginationConfig paginationConfig){
        paginationConfig.itemsPerPage = 5;
        compileElement('<pagination total-items="total" page="currentPage"></pagination>');
        expect(getPaginationBarSize()).toBe(12);
      })));

      it('should take maxSize defaults into account', async(inject((PaginationConfig paginationConfig){
        paginationConfig.maxSize = 2;
        compileElement('<pagination total-items="total" page="currentPage"></pagination>');
        expect(getPaginationBarSize()).toBe(4);
      })));
    });
  });
}