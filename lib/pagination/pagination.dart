// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.pagination;

import 'dart:html' as dom;
import 'dart:math' as Math;

import 'package:angular/angular.dart';
import "package:angular/core_dom/module_internal.dart";
import "package:angular/core/parser/syntax.dart";

import "package:angular_ui/utils/utils.dart";

class PaginationModule extends Module {

  PaginationModule() {
    value(PagerConfig, new PagerConfig(10, '« Previous', 'Next »', true));
    type(PagerComponent);
    value(PaginationConfig, new PaginationConfig(10, 'Previous', 'Next', true));
    type(PaginationComponent);
  }
}


class PagerConfig {
  int itemsPerPage;
  String previousText;
  String nextText;
  bool align;

  PagerConfig(this.itemsPerPage, this.previousText, this.nextText, this.align);
}

@Component(
    selector: 'pager[ng-model]',
    templateUrl: 'packages/angular_ui/pagination/pager.html',
    publishAs: 'ctrl',
    applyAuthorStyles: true,
    map: const {
    'total-items' : '@totalItems',
    'items-per-page': '@itemsPerPage',
    'num-pages': '&setNumPages',
    'on-select-page': '&onSelectChange',
    'align': '@align',
    'previous-text': '@previousText',
    'next-text': '@nextText'
})

class PagerComponent implements AttachAware, DetachAware {
  final NgModel ngModel;
  final Scope scope;
  final PagerConfig config;

  BoundExpression _setNumPages;

  set setNumPages(value) {
    _setNumPages = value;

    if(_setNumPages != null && _setNumPages.expression.isAssignable) {
      _setNumPages.assign(_totalPages);
    }
  }

  String _previousText;
  String _nextText;
  bool _align;
  set previousText(String value) => _previousText = (value == null? config.previousText : value);
  set nextText(String value) => _nextText = (value == null? config.nextText : value);
  set align(String value) => _align = (value == null? config.align : toBool(value) );

  BoundExpression onSelectChange;

  Watch _totalItemsWatch;
  Watch _itemsPerPageWatch;

  int _currentPage = 0;
  int _totalItems = 0;
  int _itemsPerPage;

  int _totalPages;

  PagerComponent(this.ngModel, this.scope, this.config) {
    ngModel.render = render;
  }

  set totalItems(String value) {
    _totalItemsWatch = scope.parentScope.watch(value, (newValue, previousValue) {
      _totalItems = newValue == null? 0 : newValue;
      calculatePages();
    });
  }

  set itemsPerPage(String value) {
    if (value == null) {
      return;
    }
    _itemsPerPageWatch = scope.parentScope.watch(value, (newValue, previousValue) {
      _itemsPerPage = newValue;
      calculatePages();
    });
  }

  bool get align => _align;
  String get previousText => _previousText;
  String get nextText => _nextText;

  int get totalPages => _totalPages;

  int get currentPage => _currentPage;

  bool get noPrevious => _currentPage <= 1;
  bool get noNext => _currentPage >= _totalPages;

  void attach() {
    _itemsPerPage = 10;
    calculatePages();
  }

  void detach() {
    if (_totalItemsWatch != null)_totalItemsWatch.remove();
    if (_itemsPerPageWatch != null)_itemsPerPageWatch.remove();
  }

  void selectPage(int selectedPage) {
    if (_currentPage != selectedPage && selectedPage > 0 && selectedPage <= totalPages) {
      _currentPage = selectedPage;
      scope.apply(() => ngModel.viewValue = selectedPage);
      onSelectChange(null);
    }
  }

  int _calculateTotalPages() {
    var totalPages = (_totalItems / _itemsPerPage).ceil();
    return Math.max(totalPages, 1);
  }

  void calculatePages() {
    _totalPages = _calculateTotalPages();
    if(_setNumPages != null && _setNumPages.expression.isAssignable) {
      _setNumPages.assign(_totalPages);
    }

    if (_currentPage > _totalPages) {
      _currentPage = _totalPages;
      ngModel.viewValue = _currentPage;
    }
  }


  void render(value) {
    int intValue = toInt(value);
    if (intValue != _currentPage) {
      _currentPage = intValue;
    }
  }

}

class PageInfo {
  int number;
  String text;
  bool isActive;

  PageInfo(this.number, this.text, this.isActive);
}

class PaginationConfig extends PagerConfig {


  PaginationConfig(int itemsPerPage, String previousText, String nextText, bool align) :super(itemsPerPage, previousText, nextText, align);
}

@Component(
    selector: 'pagination[ng-model]',
    templateUrl: 'packages/angular_ui/pagination/pagination.html',
    publishAs: 'ctrl',
    applyAuthorStyles: true,
    map: const {
        'total-items' : '@totalItems',
        'items-per-page': '@itemsPerPage',
        'num-pages': '&setNumPages',
        'on-select-page': '&onSelectChange',
        'align': '@align',
        'previous-text': '@previousText',
        'next-text': '@nextText'
    })

class PaginationComponent extends PagerComponent {

  List<PageInfo> _pages;

  PaginationComponent(NgModel ngModel, Scope scope, PaginationConfig config) : super(ngModel, scope, config) {
  }

  String get firstText => '';
  String get lastText => '';
  bool get boundaryLinks => false;
  bool get directionLinks => true;
  List<PageInfo> get pages => _pages;

  var _maxSize = null;
  bool _rotate = true;

  calculatePages() {
    super.calculatePages();
    _pages = _getPages(currentPage, totalPages);
  }

  void render(value) {
    super.render(value);
    _pages = _getPages(currentPage, totalPages);
  }

  List<PageInfo> _getPages(int currentPage, int totalPages) {
    var pages = new List<PageInfo>();

    // Default page limits
    int startPage = 1, endPage = totalPages;
    bool isMaxSized = ( (_maxSize != null) && _maxSize < totalPages );

    // recompute if maxSize
    if ( isMaxSized ) {
      if ( _rotate ) {
        // Current page is displayed in the middle of the visible ones
        startPage = Math.max(currentPage - ((_maxSize/2).floor()), 1);
        endPage   = startPage + _maxSize - 1;

        // Adjust if limit is exceeded
        if (endPage > totalPages) {
          endPage   = totalPages;
          startPage = endPage - _maxSize + 1;
        }
      } else {
        // Visible pages are paginated with maxSize
        startPage = (((currentPage / _maxSize).ceil() - 1) * _maxSize) + 1;

        // Adjust last page if limit is exceeded
        endPage = Math.min(startPage + _maxSize - 1, totalPages);
      }
    }

    // Add page number links
    for (var number = startPage; number <= endPage; number++) {
      var page = new PageInfo(number, '$number', number == currentPage);
      pages.add(page);
    }

    // Add links to move between page sets
    if ( isMaxSized && ! _rotate ) {
      if ( startPage > 1 ) {
        var previousPageSet = new PageInfo(startPage - 1, '...', false);
        pages.insert(0, previousPageSet);
      }

      if ( endPage < totalPages ) {
        var nextPageSet = new PageInfo(endPage + 1, '...', false);
        pages.add(nextPageSet);
      }
    }

    return pages;
  }
}