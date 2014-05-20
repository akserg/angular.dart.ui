// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please seegriddropdown_toggle;
part of angular.ui.grid;

class Updater {
  Scope scope;
  dom.TableElement grid;
  Header header;
  Body body;
  Footer footer;
  Fields fields;
  
  Updater(this.scope, this.grid, this.fields) {
    header = new Header(scope, grid);
    body = new Body(scope, grid);
    footer = new Footer(scope, grid);
  }
  
  update() {
    // Remove all children of grid before rendering
    grid.children.clear();
    // Create header
    header.createHead();
    // Create Footer
    footer.createFooter();
    // Create Body
    body.createBody();
  }
  
  /**
   * 
   * Scope variables:
   * searchBy
   * filterByFields
   * orderBy
   * orderByReverse
   * renderingItems
   * currentPage
   * itemsOnPage
   * columns
   * startItemIndex
   * endItemIndex
   */
  void prepareToRender() {
    List result = [];
    // Filter items by gridOptions.searchBy
    result = applySearch(scope.context['items'], scope.context['searchBy']);
    // Filter result by gridOptions.filterByFields
    result = applyFilterByFields(result, scope.context['filterByFields']);
    // Order by gridOptions.orderBy
    result = applyOrderBy(result, scope.context['orderBy'], scope.context['orderByReverse']);
    // Update pager
    updatePager(result.length);
    // Apply paging
    scope.context['renderingItems'] = paging(result, scope.context['currentPage'], scope.context['itemsOnPage']);
  }

  List applySearch(List input, String filterValue) {
    List result = [];
    if (filterValue != null && filterValue.trim().length > 0) {
      filterValue = filterValue.toLowerCase();
      result = input.where((item) {
        // Pass through all columns to find contains filter value
        return scope.context['columns'].any((GridColumn column) {
          return fields.getField(item, column.fieldName).toLowerCase().contains(filterValue);
        });
      }).toList();
    } else {
      result = new List.from(input);
    }
    return result;
  }
  
  List applyFilterByFields(List input, Map filters) {
    List result = new List.from(input);
    if (filters != null && filters.length > 0) {
      // Prepare cols to filter
      scope.context['columns'].forEach((GridColumn colDef) {
        // Check is columns must be filtered
        if (filters.containsKey(colDef.fieldName)) {
          result = applyFilterBy(result, filters[colDef.fieldName], colDef);
        }
      });
    }
    return result;
  }
  
  List applyFilterBy(List input, String filterValue, GridColumn column) {
    List result = [];
    if (filterValue != null && filterValue.trim().length > 0) {
      filterValue = filterValue.toLowerCase();
      result = input.where((item) {
        // Check is column value starts with filterValue
        return fields.getField(item, column.fieldName).toLowerCase().startsWith(filterValue);
      }).toList();
    } else {
      result = new List.from(input);
    }
    return result;
  }

  List applyOrderBy(List input, String orderBy, bool orderByReverse) {
    List result = new List.from(input);
    if (orderBy != null && orderBy.trim().length > 0) {
      // Find column definition
      result.sort((item1, item2) {
        String val1 = fields.getField(item1, orderBy);
        String val2 = fields.getField(item2, orderBy);
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
  
  List paging(List input, int currentPage, int itemsOnPage) {
    List result = [];
    if (itemsOnPage > 0 && input.length > 0) {
      result = input.sublist(scope.context['startItemIndex'], scope.context['endItemIndex'] + 1);
    } else {
      result = new List.from(input);
    }
    return result;
  }
  
  //**************
  // Pager updates
  //**************
 
  updateTotalItems(List input) {
    if (input != null) {
      scope.context['totalItems'] = input.length;
    } else {
      scope.context['totalItems'] = 0;
    }

    updatePager(scope.context['totalItems']);
  }
  
  resetPager() {
    scope.context['startItemIndex'] = 0;
    scope.context['currentPage'] = 0;
    scope.context['endItemIndex'] = 0;
  }
  
  updatePager(int totalItems) {
    bool isPaged = scope.context['itemsOnPage'] > 0;

    // do not set scope.gridOptions.totalItems, it might be set from the outside
    scope.context['totalItemsCount'] = totalItems != null ? totalItems : scope.context['items'] != null ? scope.context['items'].length : 0;

    if (scope.context['totalItemsCount'] > 0) {
      scope.context['startItemIndex'] = isPaged ? scope.context['itemsOnPage'] * scope.context['currentPage'] : 0;
      scope.context['endItemIndex'] = isPaged ? scope.context['startItemIndex'] + scope.context['itemsOnPage'] - 1 : scope.context['totalItemsCount'] - 1;
      if (scope.context['endItemIndex'] >= scope.context['totalItemsCount']) {
        scope.context['endItemIndex'] = scope.context['totalItemsCount'] - 1;
      }
      if (scope.context['endItemIndex'] < scope.context['startItemIndex']) {
        scope.context['endItemIndex'] = scope.context['startItemIndex'];
      }
  
      scope.context['pageCanGoBack'] = isPaged && scope.context['currentPage'] > 0;
      scope.context['pageCanGoForward'] = isPaged && scope.context['endItemIndex'] < scope.context['totalItemsCount'] - 1;
    } else {
      scope.context['startItemIndex'] = scope.context['endItemIndex'] = 0;
      scope.context['pageCanGoBack'] = scope.context['pageCanGoForward'] = false;
    }
  }
}