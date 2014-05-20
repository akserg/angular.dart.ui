// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please seegriddropdown_toggle;
part of angular.ui.grid;

class Footer {
  Scope scope;
  dom.TableElement grid;
  
  Footer(this.scope, this.grid);
  
  /**
   * Create Foot element, global search and pager based on totalItemsCount from 
   * scope.
   * 
   * Scope variables:
   * columns
   * enableFiltering
   * itemsOnPage
   * search
   * pageCanGoBack
   * startItemIndex, endItemIndex, totalItemsCount
   * pageCanGoForward
   * navigatePrevPage
   * navigateNextPage
   */
  createFooter() {
    dom.TableSectionElement foot = grid.createTFoot();
    //
    dom.TableRowElement row = foot.addRow();
    //
    dom.TableCellElement cell = row.addCell()
    ..colSpan = scope.context['columns'].length;
    //
    dom.DivElement wrapper = new dom.DivElement()
    ..classes.add('sm-ng-grid-footer form-inline')
    ..attributes['sm-ng-grid-footer'];
    cell.append(wrapper);
    //
    dom.SpanElement filter = new dom.SpanElement()
    ..classes.add('pull-left form-group ng-scope ng-hide')
    ..attributes['sm-ng-grid-global-filter'] = '';
    scope.watch('enableFiltering', (value, old) {
      if (toBool(value)) {
        filter.classes.remove('ng-hide');
      } else {
        filter.classes.add('ng-hide');
      }
    });
    wrapper.append(filter);
    //
    dom.InputElement input;
    input = new dom.InputElement()
    ..classes.add('form-control ng-pristine ng-valid')
    ..type = 'text'
    ..placeholder = 'Search'
    ..onChange.listen((dom.Event evt) {
      scope.context['setSearch'](input.value);
    })
    ..onInput.listen((dom.Event evt) {
      scope.context['setSearch'](input.value);
    });
    filter.append(input);
    //
    dom.SpanElement pager = new dom.SpanElement()
    ..classes.add('pull-right form-group ng-scope')
    ..attributes['sm-ng-grid-pager'] = '';
    wrapper.append(pager);
    //
    dom.UListElement pagination = new dom.UListElement()
    ..classes.add('pagination');
    scope.watch('itemsOnPage', (value, old) {
      if (toInt(value) > 0) {
        pagination.classes.remove('ng-model');
      } else {
        pagination.classes.add('ng-model');
      }
    });
    pager.append(pagination);
    //
    dom.LIElement prev = new dom.LIElement();
    pagination.append(prev);
    dom.AnchorElement prevIcon = new dom.AnchorElement()
    ..href = '#'
    ..title = 'Previous Page'
    ..classes.add('ng-hide')
    ..setInnerHtml('&lArr;')
    ..onClick.listen((dom.MouseEvent evt) {
      evt.preventDefault();
      evt.stopPropagation();
      scope.context['navigatePrevPage']();
    });
    scope.watch('pageCanGoBack', (value, old) {
      if (toBool(value)) {
        prevIcon.classes.remove("ng-hide");
      } else {
        prevIcon.classes.add("ng-hide");
      }
    });
    prev.append(prevIcon);
    //
    dom.LIElement display = new dom.LIElement()
    ..classes.add('disabled')
    ..style.whiteSpace = 'nowrap';
    pagination.append(display);
    //
    dom.SpanElement itemsToDisplay = new dom.SpanElement()
    ..text = 'No items to display';
    scope.watch('[startItemIndex, endItemIndex, totalItemsCount]', (value, old) {
      if (scope.context['totalItemsCount'] == 0) {
        itemsToDisplay.text = 'No items to display';
      } else {
        itemsToDisplay.text = '${scope.context['startItemIndex'] + 1} - ${scope.context['endItemIndex'] + 1} displayed, ${scope.context['totalItemsCount']} in total';
      }
    }, collection:true);
    display.append(itemsToDisplay);
    //
    dom.LIElement next = new dom.LIElement();
    pagination.append(next);
    dom.AnchorElement nextIcon = new dom.AnchorElement()
    ..href = '#'
    ..title = 'Next Page'
    ..classes.add('ng-hide')
    ..setInnerHtml('&rArr;')
    ..onClick.listen((dom.MouseEvent evt) {
      evt.preventDefault();
      evt.stopPropagation();
      scope.context['navigateNextPage']();
    });
    scope.watch('pageCanGoForward', (value, old) {
      if (toBool(value)) {
        nextIcon.classes.remove("ng-hide");
      } else {
        nextIcon.classes.add("ng-hide");
      }
    });
    next.append(nextIcon);
  }
}