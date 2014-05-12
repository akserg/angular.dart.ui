// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please seegriddropdown_toggle;

import 'dart:html' as dom;
import 'dart:async' as async;
import "package:angular/angular.dart";
import "package:angular/core_dom/module_internal.dart";
import "package:angular_ui/utils/timeout.dart";
import "package:angular_ui/utils/utils.dart";

/**
 * Grid Module.
 */
class GridModule extends Module {
  GridModule() {
    type(Grid);
  }
}

typedef OnDataRequired(GridOptions options);

class GridColumnOptions {
  String fieldName;
  String displayName;
  String displayAlign = 'left';
  String displayFormat;
  bool enableSorting = true;
  bool enableFiltering = true;
  String cellWidth;
  String cellHeight;
}

class GridOptions {
  List selectedItems = [];
  String searchBy;
  Map filterByFields = {};
  String orderBy;
  bool orderByReverse = false;
  int pageItems = 5;
  int currentPage = 0;
  int totalItems = 0;
  bool enableFiltering = true;
  bool enableSorting = true;
  bool enableSelections = true;
  bool enableMultiRowSelections = true;
  OnDataRequired onDataRequired;
  int onDataRequiredDelay = 1000;
  List<GridColumnOptions> gridColumnDefs = [];
}

class PagerOptions {
  bool isPaged;
  int totalItemsCount;
  int startItemIndex;
  int endItemIndex;
  bool pageCanGoBack;
  bool pageCanGoForward;
}

@Decorator(selector:"table[tr-ng-grid]")
class Grid {
  
//  List _items = [];
//  @NgTwoWay('items')
//  set items(value) {
//    _items = value == null ? [] : value;
//    _initialisePager(_items);
//    if (_checkAndDefineColumns()) {
//      _update();
//    }
//    _render();
//  }
//  List get items => _items;
  List items = [];
  
  @NgOneWay('enable-selections')
  set enableSelections(value) {
    if (gridOptions.enableSelections != value) {
      gridOptions.enableSelections = value;
      if (!gridOptions.enableSelections) {
        gridOptions.selectedItems.clear();
        gridOptions.enableMultiRowSelections = false;
      }
    }
  }
  get enableSelections => gridOptions.enableSelections;
  
  @NgOneWay('enable-multi-row-selections')
  set enableMultiRowSelections(value) {
    if (gridOptions.enableMultiRowSelections != value) {
      gridOptions.enableMultiRowSelections = value;
      if (!gridOptions.enableMultiRowSelections) {
        if (gridOptions.selectedItems.length > 1) {
          gridOptions.selectedItems.removeRange(1, gridOptions.selectedItems.length - 1);
        }
      }
    }
  }
  get enableMultiRowSelections => gridOptions.enableMultiRowSelections;
  
  @NgTwoWay('selected-items')
  set selectedItems(value) {
    gridOptions.selectedItems = value;
    _render();
  }
  get selectedItems => gridOptions.selectedItems;
  
  dom.TableElement _grid;
  dom.TableSectionElement _head;
  dom.TableSectionElement _body;
  
  Scope _scope;
  NodeAttrs _attrs;
  Timeout _timeout;
  async.Completer _dataRequestPromise;
  FieldGetterFactory _fieldGetterFactory;
  
  GridOptions gridOptions;
  PagerOptions pagerOptions;
  
  Grid(dom.Element gridEl, this._scope, this._attrs, this._timeout, this._fieldGetterFactory) {
    _grid = gridEl as dom.TableElement;
    _grid.classes.add('tr-ng-grid table table-hover');
    //
    _scope.context['gridOptions'] = gridOptions = new GridOptions();
    _scope.context['pagerOptions'] = pagerOptions = new PagerOptions();
    //
    _scope.watch('[gridOptions.currentPage, items.length, gridOptions.totalItems, gridOptions.pageItems]', (value, old){
      _updatePager(gridOptions.totalItems);
    }, collection:true);
    //
    _parse();
    _update();
    _updatePager(gridOptions.totalItems);
    _render();
    _parseAttributes();
  }

  _parseAttributes() {
    _attrs.observe('items', (value) {
      items = _scope.context['items'] = eval(_scope, value, []);
      _initialisePager(items);
      if (_checkAndDefineColumns()) {
        _update();
      }
      _render();      
    });
    //
    _scope.watch('items', (value, old) {
      _initialisePager(items);
      if (_checkAndDefineColumns()) {
        _update();
      }
      _render();
    });
    // TODO: Add wath enableSorting and filtering and manage columns
  }
  
  _parse() {
    
  }
  
  //*******
  // Update
  //*******
  
  // Update internal element with GridOptions
  _update() {
    // Remove all children of grid before rendering
    _grid.children.clear();
    // Create header
    _createHead();
    // Create Footer
    _createFooter();
    // Create Body
    _createBody();
  }
  
  /**
   * Create Head element and all columns based on [GridOptions].gridColumnDefs
   * of [GridColumnOptions].
   */
  _createHead() {
    _head = _grid.createTHead();
    dom.TableRowElement row = _head.addRow()
    ..attributes['tr-ng-grid-header'] = '';
//    <th field-name="id" class="ng-scope">
    gridOptions.gridColumnDefs.forEach((GridColumnOptions colDef) {
      // Push current column definition into scope
      _scope.context['currentGridColumnDef'] = colDef;
      //
      dom.TableCellElement th = row.addCell()
      ..attributes['field-name'] = colDef.fieldName;
      //
//      <div class="tr-ng-cell ng-scope">
      dom.DivElement cell = new dom.DivElement()
      ..classes.add('tr-ng-cell');
      th.append(cell);
      //
//        <div>
      dom.DivElement sortWrapper = new dom.DivElement();
      cell.append(sortWrapper);
      //
//          <div class="tr-ng-title">Id</div>
      dom.DivElement title = new dom.DivElement()
      ..classes.add('tr-ng-title')
      ..text = colDef.displayName;
      sortWrapper.append(title);
      //
//          <div ng-show="currentGridColumnDef.enableSorting" ng-click="toggleSorting(currentGridColumnDef.fieldName)" title="Sort" class="tr-ng-sort" tr-ng-grid-column-sort="">
      dom.DivElement sort = new dom.DivElement()
      ..title = "Sort"
      ..classes.add("tr-ng-sort ng-hide")
      ..attributes['tr-ng-grid-column-sort'] = ''
      ..onClick.listen((dom.MouseEvent evt){
        toggleSorting(colDef.fieldName);
      });
      _scope.watch('currentGridColumnDef.enableSorting', (value, old) {
        if (toBool(value)) {
          sort.classes.remove('ng-hide');
        } else {
          sort.classes.add('ng-hide');
        }
      });
      sortWrapper.append(sort);
      //
//            <div ng-class="{'tr-ng-sort-active':gridOptions.orderBy==currentGridColumnDef.fieldName,'tr-ng-sort-inactive':gridOptions.orderBy!=currentGridColumnDef.fieldName,'tr-ng-sort-reverse':gridOptions.orderByReverse}" class="tr-ng-sort-inactive"></div>
      dom.DivElement icon = new dom.DivElement()
      ..classes.add('tr-ng-sort-inactive');
      _scope.watch('gridOptions.orderBy', (value, old) {
        if (value == colDef.fieldName) {
          icon.classes.add('tr-ng-sort-active');
          icon.classes.remove('tr-ng-sort-inactive');
        } else {
          icon.classes.add('tr-ng-sort-inactive');
          icon.classes.remove('tr-ng-sort-active');
        }
      });
      _scope.watch('gridOptions.orderByReverse', (value, old) {
        if (value) {
          icon.classes.add('tr-ng-sort-reverse');
        } else {
          icon.classes.remove('tr-ng-sort-reverse');
        }
      });
      sort.append(icon);
      //
//        <div ng-show="currentGridColumnDef.enableFiltering" class="tr-ng-column-filter" tr-ng-grid-column-filter="">
      dom.DivElement filter = new dom.DivElement()
      ..classes.add('tr-ng-column-filter')
      ..attributes['tr-ng-grid-column-filter'] = '';
      _scope.watch('currentGridColumnDef.enableFiltering', (value, old) {
        if (toBool(value)) {
          filter.classes.remove('ng-hide');
        } else {
          filter.classes.add('ng-hide');
        }
      });
      cell.append(filter);
      //
//          <div class=""><input class="form-control input-sm ng-pristine ng-valid" type="text" ng-model="filter"></div>
      dom.DivElement inputWrapper = new dom.DivElement();
      filter.append(inputWrapper);
      //
      dom.InputElement input;
      input = new dom.InputElement()
      ..classes.add('form-control input-sm ng-valid')
      ..type = 'text'
      ..onChange.listen((dom.Event evt) {
          setFilter(colDef.fieldName, input.value);
      })
      ..onInput.listen((dom.Event evt) {
        setFilter(colDef.fieldName, input.value);
      });
      inputWrapper.append(input);
    });
  }
  
  /**
   * Create Foot element, global search and pager based on 
   * [GridOptions].totalItemsCount
   */
  _createFooter() {
//    <tfoot>
    dom.TableSectionElement foot = _grid.createTFoot();
//      <tr>
    dom.TableRowElement row = foot.addRow();
//        <td colspan="999">
    dom.TableCellElement cell = row.addCell()
    ..colSpan = gridOptions.gridColumnDefs.length;
//          <div class="tr-ng-grid-footer form-inline" tr-ng-grid-footer="">
    dom.DivElement wrapper = new dom.DivElement()
    ..classes.add('tr-ng-grid-footer form-inline')
    ..attributes['tr-ng-grid-footer'];
    cell.append(wrapper);
//            <span ng-show="gridOptions.enableFiltering" class="pull-left form-group ng-scope" tr-ng-grid-global-filter="">
    dom.SpanElement filter = new dom.SpanElement()
    ..classes.add('pull-left form-group ng-scope ng-hide')
    ..attributes['tr-ng-grid-global-filter'] = '';
    _scope.watch('gridOptions.enableFiltering', (value, old) {
      if (toBool(value)) {
        filter.classes.remove('ng-hide');
      } else {
        filter.classes.add('ng-hide');
      }
    });
    wrapper.append(filter);
//              <input class="form-control ng-pristine ng-valid" type="text" ng-model="gridOptions.filterBy" placeholder="Search">
    dom.InputElement input;
    input = new dom.InputElement()
    ..classes.add('form-control ng-pristine ng-valid')
    ..type = 'text'
    ..placeholder = 'Search'
    ..onChange.listen((dom.Event evt) {
      setSearch(input.value);
    })
    ..onInput.listen((dom.Event evt) {
      setSearch(input.value);
    });
    filter.append(input);
//            </span>
//            <span class="pull-right form-group ng-scope" tr-ng-grid-pager="">
    dom.SpanElement pager = new dom.SpanElement()
    ..classes.add('pull-right form-group ng-scope')
    ..attributes['tr-ng-grid-pager'] = '';
    wrapper.append(pager);
//              <ul class="pagination">
    dom.UListElement pagination = new dom.UListElement()
    ..classes.add('pagination');
    _scope.watch('gridOptions.pageItems', (value, old) {
      if (toInt(value) > 0) {
        pagination.classes.remove('ng-model');
      } else {
        pagination.classes.add('ng-model');
      }
    });
    pager.append(pagination);
//                <li><a href="#" ng-show="pageCanGoBack" ng-click="navigatePrevPage($event)" title="Previous Page" class="ng-hide">â‡</a></li>
    dom.LIElement prev = new dom.LIElement();
    pagination.append(prev);
    dom.AnchorElement prevIcon = new dom.AnchorElement()
    ..href = '#'
    ..title = 'Previous Page'
    ..classes.add('ng-hide')
    ..setInnerHtml('&lArr;')
    ..onClick.listen((dom.MouseEvent evt) {
      navigatePrevPage(evt);
    });
    _scope.watch('pagerOptions.pageCanGoBack', (value, old) {
      if (toBool(value)) {
        prevIcon.classes.remove("ng-hide");
      } else {
        prevIcon.classes.add("ng-hide");
      }
    });
    prev.append(prevIcon);
//                <li class="disabled" style="white-space: nowrap;">
    dom.LIElement display = new dom.LIElement()
    ..classes.add('disabled')
    ..style.whiteSpace = 'nowrap';
    pagination.append(display);
//                  <span ng-hide="totalItemsCount" class="ng-hide">No items to display</span>
    dom.SpanElement itemsToDisplay = new dom.SpanElement()
    ..text = 'No items to display';
    _scope.watch('[pagerOptions.startItemIndex, pagerOptions.endItemIndex, pagerOptions.totalItemsCount]', (value, old) {
      if (pagerOptions.totalItemsCount == null || pagerOptions.totalItemsCount == 0) {
        itemsToDisplay.text = 'No items to display';
      } else {
        //itemsToDisplay.text = '${_scope.context["pagerOptions.startItemIndex"] + 1} - ${_scope.context["pagerOptions.endItemIndex"] + 1} displayed, ${_scope.context["pagerOptions.totalItemsCount"]} in count // ${gridOptions.currentPage}';
        itemsToDisplay.text = '${pagerOptions.startItemIndex + 1} - ${pagerOptions.endItemIndex + 1} displayed, ${pagerOptions.totalItemsCount} in total';
      }
    }, collection:true);
    display.append(itemsToDisplay);
//                </li>
//                <li><a href="#" ng-show="pageCanGoForward" ng-click="navigateNextPage($event)" title="Next Page" class="ng-hide">â‡’</a></li>
    dom.LIElement next = new dom.LIElement();
    pagination.append(next);
    dom.AnchorElement nextIcon = new dom.AnchorElement()
    ..href = '#'
    ..title = 'Next Page'
    ..classes.add('ng-hide')
    ..setInnerHtml('&rArr;')
    ..onClick.listen((dom.MouseEvent evt) {
      navigateNextPage(evt);
    });
    _scope.watch('pagerOptions.pageCanGoForward', (value, old) {
      if (toBool(value)) {
        nextIcon.classes.remove("ng-hide");
      } else {
        nextIcon.classes.add("ng-hide");
      }
    });
    next.append(nextIcon);
//                <li></li>
//              </ul>
//            </span>
//          </div>
//        </td>
//      </tr>
//    </tfoot>
  }
  
  _createBody() {
//    <tbody tr-ng-grid-body="" class="ng-scope"><!-- ngRepeat: gridItem in gridOptions.items | filter:gridOptions.filterBy | filter:gridOptions.filterByFields | orderBy:gridOptions.orderBy:gridOptions.orderByReverse | paging:gridOptions -->
    _body = _grid.createTBody()
    ..attributes['tr-ng-grid-body'] = '';
  }
  
  
  //**************************
  // Attributes and Properties
  // **************************
  
  /**
   * Check were columns defined? If not we trying define them based on [items].
   * If columns were defined in here then that method returns true else false. 
   */
  bool _checkAndDefineColumns() {
    if (gridOptions.gridColumnDefs.length == 0 && items.length > 0 && items.first is Map) {
      Map item = items.first;
      for (var key in item.keys) {
        GridColumnOptions colDef = new GridColumnOptions()
        ..fieldName = key
        ..displayName = splitByCamelCasing(key)
        ..enableSorting = gridOptions.enableSorting
        ..enableFiltering = gridOptions.enableFiltering;
        gridOptions.gridColumnDefs.add(colDef);
      }
      return true;
    }
    return false;
  }
  
  //**********
  // Rendering
  //**********
  
  List _prepareItemsToRender(List input) {
    List result = [];
    // Filter items by gridOptions.searchBy
    result = _globalFilterBy(input, gridOptions.searchBy);
    // Filter result by gridOptions.filterByFields
    result = _filterByFields(result, gridOptions.filterByFields);
    // Order by gridOptions.orderBy
    result = _orderBy(result, gridOptions.orderBy, gridOptions.orderByReverse);
    // Update pager
    _updatePager(result.length);
    // Apply paging
    result = _paging(result, gridOptions.currentPage, gridOptions.pageItems);
    return result;
  }
  
  List _globalFilterBy(List input, String filterValue) {
    List result = [];
    if (filterValue != null && filterValue.trim().length > 0) {
      filterValue = filterValue.toLowerCase();
      result = input.where((item) {
        // Pass through all columns to find contains filter value
        return gridOptions.gridColumnDefs.any((GridColumnOptions colDef) {
          return getField(item, colDef.fieldName).toLowerCase().contains(filterValue);
        });
      }).toList();
    } else {
      result = new List.from(input);
    }
    return result;
  }
  
  List _filterByFields(List input, Map filters) {
    List result = new List.from(input);
    if (filters != null && filters.length > 0) {
      // Prepare cols to filter
      gridOptions.gridColumnDefs.forEach((GridColumnOptions colDef) {
        // Check is columns must be filtered
        if (filters.containsKey(colDef.fieldName)) {
          result = _filterBy(result, filters[colDef.fieldName], colDef);
        }
      });
    }
    return result;
  }
  
  List _filterBy(List input, String filterValue, GridColumnOptions colDef) {
    List result = [];
    if (filterValue != null && filterValue.trim().length > 0) {
      filterValue = filterValue.toLowerCase();
      result = input.where((item) {
        // Check is column value starts with filterValue
        return getField(item, colDef.fieldName).toLowerCase().startsWith(filterValue);
      }).toList();
    } else {
      result = new List.from(input);
    }
    return result;
  }

  List _orderBy(List input, String orderBy, bool orderByReverse) {
    List result = new List.from(input);
    if (orderBy != null && orderBy.trim().length > 0) {
      // Find column definition
      result.sort((item1, item2) {
        String val1 = getField(item1, orderBy);
        String val2 = getField(item2, orderBy);
        // Compare to not null string
        if (orderByReverse) {
          return val2.compareTo(val1);
        } else {
          return val1.compareTo(val2);
        }
      });
    }
    return result;
  }
  
  List _paging(List input, int currentPage, int pageItems) {
    List result = [];
    if (pageItems > 0 && input.length > 0) {
      result = input.sublist(pagerOptions.startItemIndex, pagerOptions.endItemIndex + 1);
    } else {
      result = new List.from(input);
    }
    return result;
  }
  
  // Render data based in column information
  _render() {
    // Clear gird body before render
    _body.children.clear();
    // Prepare items to show
    List preparedItems = _prepareItemsToRender(items);
    //
    preparedItems.forEach((gridItem) {
//      <tr 
      //ng-repeat="gridItem in gridOptions.items | filter:gridOptions.filterBy | filter:gridOptions.filterByFields | orderBy:gridOptions.orderBy:gridOptions.orderByReverse | paging:gridOptions" ng-click="toggleItemSelection(gridItem)" 
      //ng-class="{'active':gridOptions.selectedItems.indexOf(gridItem)>=0}" tr-ng-grid-row-page-item-index="0" class="ng-scope">
      dom.TableRowElement row;
      row = _body.addRow()
      ..classes.add(gridOptions.selectedItems.indexOf(gridItem) != -1 ? 'active' : '')
      ..onClick.listen((dom.MouseEvent evt) {
        if (_toggleItemSelection(gridItem)) {
          row.classes.add('active');
        } else {
          row.classes.remove('active');
        }
      });
//      ..attributes['tr-ng-grid-row-page-item-index'] = '0';
      gridOptions.gridColumnDefs.forEach((GridColumnOptions colDef) {
        
//        <td><div class="tr-ng-cell ng-binding" field-name="id">01</div></td>
        dom.TableCellElement cell = row.addCell();
        dom.DivElement data = new dom.DivElement()
        ..classes.add('tr-ng-cell')
        ..attributes['field-name'] = colDef.fieldName
        ..text = getField(gridItem, colDef.fieldName);
        cell.append(data);
      });
    });
  }
  
  String getField(item, String name) {
    var val;
    if (item is Map) {
      val = item[name];
    } else if (item is List) {
      val = item.toString();
    } else {
      Function itemGetter = _fieldGetterFactory.getter(item, name);
      val = itemGetter(item);
    }
    
    return val == null ? '' : val.toString();
  }

  //******
  // Logic
  //******
  
  toggleSorting(String propertyName) {
    if (gridOptions.orderBy != propertyName) {
      // the column has changed
      gridOptions.orderBy = propertyName;
    } else {
      // the sort direction has changed
      gridOptions.orderByReverse = !gridOptions.orderByReverse;
    }
    
    _render();
  }
  
  setFilter(String propertyName, String filter) {
    if (filter == null) {
      if (gridOptions.filterByFields.containsKey(propertyName)) {
        gridOptions.filterByFields.remove(propertyName);
      }
    } else {
      gridOptions.filterByFields[propertyName] = filter;
    }

    _render();
  }
  
  setSearch(String search) {
    gridOptions.searchBy = search == null ? '' : search;

    _render();
  }
  
  navigatePrevPage(dom.Event event) {
    gridOptions.currentPage = gridOptions.currentPage - 1;
    event.preventDefault();
    event.stopPropagation();
    
    _updatePager(gridOptions.totalItems);
    _render();
  }
  
  navigateNextPage(dom.Event event) {
    gridOptions.currentPage = gridOptions.currentPage + 1;
    event.preventDefault();
    event.stopPropagation();
    
    _updatePager(gridOptions.totalItems);
    _render();
  }
  
  _updatePager(int totalItems) {
    pagerOptions.isPaged = gridOptions.pageItems > 0;

    // do not set scope.gridOptions.totalItems, it might be set from the outside
    pagerOptions.totalItemsCount = totalItems != null ? totalItems : items != null ? items.length : 0;

    if (pagerOptions.totalItemsCount > 0) {
      pagerOptions.startItemIndex = pagerOptions.isPaged ? gridOptions.pageItems * gridOptions.currentPage : 0;
      pagerOptions.endItemIndex = pagerOptions.isPaged ? pagerOptions.startItemIndex + gridOptions.pageItems-1 : pagerOptions.totalItemsCount - 1;
      if (pagerOptions.endItemIndex >= pagerOptions.totalItemsCount) {
        pagerOptions.endItemIndex = pagerOptions.totalItemsCount - 1;
      }
      if (pagerOptions.endItemIndex < pagerOptions.startItemIndex) {
        pagerOptions.endItemIndex = pagerOptions.startItemIndex;
      }
  
      pagerOptions.pageCanGoBack = pagerOptions.isPaged && gridOptions.currentPage > 0;
      pagerOptions.pageCanGoForward = pagerOptions.isPaged && pagerOptions.endItemIndex < pagerOptions.totalItemsCount - 1;
    } else {
      pagerOptions.startItemIndex = pagerOptions.endItemIndex = 0;
      pagerOptions.pageCanGoBack = pagerOptions.pageCanGoForward = false;
    }
  }
  
  _initialisePager(List input) {
    if (input != null) {
      gridOptions.totalItems = input.length;
    } else {
      gridOptions.totalItems = 0;
    }

    _updatePager(gridOptions.totalItems);
  }
  
  bool _toggleItemSelection(item) {
    if (gridOptions.enableSelections) {
      var itemIndex = gridOptions.selectedItems.indexOf(item);
      if (itemIndex != -1) {
        // We found him - just remove
        gridOptions.selectedItems.removeAt(itemIndex);
      } else {
        if (!gridOptions.enableMultiRowSelections) {
          gridOptions.selectedItems.clear();
        }
        gridOptions.selectedItems.add(item);
        return true;
      }
    }
    return false;
  }
}