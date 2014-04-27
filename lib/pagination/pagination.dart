// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.pagination;

import 'dart:html' as dom;

import 'package:angular/angular.dart';
import "package:angular/core_dom/module_internal.dart";

import "package:angular_ui/utils/utils.dart";

class PaginationModule extends Module {

  PaginationModule() {
    type(PagerComponent);
  }
}

@Component(
    selector: 'pager[ng-model]',
    templateUrl: 'packages/angular_ui/pagination/pager.html',
    publishAs: 'ctrl')
class PagerComponent {
  final NgModel ngModel;
  final Scope scope;
  int currentPage;
  int totalPages = 5;

  @NgCallback('on-select-page')
  var onSelectChange;

  PagerComponent(this.ngModel, this.scope) {
    ngModel.render = _render;
  }

  void selectPage(int selectedPage) {
    if (currentPage != selectedPage && selectedPage > 0 && selectedPage <= totalPages) {
      currentPage = selectedPage;
      scope.apply(() => ngModel.viewValue = selectedPage);
      onSelectChange(null);
    }
  }


  void _render(value) {
    int intValue = toInt(value);
    if (intValue != currentPage) {
      currentPage = intValue;
    }
  }

}