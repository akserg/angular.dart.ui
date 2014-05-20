// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please seegriddropdown_toggle;
part of angular.ui.grid;

class Body {
  Scope scope;
  dom.TableSectionElement body;
  dom.TableElement grid;
  
  Body(this.scope, this.grid);
  
  createBody() {
    body = grid.createTBody()
    ..attributes['sm-ng-grid-body'] = '';
  }

}