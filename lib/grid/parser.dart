// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please seegriddropdown_toggle;
part of angular.ui.grid;

class Parser {
  Scope scope;
  dom.TableElement grid;
  
  static const String rendererTemplate = "";
  
  Parser(this.scope, this.grid);

  /**
   * Check were columns defined? If not we trying define them based on [items].
   * If columns were defined in here then that method returns true else false.
   * 
   * Scope variables:
   * columns
   * items
   * enableSorting
   * enableFiltering
   */
  bool defineColumns() {
    if (scope.context['columns'].length == 0 && scope.context['items'].length > 0 && scope.context['items'].first is Map) {
      Map item = scope.context['items'].first;
      for (var key in item.keys) {
        GridColumn column = new GridColumn()
        ..fieldName = key
        ..displayName = splitByCamelCasing(key)
        ..enableSorting = scope.context['enableSorting']
        ..enableFiltering = scope.context['enableFiltering'];
        scope.context['columns'].add(column);
      }
      return true;
    }
    return false;
  }

  parse() {
    // Check header renderers
    if (grid.tHead != null) {
      // Find all fields
      List fields = grid.tHead.querySelectorAll("tr > th");
      fields.forEach((dom.TableCellElement th) {
        (scope.context['columns'] as List).add(parseColumn(th));
      });
    }
    // Check body renderers
    if (grid.tBodies.length > 0) {
      int i = 0;
      List<dom.TableCellElement> tds =  grid.tBodies.first.querySelectorAll("td"); 
      tds.forEach((dom.TableCellElement td) {
        parseRenderer(td, scope.context['columns'], i++);
      });
    }
  }
  
  GridColumn parseColumn(dom.TableCellElement th) {
    GridColumn column = new GridColumn();

    column.fieldName = getValue(th, 'field-name');
    if (column.fieldName != null) {
      column.displayName = getValue(th, 'display-name', splitByCamelCasing(column.fieldName));
      column.displayAlign = getValue(th, 'display-align', 'left');
      column.displayFormat = getValue(th, 'display-format');
      column.enableSorting = getValue(th, 'enable-sorting', scope.context['enableSorting']);
      column.enableFiltering = getValue(th, 'enable-filtering', scope.context['enableFiltering']);
      column.cellWidth = getValue(th, 'cell-width');
      column.cellHeight = getValue(th, 'cell-height');
    }    
    // Remove whitespaces from content of TH
    String content = th.innerHtml.trim();
    if (content.length > 0) {
      // We have template - save it
      column.headerRenderer = content;
    }
    return column;
  }
  
  parseRenderer(dom.TableCellElement td, List<GridColumn> columns, int indx) {
    GridColumn column;
    String fieldName = getValue(td, 'field-name'); 
    if (fieldName != null) {
      // Find column
      column = columns.firstWhere((GridColumn column) {
        return column.fieldName == fieldName;
      });
      // Check columns
      if (column != null) {
        column.itemRenderer = td.innerHtml.trim();
        return;
      }
    }
    // Column not found - use index
    if (indx <= columns.length - 1) {
      column = columns.elementAt(indx);
      if (column != null) {
        column.itemRenderer = td.innerHtml.trim();
      }
    }
  }
  
  getValue(dom.TableCellElement th, String attribute, [defaultValue = null]) {
    return th.attributes.containsKey(attribute) ? th.attributes[attribute] : defaultValue;
  }
}