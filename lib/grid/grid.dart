// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please seegriddropdown_toggle;
library angular.ui.grid;

import 'dart:html' as dom;
import "package:angular/angular.dart";
import "package:angular/core_dom/module_internal.dart";
import "package:angular_ui/utils/utils.dart";

part 'header.dart';
part 'body.dart'; 
part 'footer.dart';
part 'parser.dart';
part 'updater.dart';
part 'renderer.dart'; 
part 'fields.dart';

/**
 * Grid Module.
 */
class GridModule extends Module {
  GridModule() {
    bind(Grid);
  }
}

class GridColumn {
  String fieldName;
  String displayName;
  String displayAlign = 'left';
  String displayFormat;
  bool enableSorting = true;
  bool enableFiltering = true;
  String cellWidth;
  String cellHeight;
}

@Decorator(selector:"table[sm-ng-grid]")
class Grid {

  @NgTwoWay('items')
  set items(List value) {
    _scope.context['items'] = value == null ? [] : value;
  }
  List get items => _scope.context['items'];
  
  @NgTwoWay('selected-items')
  set selectedItems(List value) {
    _scope.context['selectedItems'] = value == null ? [] : value;
  }
  List get selectedItems => _scope.context['selectedItems'];
    
  @NgTwoWay('search-by')
  set searchBy(String value) {
    _scope.context['searchBy'] = value;
  }
  String get searchBy => _scope.context['searchBy'];
  
  @NgTwoWay('order-by')
  set orderBy(String value) {
    _scope.context['orderBy'] = value;
  }
  String get orderBy => _scope.context['orderBy'];
  
  @NgTwoWay('order-by-reverse')
  set orderByReverse(bool value) {
    _scope.context['orderByReverse'] = value;
  }
  bool get orderByReverse => _scope.context['orderByReverse'];
   
  @NgTwoWay('enable-filtering')
  set enableFiltering(bool value) {
    _scope.context['enableFiltering'] = value;
  }
  bool get enableFiltering => _scope.context['enableFiltering'];
    
  @NgTwoWay('enable-sorting')
  set enableSorting(bool value) {
    _scope.context['enableSorting'] = value;
  }
  bool get enableSorting => _scope.context['enableSorting'];

  @NgTwoWay('enable-selections')
  set enableSelections(bool value) {
    _scope.context['enableSelections'] = value;
  }
  bool get enableSelections => _scope.context['enableSelections'];
    
  @NgTwoWay('enable-multi-row-selections')
  set enableMultiRowSelections(bool value) {
    _scope.context['enableMultiRowSelections'] = value;
  }
  bool get enableMultiRowSelections => _scope.context['enableMultiRowSelections'];
    
  @NgTwoWay('columns')
  set columns(List<GridColumn> value) {
    _scope.context['columns'] = value == null ? [] : value;
  }
  List<GridColumn> get columns => _scope.context['columns'];

  @NgTwoWay('items-on-page')
  set itemsOnPage(int value) {
    _scope.context['itemsOnPage'] = value == null ? 0 : value;
  }
  int get itemsOnPage => _scope.context['itemsOnPage'];

  @NgTwoWay('current-page')
  set currentPage(int value) {
    _scope.context['currentPage'] = value == null ? 0 : value;
  }
  int get currentPage => _scope.context['currentPage'];
  
  @NgTwoWay('total-items')
  set totalItems(int value) { /* Read-only */}
  int get totalItems => _scope.context['totalItems'];

  dom.TableElement _grid;
  
  Scope _scope;
  NodeAttrs _attrs;

  Parser _parser;
  Updater _updater;
  Renderer _renderer;
  
  Grid(dom.Element gridEl, Scope scope, this._attrs, FieldGetterFactory fieldGetterFactory) {
    _grid = gridEl as dom.TableElement;
    _scope = scope.createChild(new PrototypeMap(scope.context));
    // Update predefined classes
    _grid.classes.add('sm-ng-grid table table-hover');
    
    // Scope variables initialization
    _scope.context['itemsOnPage'] = 5;
    _scope.context['totalItemsCount'] = 0;
    _scope.context['items'] = [];
    _scope.context['startItemIndex'] = 0;
    _scope.context['currentPage'] = 0;
    _scope.context['endItemIndex'] = 0;
    _scope.context['pageCanGoBack'] = false;
    _scope.context['pageCanGoForward'] = false;
    _scope.context['searchBy'] = null;
    _scope.context['filterByFields'] = {};
    _scope.context['orderBy'] = null;
    _scope.context['orderByReverse'] = false;
    _scope.context['renderingItems'] = [];
    _scope.context['columns'] = [];
    _scope.context['selectedItems'] = [];
    _scope.context['enableSelections'] = true; 
    _scope.context['enableMultiRowSelections'] = true;
    _scope.context['enableSorting'] = true;
    _scope.context['enableFiltering'] = true;
    _scope.context['totalItems'] = 0;
    
    // Functions
    _scope.context['toggleSorting'] = toggleSorting;
    _scope.context['setFilter'] = setFilter;
    _scope.context['setSearch'] = setSearch;
    _scope.context['navigatePrevPage'] = navigatePrevPage;
    _scope.context['navigateNextPage'] = navigateNextPage;
    
    // Watchers
    _scope.watch('[currentPage, orderBy, orderByReverse]', (value, old) {
      _updater.prepareToRender();
      _renderer.render();
    }, collection: true);
    _scope.watch('[searchBy, items.length, totalItems, itemsOnPage]', (value, old) {
      _updater.resetPager();
      _updater.prepareToRender();
      _renderer.render();
    }, collection: true);
    //
    _scope.watch('filterByFields', (value, old) {
      _updater.resetPager();
      _updater.prepareToRender();
      _renderer.render();
    }, collection: true);
    //
    _scope.watch('items', (value, old) {
      _updater.updateTotalItems(_scope.context['items']);
      if (_parser.defineColumns()) {
        // Columns definition was found first time - apply changes 
        _updater.update();
      }
      _updater.prepareToRender();
      _renderer.render();
    }, collection:true);
    
    // Helpers
    Fields fields = new Fields(fieldGetterFactory);
    _parser  = new Parser(_scope);
    _updater = new Updater(_scope, _grid, fields);
    _renderer = new Renderer(_scope, _grid, fields);
    
    // Initialize grid
    _parser.parse();
    _updater.update();
    _updater.updatePager(_scope.context['totalItems']);
    _renderer.render();
  }
  
  /**
   * Toggle sorting on [property].
   * That method doesn't check is [property] exists in grid.
   * Reneding triggers automatically.
   */
  toggleSorting(String property) {
    if (_scope.context['orderBy'] != property) {
      // the column has changed
      _scope.context['orderBy'] = property;
    } else {
      // the sort direction has changed
      _scope.context['orderByReverse'] = !_scope.context['orderByReverse'];
    }
  }
  
  /**
   * Set [filter] value for [property].
   * That method doesn't check is [property] exists in grid.
   * Reneding triggers automatically.
   */
  setFilter(String property, String filter) {
    if (filter == null) {
      if (_scope.context['filterByFields'].containsKey(property)) {
        _scope.context['filterByFields'].remove(property);
      }
    } else {
      _scope.context['filterByFields'][property] = filter;
    }
  }
  
  /**
   * Set global [search].
   * Reneding triggers automatically.
   */
  setSearch(String search) {
    _scope.context['searchBy'] = search == null ? '' : search;
  }

  /**
   * Navigate to previouse page
   */
  navigatePrevPage() {
    _scope.context['currentPage'] = _scope.context['currentPage'] - 1;
  }
  
  /**
   * Navigate to next page
   */
  navigateNextPage() {
    _scope.context['currentPage'] = _scope.context['currentPage'] + 1;
  }
}
