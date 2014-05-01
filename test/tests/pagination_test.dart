// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void paginationTests() {

  describe('Testing pager:', () {

    Scope rootScope;
    Injector injector;
    Compiler compile;
    TemplateCache cache;
    dom.Element shadowElement;
    dom.Element element;

    beforeEach(setUpInjector);

    dom.Element compileElement(String htmlText) {
      List<dom.Node> elements = $(htmlText);
      compile(elements, injector.get(DirectiveMap))(injector, elements);
      rootScope.rootScope.apply();
      microLeap();
      return elements[0];
    }

    void loadTemplatesToCache() {
      addToTemplateCache(cache, 'packages/angular_ui/pagination/pager.html');
    }

    beforeEach(module((Module module) {
      module.install(new PaginationModule());
      return (Injector _injector) {
        injector = _injector;
        compile = injector.get(Compiler);
        rootScope = injector.get(Scope);
        cache = injector.get(TemplateCache);
        loadTemplatesToCache();
        rootScope.context['total'] = 47;
        rootScope.context['currentPage'] = 3;
        element = compileElement('<pager total-items="total" ng-model="currentPage"></pager>');
        microLeap();
        rootScope.rootScope.apply();
        shadowElement = getFirstUList(element.shadowRoot);
      };
    }));

    afterEach(tearDownInjector);

    int getPaginationBarSize() {
      return shadowElement.querySelectorAll('li').length;
    }

    dom.Element getPaginationEl(index) {
      return shadowElement.querySelectorAll('li').elementAt(index);
    }

    void clickPaginationEl(index) {
      getPaginationEl(index).querySelector('a').click();
    }

    void updateCurrentPage(value) {
      rootScope.context['currentPage'] = value;
      rootScope.rootScope.apply();
    }


    it('has a "pager" css class', async(inject(() {
      expect(shadowElement).toHaveClass('pager');
    })));

    it('contains 2 li elements', async(inject(() {
      expect(getPaginationBarSize()).toBe(2);
      expect(getPaginationEl(0).firstChild.text).toEqual('« Previous');
      expect(getPaginationEl(1).firstChild.text).toEqual('Next »');
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
      expect(rootScope.context['currentPage']).toBe(2);
    })));

    it('changes currentPage if the "next" link is clicked', async(inject(() {
      clickPaginationEl(1);
      expect(rootScope.context['currentPage']).toBe(4);
    })));

    it('does not change the current page on "previous" click if already at first page', async(inject(() {
      updateCurrentPage(1);
      clickPaginationEl(0);
      expect(rootScope.context['currentPage']).toBe(1);
    })));

    it('does not change the current page on "next" click if already at last page', async(inject(() {
      updateCurrentPage(5);
      clickPaginationEl(1);
      expect(rootScope.context['currentPage']).toBe(5);
    })));

    it('executes the `ng-change` expression when an element is clicked', async(inject(() {
      rootScope.context['selectPageHandler'] = jasmine.createSpy('selectPageHandler');
      element = compileElement('<pager total-items="total" ng-model="currentPage" on-select-page="selectPageHandler()"></pager>');
      shadowElement = getFirstUList(element.shadowRoot);
      clickPaginationEl(1);
      expect(rootScope.context['selectPageHandler']).toHaveBeenCalled();
    })));

    it('does not changes the number of pages when `total-items` changes', async(inject(() {
      rootScope.context['total'] = 73; // 8 pages
      rootScope.rootScope.apply();

      expect(getPaginationBarSize()).toBe(2);
      expect(getPaginationEl(0).firstChild.text).toEqual('« Previous');
      expect(getPaginationEl(1).firstChild.text).toEqual('Next »');
    })));

    describe('`items-per-page`', () {
      beforeEach(module((Module module) {
        return (Injector _injector) {
          rootScope.context['perpage'] = 5;
          element = compileElement('<pager total-items="total" items-per-page="perpage" ng-model="currentPage"></pager>');
          microLeap();
          rootScope.rootScope.apply();
          shadowElement = getFirstUList(element.shadowRoot);
        };
      }));

      it('does not change the number of pages', async(inject(() {
        expect(getPaginationBarSize()).toBe(2);
        expect(getPaginationEl(0).firstChild.text).toEqual('« Previous');
        expect(getPaginationEl(1).firstChild.text).toEqual('Next »');
      })));

      it('selects the last page when it is too big', async(inject(() {
        rootScope.context['perpage'] = 30;
        rootScope.rootScope.apply();

        expect(rootScope.context['currentPage']).toBe(2);
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
          element = compileElement('<pager total-items="total" num-pages="numpg" ng-model="currentPage"></pager>');
          microLeap();
          rootScope.rootScope.apply();
          shadowElement = getFirstUList(element.shadowRoot);
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
        expect(getPaginationEl(0).firstChild.text).toEqual('PR');
        expect(getPaginationEl(1).firstChild.text).toEqual('NE');
      })));

      it('should not align previous & next page link', async(inject(() {
        expect(getPaginationEl(0)).not.toHaveClass('previous');
        expect(getPaginationEl(1)).not.toHaveClass('next');
      })));
    });

    describe('override configuration from attributes', () {
      beforeEach(module((Module module){
        return (Injector injector) {
          element = compileElement('<pager align="false" previous-text="<" next-text=">" total-items="total" ng-model="currentPage"></pager>');
          microLeap();
          rootScope.rootScope.apply();
          shadowElement = getFirstUList(element.shadowRoot);
        };
      }));

      it('contains 2 li elements', async(inject(() {
        expect(getPaginationBarSize()).toBe(2);
      })));

      it('should change paging text from attributes', async(inject(() {
        expect(getPaginationEl(0).firstChild.text).toEqual('<');
        expect(getPaginationEl(1).firstChild.text).toEqual('>');
      })));

      it('should not align previous & next page link', async(inject(() {
        expect(getPaginationEl(0)).not.toHaveClass('previous');
        expect(getPaginationEl(1)).not.toHaveClass('next');
      })));

      it('changes "previous" & "next" text from interpolated attributes', async(inject(() {
        rootScope.context['previousText'] = '<<';
        rootScope.context['nextText'] = '>>';
        element = compileElement('<pager align="false" previous-text="{{previousText}}" next-text="{{nextText}}" total-items="total" ng-model="currentPage"></pager>');
        microLeap();
        rootScope.rootScope.apply();
        shadowElement = getFirstUList(element.shadowRoot);

        expect(getPaginationEl(0).firstChild.text).toEqual('<<');
        expect(getPaginationEl(1).firstChild.text).toEqual('>>');
      })));
    });
  });

  describe('Testing pagination:', () {

    Scope rootScope;
    Injector injector;
    Compiler compile;
    TemplateCache cache;
    dom.Element shadowElement;
    dom.Element element;

    beforeEach(setUpInjector);

    dom.Element compileElement(String htmlText) {
      List<dom.Node> elements = $(htmlText);
      compile(elements, injector.get(DirectiveMap))(injector, elements);
      rootScope.rootScope.apply();
      microLeap();
      return elements[0];
    }

    void loadTemplatesToCache() {
      addToTemplateCache(cache, 'packages/angular_ui/pagination/pagination.html');
    }

    beforeEach(module((Module module) {
      module.install(new PaginationModule());
      return (Injector _injector) {
        injector = _injector;
        compile = injector.get(Compiler);
        rootScope = injector.get(Scope);
        cache = injector.get(TemplateCache);
        loadTemplatesToCache();
        rootScope.context['total'] = 47;
        rootScope.context['currentPage'] = 3;
        element = compileElement('<pagination total-items="total" ng-model="currentPage"></pagination>');
        microLeap();
        rootScope.rootScope.apply();
        shadowElement = getFirstUList(element.shadowRoot);
      };
    }));

    afterEach(tearDownInjector);

    int getPaginationBarSize() {
      return shadowElement.querySelectorAll('li').length;
    }

    dom.Element getPaginationEl(index) {
      return shadowElement.querySelectorAll('li').elementAt(index);
    }

    void clickPaginationEl(index) {
      getPaginationEl(index).querySelector('a').click();
    }

    void updateCurrentPage(value) {
      rootScope.context['currentPage'] = value;
      rootScope.rootScope.apply();
    }

    it('has a "pagination" css class', async(inject(() {
      expect(shadowElement).toHaveClass('pagination');
    })));

    it('contains num-pages + 2 li elements', async(inject(() {
      expect(getPaginationBarSize()).toBe(7);
      expect(getPaginationEl(0).firstChild.text).toEqual('Previous');
      expect(getPaginationEl(6).firstChild.text).toEqual('Next');
    })));

    it('has the number of the page as text in each page item', async(inject(() {
      for (var i = 1; i <= 5; i++) {
        expect(getPaginationEl(i).firstChild.text).toEqual('$i');
      }
    })));

    it('sets the current page to be active', async(inject(() {
      expect(getPaginationEl(rootScope.context['currentPage'])).toHaveClass('active');
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
      expect(rootScope.context['currentPage']).toBe(2);
    })));

    it('changes currentPage if the "previous" link is clicked', async(inject(() {
      clickPaginationEl(0);
      expect(rootScope.context['currentPage']).toBe(2);
    })));

    it('changes currentPage if the "next" link is clicked', async(inject(() {
      clickPaginationEl(6);
      expect(rootScope.context['currentPage']).toBe(4);
    })));

    it('does not change the current page on "previous" click if already at first page', async(inject(() {
      updateCurrentPage(1);
      clickPaginationEl(0);
      expect(rootScope.context['currentPage']).toBe(1);
    })));

    it('does not change the current page on "next" click if already at last page', async(inject(() {
      updateCurrentPage(5);
      clickPaginationEl(6);
      expect(rootScope.context['currentPage']).toBe(5);
    })));

    it('changes the number of pages when `total-items` changes', async(inject(() {
      rootScope.context['total'] = 78; // 8 pages
      rootScope.rootScope.apply();

      expect(getPaginationBarSize()).toBe(10);
      expect(getPaginationEl(0).firstChild.text).toEqual('Previous');
      expect(getPaginationEl(9).firstChild.text).toEqual('Next');
    })));

    it('does not "break" when `total-items` is undefined', async(inject(() {
      rootScope.context['total'] = null;
      rootScope.rootScope.apply();

      expect(getPaginationBarSize()).toBe(3); // Previous, 1, Next
      expect(getPaginationEl(0)).toHaveClass('disabled');
      expect(getPaginationEl(1)).toHaveClass('active');
      expect(getPaginationEl(2)).toHaveClass('disabled');
    })));

    it('does not "break" when `total-items` is negative', async(inject(() {
      rootScope.context['total'] = -1;
      rootScope.rootScope.apply();

      expect(getPaginationBarSize()).toBe(3); // Previous, 1, Next
      expect(getPaginationEl(0)).toHaveClass('disabled');
      expect(getPaginationEl(1)).toHaveClass('active');
      expect(getPaginationEl(2)).toHaveClass('disabled');
    })));

    it('does not change the current page when `total-items` changes but is valid', async(inject(() {
      rootScope.context['currentPage'] = 1;
      rootScope.rootScope.apply();
      rootScope.context['total'] = 18; // 2 pages
      rootScope.rootScope.apply();

      expect(rootScope.context['currentPage']).toBe(1);
    })));

    describe('`items-per-page`', () {
      beforeEach(module((Module module){
        return (Injector injector) {
          rootScope.context['perpage'] = 5;
          element = compileElement('<pagination total-items="total" items-per-page="perpage" ng-model="currentPage"></pagination>');
          microLeap();
          rootScope.rootScope.apply();
          shadowElement = getFirstUList(element.shadowRoot);
        };
      }));

      it('changes the number of pages', async(inject(() {
        expect(getPaginationBarSize()).toBe(12);
        expect(getPaginationEl(0).firstChild.text).toEqual('Previous');
        expect(getPaginationEl(11).firstChild.text).toEqual('Next');
      })));

      it('changes the number of pages when changes', async(inject(() {
        rootScope.context['perpage'] = 20;
        rootScope.rootScope.apply();

        expect(getPaginationBarSize()).toBe(5);
        expect(getPaginationEl(0).firstChild.text).toEqual('Previous');
        expect(getPaginationEl(4).firstChild.text).toEqual('Next');
      })));

      it('selects the last page when current page is too big', async(inject(() {
        rootScope.context['perpage'] = 30;
        rootScope.rootScope.apply();

        expect(rootScope.context['currentPage']).toBe(2);
        expect(getPaginationBarSize()).toBe(4);
        expect(getPaginationEl(0).firstChild.text).toEqual('Previous');
        expect(getPaginationEl(3).firstChild.text).toEqual('Next');
      })));

      it('displays a single page when it is negative', async(inject(() {
        rootScope.context['perpage'] = -1;
        rootScope.rootScope.apply();

        expect(getPaginationBarSize()).toBe(3);
        expect(getPaginationEl(0).firstChild.text).toEqual('Previous');
        expect(getPaginationEl(1).firstChild.text).toEqual('1');
        expect(getPaginationEl(2).firstChild.text).toEqual('Next');
      })));
    });
  });

}