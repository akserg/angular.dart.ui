// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.pagination;

import 'dart:math' as Math;

import 'package:angular/angular.dart';

import "package:angular_ui/utils/utils.dart";

class PaginationModule extends Module {

  PaginationModule() {
    bind(PagerConfig, toValue:new PagerConfig(10, '« Previous', 'Next »', true));
    bind(PagerComponent);
    bind(PaginationConfig, toValue:new PaginationConfig(10, false, true, 'First', 'Previous', 'Next', 'Last', true));
    bind(PaginationComponent);
    bind(PaginationGenerator, toValue: new BasicPaginationGenerator());
  }
}

@Injectable()
class PagerConfig {
  int itemsPerPage;
  String previousText;
  String nextText;
  bool align;

  PagerConfig(this.itemsPerPage, this.previousText, this.nextText, this.align);
}

@Component(
    selector: 'pager[page][total-items]',
    //templateUrl: 'packages/angular_ui/pagination/pager.html',
    template: '''
<ul class="pager">
  <li ng-class="{disabled: noPrevious, previous : align}"><a ng-click="selectPage(currentPage - 1)">{{previousText}}</a></li>
  <li ng-class="{disabled: noNext, next : align}"><a ng-click="selectPage(currentPage + 1)">{{nextText}}</a></li>
</ul>''',
    useShadowDom: false,
    map: const {
      'page': '<=>currentPage',
      'total-items' : '=>totalItems',
      'items-per-page' : '=>itemsPerPage',
      'num-pages': '&setNumPagesListener',
      'on-select-page': '&onSelectChangeExtEventHandler',
      'align': '@align',
      'previous-text': '@previousText',
      'next-text': '@nextText'
    }
)
//@Component(
//    selector: '[pager][page][total-items]',
//    //templateUrl: 'packages/angular_ui/pagination/pager.html',
//    template: '''
//<ul class="pager">
//  <li ng-class="{disabled: noPrevious, previous : align}"><a ng-click="selectPage(currentPage - 1)">{{previousText}}</a></li>
//  <li ng-class="{disabled: noNext, next : align}"><a ng-click="selectPage(currentPage + 1)">{{nextText}}</a></li>
//</ul>''',
//    useShadowDom: false,
//    map: const {
//      'page': '<=>currentPage',
//      'total-items' : '=>totalItems',
//      'items-per-page' : '=>itemsPerPage',
//      'num-pages': '&setNumPagesListener',
//      'on-select-page': '&onSelectChangeExtEventHandler',
//      'align': '@align',
//      'previous-text': '@previousText',
//      'next-text': '@nextText'
//    }
//)
class PagerComponent implements ScopeAware {
  // Paging always starts with 1st page.
  static const int DEFAULT_FIRST_PAGE = 1;

  Scope scope;
  final PagerConfig pagerConfig;

  // Bound attributes
  //!!! BoundExpression onSelectChangeExtEventHandler;
  var onSelectChangeExtEventHandler;

  // Bound attributes store fields
  int _currentPage;
  int _itemsPerPage;
  //!!! BoundExpression _setNumPagesListener;
  var _setNumPagesListener;
  int _totalItems;
  bool _align;
  String _previousText;
  String _nextText;

  // Computed Fields
  int _totalPages;


  PagerComponent(this.pagerConfig) {
    // By default there is one page
    _currentPage = DEFAULT_FIRST_PAGE;
    _totalPages = DEFAULT_FIRST_PAGE;

    // load default config
    _itemsPerPage = pagerConfig.itemsPerPage;
    _align = pagerConfig.align;
    _previousText = pagerConfig.previousText;
    _nextText = pagerConfig.nextText;
  }

  int get currentPage => _currentPage;

  set currentPage(value) {
    var newIntValue;
    try {
      newIntValue = toInt(value);
    } catch(FormatException){
      newIntValue = 1;
    }
    if(_currentPage != newIntValue) {
      _currentPage = newIntValue;
      generatePages(_currentPage, _totalPages);
    }
  }

  set totalItems(int value) {
    var newIntValue = value == null? 0 : value;
    if(_totalItems != newIntValue) {
      _totalItems = newIntValue;
      _reevaluateTotalPages();
    }
  }

  set itemsPerPage(int value) {
    if(_itemsPerPage != value) {
      _itemsPerPage = value;
      _reevaluateTotalPages();
    }
  }

  set setNumPagesListener(value) {
    _setNumPagesListener = value;

    _invokeNumPagesListener(_totalPages);
  }

  bool get noPrevious => currentPage <= DEFAULT_FIRST_PAGE;
  bool get noNext => currentPage >= _totalPages;

  String get previousText => _previousText;
  set previousText(String value) => _previousText = (value == null? pagerConfig.previousText : value);

  String get nextText => _nextText;
  set nextText(String value) => _nextText = (value == null? pagerConfig.nextText : value);

  bool get align => _align;
  set align(value) => _align = (value == null? pagerConfig.align : toBool(value));

  int get totalPages => _totalPages;

  void selectPage(int newPage) {
    if((newPage >= DEFAULT_FIRST_PAGE) &&(newPage <= _totalPages)) {
      scope.apply(() => currentPage = newPage);

      if (onSelectChangeExtEventHandler != null) {
        onSelectChangeExtEventHandler();
      }
    }
  }

  // Do nothing on currentPageChange
  generatePages(int currentPage, int totalPages) => null;

  int _calculateTotalPages(int totalItems, int itemsPerPage) {
    var totalPages = (totalItems / itemsPerPage).ceil();
    return Math.max(totalPages, 1);
  }

  void _reevaluateTotalPages() {
    _totalPages = _calculateTotalPages(_totalItems, _itemsPerPage);
    _invokeNumPagesListener(_totalPages);
    _validateCurrentPage();
    generatePages(currentPage, _totalPages);
  }

  void _validateCurrentPage() {
    if(currentPage > _totalPages) {
      currentPage = _totalPages;
    }
  }

  void _invokeNumPagesListener(int totalPages) {
    if(_setNumPagesListener != null && _setNumPagesListener.expression.isAssignable) {
      _setNumPagesListener.assign(totalPages);
    }
  }
}

@Injectable()
class PaginationConfig extends PagerConfig {
  bool boundaryLinks;
  bool directionLinks;
  String firstText;
  String lastText;

  int maxSize;

  PaginationConfig(int itemsPerPage, this.boundaryLinks, this.directionLinks, this.firstText, String previousText, String nextText, this.lastText, bool align) :super(itemsPerPage, previousText, nextText, align);
}

@Component(
    selector: 'pagination[page][total-items]',
    //templateUrl: 'packages/angular_ui/pagination/pagination.html',
    template: '''
<ul class="pagination">
  <li ng-if="boundaryLinks" ng-class="{disabled: noPrevious}"><a ng-click="selectPage(1)">{{firstText}}</a></li>
  <li ng-if="directionLinks" ng-class="{disabled: noPrevious}"><a ng-click="selectPage(currentPage - 1)">{{previousText}}</a></li>
  <li ng-repeat="page in pages" ng-class="{active: page.isActive}"><a ng-click="selectPage(page.number)">{{page.text}}</a></li>
  <li ng-if="directionLinks" ng-class="{disabled: noNext}"><a ng-click="selectPage(currentPage + 1)">{{nextText}}</a></li>
  <li ng-if="boundaryLinks" ng-class="{disabled: noNext}"><a ng-click="selectPage(totalPages)">{{lastText}}</a></li>
</ul>''',
    useShadowDom: false,
    map: const {
        'page': '<=>currentPage',
        'total-items': '=>totalItems',
        'items-per-page': '=>itemsPerPage',
        'max-size': '=>maxSize',
        'rotate': '=>rotate',
        'num-pages': '&setNumPagesListener',
        'on-select-page': '&onSelectChangeExtEventHandler',
        'boundary-links': '=>boundaryLinks',
        'direction-links': '=>directionLinks',
        'align': '@align',
        'previous-text': '@previousText',
        'next-text': '@nextText',
        'first-text': '@firstText',
        'last-text': '@lastText'
    }
)
//@Component(
//    selector: '[pagination][page][total-items]',
//    templateUrl: 'packages/angular_ui/pagination/pagination.html',
//    useShadowDom: false,
//    map: const {
//        'page': '<=>currentPage',
//        'total-items': '=>totalItems',
//        'items-per-page': '=>itemsPerPage',
//        'max-size': '=>maxSize',
//        'rotate': '=>rotate',
//        'num-pages': '&setNumPagesListener',
//        'on-select-page': '&onSelectChangeExtEventHandler',
//        'boundary-links': '=>boundaryLinks',
//        'direction-links': '=>directionLinks',
//        'align': '@align',
//        'previous-text': '@previousText',
//        'next-text': '@nextText',
//        'first-text': '@firstText',
//        'last-text': '@lastText'
//    }
//)
class PaginationComponent extends PagerComponent {

  PaginationConfig paginationConfig;
  PaginationGenerator paginationGenerator;

  // Bound attributes
  bool boundaryLinks;
  bool directionLinks;
  List<PageInfo> pages;
  String _firstText;
  String _lastText;

  // Bound attributes store fields
  int _maxSize;
  bool _rotate;


  PaginationComponent(PaginationConfig paginationConfig, this.paginationGenerator): super(paginationConfig) {
    _rotate = true;
    this.paginationConfig = paginationConfig;

    // config
    boundaryLinks = paginationConfig.boundaryLinks;
    directionLinks = paginationConfig.directionLinks;
    _firstText = paginationConfig.firstText;
    _lastText = paginationConfig.nextText;
    _maxSize = paginationConfig.maxSize;
  }

  int get maxSize => _maxSize;
  set maxSize(int value) {
    _maxSize = value;
    _generatePages(currentPage, totalPages, maxSize, rotate);
  }

  bool get rotate => _rotate;
  set rotate(bool value) {
    _rotate = value;
    _generatePages(currentPage, totalPages, maxSize, rotate);
  }

  String get firstText => _firstText;
  set firstText(String value) => _firstText = (value == null? paginationConfig.firstText : value);

  String get lastText => _lastText;
  set lastText(String value) => _lastText = (value == null? paginationConfig.lastText : value);

  generatePages(int currentPage, int totalPages) => _generatePages(currentPage, totalPages, maxSize, rotate);

  _generatePages(int currentPage, int totalPages, int maxSize, bool rotate) => pages = paginationGenerator.getPages(currentPage, totalPages, maxSize, rotate);

}

@Injectable()
class PageInfo {
  int number;
  String text;
  bool isActive;

  PageInfo(this.number, this.text, this.isActive);
}


abstract class PaginationGenerator {
  List<PageInfo> getPages(int currentPage, int totalPages, int maxSize, bool rotate);
  
  factory PaginationGenerator() {
    return new BasicPaginationGenerator();
  }
}

@Injectable()
class BasicPaginationGenerator implements PaginationGenerator {

  List<PageInfo> getPages(int currentPage, int totalPages, int maxSize, bool rotate) {
    var pages = new List<PageInfo>();

    // Default page limits
    int startPage = 1, endPage = totalPages;
    bool isMaxSized = ( (maxSize != null) && maxSize < totalPages );

    // recompute if maxSize
    if ( isMaxSized ) {
      if ( rotate ) {
        // Current page is displayed in the middle of the visible ones
        startPage = Math.max(currentPage - ((maxSize/2).floor()), 1);
        endPage   = startPage + maxSize - 1;

        // Adjust if limit is exceeded
        if (endPage > totalPages) {
          endPage   = totalPages;
          startPage = endPage - maxSize + 1;
        }
      } else {
        // Visible pages are paginated with maxSize
        startPage = maxSize == 0? 0 : ((((currentPage / maxSize).ceil() - 1) * maxSize) + 1);

        // Adjust last page if limit is exceeded
        endPage = Math.min(startPage + maxSize - 1, totalPages);
      }
    }

    // Add page number links
    for (var number = startPage; number <= endPage; number++) {
      var page = new PageInfo(number, '$number', number == currentPage);
      pages.add(page);
    }

    // Add links to move between page sets
    if ( isMaxSized && ! rotate ) {
      if ( startPage > 1 ) {
        var previousPageSet = new PageInfo(startPage - 1, '...', false);
        pages.insert(0, previousPageSet);
      }

      if ( (endPage > 1) && (endPage < totalPages) ) {
        var nextPageSet = new PageInfo(endPage + 1, '...', false);
        pages.add(nextPageSet);
      }
    }

    return pages;
  }
}