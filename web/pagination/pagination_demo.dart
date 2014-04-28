// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

/**
 * Pagination controller with template.
 */
@Controller(selector: '[pagination-ctrl]', publishAs: 'ctrl')
class PaginationController {

  int totalItems;
  int currentPage;
  int itemsPerPage;

  int totalPages;

  PaginationController() {
    totalItems = 54;
    currentPage = 2;
    itemsPerPage = 5;
  }

}