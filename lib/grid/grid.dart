// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please seegriddropdown_toggle;

import 'dart:html' as dom;
import 'dart:async' as async;
import "package:angular/angular.dart";
import "package:angular/core_dom/module_internal.dart";
import "package:angular_ui/utils/timeout.dart";

/**
 * Grid Module.
 */
class GridModule extends Module {
  GridModule() {
    install(new TimeoutModule());
    type(Grid);
  }
}

const tableDirective="trNgGrid";

const headerDirective="trNgGridHeader";
const headerDirectiveAttribute="tr-ng-grid-header";

const bodyDirective="trNgGridBody";
const bodyDirectiveAttribute="tr-ng-grid-body";

const footerDirective="trNgGridFooter";
const footerDirectiveAttribute="tr-ng-grid-footer";

const globalFilterDirective="trNgGridGlobalFilter";
const globalFilterDirectiveAttribute="tr-ng-grid-global-filter";

const pagerDirective="trNgGridPager";
const pagerDirectiveAttribute="tr-ng-grid-pager";

const columnDirective="trNgGridColumn";
const columnDirectiveAttribute="tr-ng-grid-column";

const sortDirective="trNgGridColumnSort";
const sortDirectiveAttribute="tr-ng-grid-column-sort";

const filterColumnDirective="trNgGridColumnFilter";
const filterColumnDirectiveAttribute="tr-ng-grid-column-filter";

const rowPageItemIndexAttribute="tr-ng-grid-row-page-item-index";

const tableCssClass="tr-ng-grid table table-bordered table-hover"; // at the time of coding, table-striped is not working properly with selection
const cellCssClass="tr-ng-cell";
const cellTitleSortCssClass="";
const titleCssClass="tr-ng-title";
const sortCssClass="tr-ng-sort";
const filterColumnCssClass="tr-ng-column-filter";
const filterInputWrapperCssClass="";
const sortActiveCssClass="tr-ng-sort-active";
const sortInactiveCssClass="tr-ng-sort-inactive";
const sortReverseCssClass="tr-ng-sort-reverse";
const selectedRowCssClass="active";

const footerOpsContainerCssClass="tr-ng-grid-footer form-inline";

class IGridColumnOptions{
  String fieldName;
  String displayName;
  String displayAlign;
  String displayFormat;
  bool enableSorting;
  bool enableFiltering;
  String cellWidth;
  String cellHeight;
}

class IGridOptions {
  List items;
  List selectedItems;
  String filterBy;
  var filterByFields;
  String orderBy;
  bool orderByReverse;
  int pageItems;
  int currentPage;
  int totalItems;
  bool enableFiltering;
  bool enableSorting;
  bool enableSelections;
  bool enableMultiRowSelections;
  var onDataRequired = (IGridOptions gridOptions) {};
  int onDataRequiredDelay;
  List<IGridColumnOptions> gridColumnDefs;
}

abstract class IGridColumnScope implements Scope {
  IGridColumnOptions currentGridColumnDef;
  IGridOptions gridOptions;
  var toggleSorting = (String propertyName) {};
  String filter;
}

abstract class IGridBodyScope implements Scope {
  IGridOptions gridOptions;
  var toggleItemSelection = (item) {};
}

abstract class IGridFooterScope implements Scope {
  IGridOptions gridOptions;
  bool isPaged;
  int totalItemsCount;
  int startItemIndex;
  int endItemIndex;
  bool pageCanGoBack;
  bool pageCanGoForward;
  var navigateNextPage = (dom.Event event) {};
  var navigatePrevPage = (dom.Event event) {};
}

abstract class IGridScope implements IGridOptions, Scope { }

class GridController {
  Scope externalScope;
  Scope internalScope;
  IGridOptions gridOptions;
  dom.Element _gridElement;
  Function _scheduledRecompilationDereg;
  async.Completer dataRequestPromise;
  
  Compiler _compile;
  IGridScope scope;
  NodeAttrs attrs;
  Parser _parse;
  Timeout _timeout;
  
  GridController(this._compile,
                 this.scope,
                 this._gridElement,
                 this.attrs,
                 this._parse,
                 this._timeout) {
    internalScope = scope;
    var scopeOptionsIdentifier = "gridOptions";
    
    // initialise the options
    gridOptions = new IGridOptions()
      ..items = []
      ..selectedItems = []
      ..filterBy = null
      ..filterByFields = {}
      ..orderBy = null
      ..orderByReverse = false
      ..pageItems = null
      ..currentPage = 0
      ..totalItems = null
      ..enableFiltering = true
      ..enableSorting = true
      ..enableSelections = true
      ..enableMultiRowSelections = true
      ..onDataRequiredDelay = 1000;
    
    gridOptions.onDataRequired = attrs.containsKey("on-data-required") ? scope.context['onDataRequired'] : null;
    gridOptions.gridColumnDefs = [];
    scope.context['scopeOptionsIdentifier'] = gridOptions;
    
    externalScope = internalScope.parentScope;
    
    // link the outer scope with the internal one
    linkScope(internalScope, scopeOptionsIdentifier, attrs);
    
    // set up watchers for some of the special attributes we support
    if (gridOptions.onDataRequired != null){
        scope.watch("[gridOptions.filterBy, gridOptions.filterByFields, gridOptions.orderBy, gridOptions.orderByReverse, gridOptions.currentPage]", (value, old) {

        if (dataRequestPromise != null) {
          _timeout.cancel(dataRequestPromise);
          dataRequestPromise = null;
        }

        // for the time being, Angular is not able to bind only when losing focus, so we'll introduce a delay
        dataRequestPromise = _timeout(() {
            dataRequestPromise = null;
            gridOptions.onDataRequired(gridOptions);
        }, delay:gridOptions.onDataRequiredDelay, invokeApply:true);
      });
    }
    
    internalScope.watch("enableMultiRowSelections", (bool newValue, bool oldValue) {
      if (newValue != oldValue && !newValue){
        if(gridOptions.selectedItems.length > 1){
          gridOptions.selectedItems.removeRange(1, gridOptions.selectedItems.length);
        }
      }
    });
    
    internalScope.watch("enableSelections", (bool newValue, bool oldValue) {
      if(newValue !=oldValue && !newValue){
        gridOptions.selectedItems.clear();
        gridOptions.enableMultiRowSelections = false;
      }
    });
  }
  
  setColumnOptions(int columnIndex, IGridColumnOptions columnOptions) {
    if(columnIndex >= gridOptions.gridColumnDefs.length){
      gridOptions.gridColumnDefs.add(new IGridColumnOptions());
      setColumnOptions(columnIndex, columnOptions);
    }
    else{
      gridOptions.gridColumnDefs[columnIndex] = columnOptions;
    }
  }
  
  toggleSorting(String propertyName) {
    if(gridOptions.orderBy != propertyName) {
      // the column has changed
      gridOptions.orderBy = propertyName;
    }
    else{
      // the sort direction has changed
      gridOptions.orderByReverse = !this.gridOptions.orderByReverse;
    }
  }
  
  setFilter(String propertyName, String filter){
    if (filter == null){
      delete(gridOptions.filterByFields[propertyName]);
    }
    else{
      gridOptions.filterByFields[propertyName] = filter;
    }

    // in order for someone to successfully listen to changes made to this object, we need to replace it
    //gridOptions.filterByFields = $.extend({}, gridOptions.filterByFields);
  }
  
  toggleItemSelection(item) {
    if(!gridOptions.enableSelections)
      return;

    var itemIndex = gridOptions.selectedItems.indexOf(item);
    if(itemIndex >= 0){
      gridOptions.selectedItems.removeAt(itemIndex);
    }
    else{
      if(!gridOptions.enableMultiRowSelections){
        gridOptions.selectedItems.clear();
      }
      gridOptions.selectedItems.add(item);
    }
  }
  
  scheduleRecompilationOnAvailableItems(){
    if(_scheduledRecompilationDereg != null || (gridOptions.items != null && this.gridOptions.items.length > 0))
      // already have one set up
      return;

    //_scheduledRecompilationDereg = 
    internalScope.watch("items.length", (int newLength, int oldLength) {
     if(newLength > 0){
       _scheduledRecompilationDereg();
       _compile(_gridElement)(externalScope);
     }
    });
  }
  
  linkScope(Scope scope, String scopeTargetIdentifier, NodeAttrs attrs) {
    // this method shouldn't even be here
    // but it is because we want to allow people to either set attributes with either a constant or a watchable variable

    // watch for a resolution to issue #5951 on angular
    // https://github.com/angular/angular.js/issues/5951

    var target = scope.context[scopeTargetIdentifier];

    for (var propName in target) {
      var attributeExists = attrs.containsKey(propName) && attrs[propName] != null; // typeof(attrs[propName])!="undefined" && attrs[propName]!=null;

      if (attributeExists) {
        var isArray = false;

        // initialise from the scope first
//        if(typeof(scope[propName])!="undefined" && scope[propName]!=null){
        if (scope.context[propName] != null) {
          target[propName] = scope.context[propName];
          isArray = target[propName] is List;
        }

        if (!isArray) {
          var compiledAttr = _parse(attrs[propName]);
          var dualDataBindingPossible = compiledAttr != null && compiledAttr is List && compiledAttr.assign; // typeof(compiledAttr)!="array" && compiledAttr && compiledAttr.assign; // very fragile, replace it as soon as possible
          if (dualDataBindingPossible) {
            ((String propName) {
              // set up one of the bindings
              scope.watch(scopeTargetIdentifier+"."+propName, (newValue, oldValue) {
                if (newValue != oldValue) {
                  scope.context[propName] = target[propName];
                }
              });

              // set up the other one
              scope.watch(propName, (newValue, oldValue) {
                if(newValue != oldValue){
                  target[propName] = scope.context[propName];
                }
              });
            })(propName);
          }
        }
      }
    }
  }
  
  splitByCamelCasing(String input) {
    RegExp r = new RegExp(r"(?=[A-Z])");
    var splitInput = r.allMatches(input); // input.split(/(?=[A-Z])/);
    if(splitInput.length > 0 && splitInput.first.length > 0){
      splitInput[0] = splitInput[0][0].toLocaleUpperCase()+splitInput[0].substr(1);
    }

    return splitInput.join(" ");
  }
}

@Directive(selector:"grid")
class Grid {
 
  // create an isolated scope, and remember the original scope can be found in the parent
//  scope: {
//       items:'=',
//       selectedItems:'=?',
//       filterBy:'=?',
//       filterByFields:'=?',
//       orderBy:'=?',
//       orderByReverse:'=?',
//       pageItems:'=?',
//       currentPage:'=?',
//       totalItems:'=?',
//       enableFiltering:'=?',
//       enableSorting:'=?',
//       enableSelections:'=?',
//       enableMultiRowSelections:'=?',
//       onDataRequired:'&',
//       onDataRequiredDelay:'=?'
//   }
                 
  Grid(dom.Element templateElement, NodeAttrs tAttrs) {
    templateElement.classes.add(tableCssClass);
    var insertFooterElement = false;
    var insertHeadElement = false;
    
    // make sure the header is present
    dom.Element tableHeadElement = templateElement.querySelector("thead");
    if (tableHeadElement == null) {
      tableHeadElement = new dom.Element.html("<thead>");
      insertHeadElement = true;
    }
    
    var tableHeadRowTemplate = tableHeadElement.querySelector("tr");
    if(tableHeadRowTemplate == null){
      tableHeadRowTemplate = new dom.Element.tr(); // $("<tr>").appendTo(tableHeadElement);
      tableHeadElement.append(tableHeadRowTemplate);
    }
    tableHeadRowTemplate.attributes[headerDirectiveAttribute] = "";
    // help a bit with the attributes
    tableHeadRowTemplate.querySelectorAll("th[field-name]").forEach((dom.Element el) {
      el.attributes[columnDirectiveAttribute] = "";
    });
    
    //discoverColumnDefinitionsFromUi(tableHeadRowTemplate);
    
    // make sure the body is present
    dom.Element tableBodyElement = templateElement.querySelector("tbody");
    if (tableBodyElement == null) {
      tableBodyElement = new dom.Element.html("<tbody>");
      templateElement.append(tableBodyElement);
    }
    
    dom.Element tableBodyRowTemplate = tableBodyElement.querySelector("tr");
    if (tableBodyRowTemplate == null) {
      tableBodyRowTemplate = new dom.Element.tr(); //$("<tr>").appendTo(tableBodyElement);
      tableBodyElement.append(tableBodyRowTemplate);
    }
    tableBodyElement.attributes[bodyDirectiveAttribute] = "";
    
    // make sure the footer is present
    dom.Element tableFooterElement = templateElement.querySelector("tfoot");
    if (tableFooterElement == null) {
      tableFooterElement = new dom.Element.html("<tfoot>"); // $("<tfoot>");
      insertFooterElement = true;
    }
    
    var tableFooterRowTemplate = tableFooterElement.querySelector("tr");
    if(tableFooterRowTemplate == null){
      tableFooterRowTemplate = new dom.Element.tr(); // $("<tr>").appendTo(tableFooterElement);
      tableFooterElement.append(tableFooterRowTemplate);
    }
    if(tableFooterRowTemplate.querySelectorAll("td").length == 0){
      dom.Element fullTableLengthFooterCell = new dom.Element.td() // $("<td>")
      ..attributes["colspan"] = "999"; //TODO: fix this hack
      tableFooterRowTemplate.append(fullTableLengthFooterCell);

      dom.Element footerOpsContainer = new dom.Element.div() //$("<div>")
      ..attributes[footerDirectiveAttribute] = "";
      fullTableLengthFooterCell.append(footerOpsContainer);
    }

    if(insertHeadElement){
      tableHeadElement.insertAdjacentElement("beforeBegin", templateElement);
      //templateElement.prepend(tableHeadElement);
    }

    if(insertFooterElement){
      tableFooterElement.insertBefore(tableBodyElement);
    }
  }
}