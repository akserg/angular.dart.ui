// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please seegriddropdown_toggle;
part of angular.ui.grid;

class Header {
  Scope scope;
  dom.TableElement grid;
  dom.TableSectionElement head;
  
  static const String columnTemplate = """ 
<div class="sm-ng-cell">
  <div>
    <div class="sm-ng-title"></div>
    <div title="Sort" class="sm-ng-sort" sm-ng-grid-column-sort="">
      <div class="sm-ng-sort-inactive"></div>
    </div>
  </div>
  <div class="sm-ng-filter" sm-ng-grid-column-filter="">
    <div><input class="form-control input-sm" type="text"></div>
  </div>
</div>"""; 
  
  Header(this.scope, this.grid);
  
  /**
   * Create Head element and all columns based on [gridColumn] from scope.
   * 
   * Scope variables:
   * columns
   * column$colNumber
   * column$colNumber.enableSorting
   * column$colNumber.enableFiltering
   * orderBy
   * orderByReverse
   * toggleSorting - function
   * setFilter
   */
  createHead() {
    head = grid.createTHead();
    dom.TableRowElement row = head.addRow()
    ..attributes['sm-ng-grid-header'] = '';
    int colNumber = 0;
    scope.context['columns'].forEach((GridColumn column) {
      // Push column definition into scope so we can watch of property 
      // changes
      scope.context['column$colNumber'] = column;
      // Create TH
      dom.TableCellElement th = new dom.Element.th()
      ..attributes['field-name'] = column.fieldName != null ? column.fieldName : '';
      row.nodes.add(th);
      // Add column specific or general template to column
      String html = column.headerRenderer != null ? column.headerRenderer : columnTemplate;
      th.setInnerHtml(html);
      
      // Find title
      dom.DivElement title = th.querySelector(".sm-ng-title");
      if (title != null) {
        title.text = column.displayName;
      }
      // Find sort wrapper
      dom.DivElement sort = th.querySelector(".sm-ng-sort");
      if (sort != null) {
        sort.onClick.listen((dom.MouseEvent evt){
          scope.context['toggleSorting'](column.fieldName);
        });
        scope.watch('column$colNumber.enableSorting', (value, old) {
          if (toBool(value)) {
            sort.classes.remove('ng-hide');
          } else {
            sort.classes.add('ng-hide');
          }
        });
      }
      // Find sort icon
      dom.DivElement icon = th.querySelector(".sm-ng-sort-inactive,.sm-ng-sort-active");
      if (icon != null) {
        scope.watch('orderBy', (value, old) {
          if (value == column.fieldName) {
            icon.classes.add('sm-ng-sort-active');
            icon.classes.remove('sm-ng-sort-inactive');
          } else {
            icon.classes.add('sm-ng-sort-inactive');
            icon.classes.remove('sm-ng-sort-active');
          }
        });
        scope.watch('orderByReverse', (value, old) {
          if (value) {
            icon.classes.add('sm-ng-sort-reverse');
          } else {
            icon.classes.remove('sm-ng-sort-reverse');
          }
        });
      }
      // Find filter wrapper
      dom.DivElement filter = th.querySelector(".sm-ng-filter");
      if (filter != null) {
        scope.watch('column$colNumber.enableFiltering', (value, old) {
          if (toBool(value)) {
            filter.classes.remove('ng-hide');
          } else {
            filter.classes.add('ng-hide');
          }
        });
      }
      //
      dom.InputElement input = th.querySelector(".form-control");
      if (input != null) {
        input.onChange.listen((dom.Event evt) {
          scope.context['setFilter'](column.fieldName, input.value);
        });
        input.onInput.listen((dom.Event evt) {
          scope.context['setFilter'](column.fieldName, input.value);
        });
      }
      //
      colNumber++;
    });
  }
}