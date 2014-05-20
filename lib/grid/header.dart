// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please seegriddropdown_toggle;
part of angular.ui.grid;

class Header {
  Scope scope;
  dom.TableElement grid;
  dom.TableSectionElement head;
  
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
      //
      dom.TableCellElement th = row.addCell()
      ..attributes['field-name'] = column.fieldName;
      //
      dom.DivElement cell = new dom.DivElement()
      ..classes.add('sm-ng-cell');
      th.append(cell);
      //
      dom.DivElement sortWrapper = new dom.DivElement();
      cell.append(sortWrapper);
      //
      dom.DivElement title = new dom.DivElement()
      ..classes.add('sm-ng-title')
      ..text = column.displayName;
      sortWrapper.append(title);
      //
      dom.DivElement sort = new dom.DivElement()
      ..title = "Sort"
      ..classes.add("sm-ng-sort ng-hide")
      ..attributes['sm-ng-grid-column-sort'] = ''
      ..onClick.listen((dom.MouseEvent evt){
        scope.context['toggleSorting'](column.fieldName);
      });
      scope.watch('column$colNumber.enableSorting', (value, old) {
        if (toBool(value)) {
          sort.classes.remove('ng-hide');
        } else {
          sort.classes.add('ng-hide');
        }
      });
      sortWrapper.append(sort);
      //
      dom.DivElement icon = new dom.DivElement()
      ..classes.add('sm-ng-sort-inactive');
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
      sort.append(icon);
      //
      dom.DivElement filter = new dom.DivElement()
      ..classes.add('sm-ng-column-filter')
      ..attributes['sm-ng-grid-column-filter'] = '';
      scope.watch('column$colNumber.enableFiltering', (value, old) {
        if (toBool(value)) {
          filter.classes.remove('ng-hide');
        } else {
          filter.classes.add('ng-hide');
        }
      });
      cell.append(filter);
      //
      dom.DivElement inputWrapper = new dom.DivElement();
      filter.append(inputWrapper);
      //
      dom.InputElement input;
      input = new dom.InputElement()
      ..classes.add('form-control input-sm ng-valid')
      ..type = 'text'
      ..onChange.listen((dom.Event evt) {
        scope.context['setFilter'](column.fieldName, input.value);
      })
      ..onInput.listen((dom.Event evt) {
        scope.context['setFilter'](column.fieldName, input.value);
      });
      inputWrapper.append(input);
      //
      colNumber++;
    });
  }
}