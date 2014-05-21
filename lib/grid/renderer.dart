// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please seegriddropdown_toggle;
part of angular.ui.grid;

class Renderer {
  Scope scope;
  dom.TableElement grid;
  Fields fields;
  Injector injector;
  
  Renderer(this.scope, this.grid, this.fields, this.injector);
  
  dom.TableSectionElement get body => grid.tBodies.first;
  
  /**
   * Render data based in column information
   * 
   * Scope variables:
   * renderingItems
   * selectedItems
   * columns
   * enableSelections
   * enableMultiRowSelections
   */
  render() {
    // Clear gird body before render
    body.children.clear();
    // Prepare items to show
    List preparedItems = scope.context['renderingItems'];
    //
    preparedItems.forEach((gridItem) {
      scope.context['gridItem'] = gridItem;
      dom.TableRowElement row;
      row = body.addRow()
      ..classes.add(scope.context['selectedItems'].indexOf(gridItem) != -1 ? 'active' : '')
      ..onClick.listen((dom.MouseEvent evt) {
        markRowSelected(row, toggleItemSelection(gridItem));
      });
      //
      scope.context['columns'].forEach((GridColumn column) {
        dom.TableCellElement cell = row.addCell();
        dom.DivElement data = new dom.DivElement();
        if (column.itemRenderer != null && column.itemRenderer.length > 0) {
          data.setInnerHtml(column.itemRenderer);
          renderItem(data);
        } else if (column.fieldName != null) {
          data.text = fields.getField(gridItem, column.fieldName);
        }
        if (column.fieldName != null) {
          data.attributes['field-name'] = column.fieldName;
        }
        cell.append(data);
      });
    });
  }
  
  void markRowSelected(dom.TableRowElement row, bool selected) {
    if (selected) {
      row.classes.add('active');
    } else {
      row.classes.remove('active');
    }
  }
  
  bool toggleItemSelection(item) {
    if (scope.context['enableSelections']) {
      int itemIndex = scope.context['selectedItems'].indexOf(item);
      if (itemIndex != -1) {
        // We found him - just remove
        scope.context['selectedItems'].removeAt(itemIndex);
      } else {
        if (!scope.context['enableMultiRowSelections']) {
          scope.context['selectedItems'].clear();
        }
        scope.context['selectedItems'].add(item);
        return true;
      }
    }
    return false;
  }
  
  dom.Element renderItem(dom.Element itemRenderer) {
    dom.Element element = compile2(itemRenderer, injector, scope:scope); // parser(itemRenderer); // eval(scope, '"${itemRenderer}"', '');
    return element;
  }
}