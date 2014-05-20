// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please seegriddropdown_toggle;
part of angular.ui.grid;

class Parser {
  Scope scope;
  
  Parser(this.scope);

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
    
  }
  
}