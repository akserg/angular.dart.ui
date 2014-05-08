// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please seegriddropdown_toggle;

import 'dart:html' as dom;
import 'dart:async' as async;
import "package:angular/angular.dart";
import "package:angular/core_dom/module_internal.dart";
import "package:angular_ui/utils/timeout.dart";
import "package:angular_ui/utils/utils.dart";

/**
 * Grid Module.
 */
class GridModule extends Module {
  GridModule() {
    install(new TimeoutModule());
    type(Grid);
    type(GridHeader);
    type(GridColumn);
    type(GridSort);
    type(GridColumnFilter);
    type(PagingFilter);
    type(GridBody);
    type(GridFooter);
    type(GridGlobalFilter);
    type(GridPager);
  }
}

const tableDirective="tr-ng-grid";

const headerDirective="tr-ng-grid-header";

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
  Map filterByFields;
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

//abstract class IGridScope implements IGridOptions, Scope { }

class GridController {
  
  Scope externalScope;
  Scope internalScope;
  IGridOptions gridOptions;
  dom.Element _gridElement;
  Function _scheduledRecompilationDereg;
  async.Completer dataRequestPromise;

  Injector _injector;
  Compiler _compiler;
  
  Scope scope;
  NodeAttrs _attrs;
  Parser _parse;
  Timeout _timeout;
  
  GridController(this._compiler, this.scope, this._gridElement, this._attrs, this._parse, this._timeout, this._injector) {
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
    
    gridOptions.onDataRequired = _attrs.containsKey("on-data-required") ? scope.context['onDataRequired'] : null;
    gridOptions.gridColumnDefs = [];
    scope.context[scopeOptionsIdentifier] = gridOptions;
    
    externalScope = internalScope.parentScope;
    
    // link the outer scope with the internal one
//    linkScope(internalScope, scopeOptionsIdentifier, _attrs);

    if (_attrs.containsKey('items')) {
      if (internalScope.context['items'] != null) {
        gridOptions.items = internalScope.context['items'];
      }
    }
    
    // set up watchers for some of the special attributes we support
    if (gridOptions.onDataRequired != null) {
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
      if (newValue != oldValue && !newValue ){
        if(gridOptions.selectedItems.length > 1){
          gridOptions.selectedItems.removeRange(1, gridOptions.selectedItems.length);
        }
      }
    });
    
    internalScope.watch("enableSelections", (bool newValue, bool oldValue) {
      if (newValue != oldValue && !newValue) {
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
      //delete(gridOptions.filterByFields[propertyName]);
      if (gridOptions.filterByFields.containsKey(propertyName)) {
        gridOptions.filterByFields.remove(propertyName);
      }
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
       //_compile(_gridElement)(externalScope);
       compile(_gridElement, _injector, _compiler, scope:externalScope);
     }
    });
  }
  
  linkScope(Scope scope, String scopeTargetIdentifier, NodeAttrs attrs) {
    IGridOptions target = scope.context[scopeTargetIdentifier];
    bindProperty(target.items, 'items', scope, scopeTargetIdentifier, attrs);
  }
  
  void bindProperty(target, String propName, Scope scope, String scopeTargetIdentifier, NodeAttrs attrs) {
    var attributeExists = attrs.containsKey(propName) && attrs[propName] != null; // typeof(attrs[propName])!="undefined" && attrs[propName]!=null;

    if (attributeExists) {
      var isArray = false;

      // initialise from the scope first
      if (scope.context[propName] != null) {
        target = scope.context[propName];
        isArray = target is List;
      }

      if (!isArray) {
        var compiledAttr = _parse(attrs[propName]);
        var dualDataBindingPossible = compiledAttr != null && compiledAttr.isAssignable && compiledAttr is! List; // && compiledAttr.assign; // typeof(compiledAttr)!="array" && compiledAttr && compiledAttr.assign; // very fragile, replace it as soon as possible
        if (dualDataBindingPossible) {
          ((String propName) {
            // set up one of the bindings
            scope.watch(scopeTargetIdentifier + "." + propName, (newValue, oldValue) {
              if (newValue != oldValue) {
                scope.context[propName] = target;
              }
            });

            // set up the other one
            scope.watch(propName, (newValue, oldValue) {
              if (newValue != oldValue) {
                target = scope.context[propName];
              }
            });
          })(propName);
        }
      }
  }    
//    
//    
//                                
//                                
//                                
//    ..items = []
//    ..selectedItems = []
//    ..filterBy = null
//    ..filterByFields = {}
//    ..orderBy = null
//    ..orderByReverse = false
//    ..pageItems = null
//    ..currentPage = 0
//    ..totalItems = null
//    ..enableFiltering = true
//    ..enableSorting = true
//    ..enableSelections = true
//    ..enableMultiRowSelections = true
//    ..onDataRequiredDelay = 1000;
//    
    
//    // this method shouldn't even be here
//    // but it is because we want to allow people to either set attributes with either a constant or a watchable variable
//
//    // watch for a resolution to issue #5951 on angular
//    // https://github.com/angular/angular.js/issues/5951
//
//    var target = scope.context[scopeTargetIdentifier];
//
//    for (var propName in target) {
//      var attributeExists = attrs.containsKey(propName) && attrs[propName] != null; // typeof(attrs[propName])!="undefined" && attrs[propName]!=null;
//
//      if (attributeExists) {
//        var isArray = false;
//
//        // initialise from the scope first
////        if(typeof(scope[propName])!="undefined" && scope[propName]!=null){
//        if (scope.context[propName] != null) {
//          target[propName] = scope.context[propName];
//          isArray = target[propName] is List;
//        }
//
//        if (!isArray) {
//          var compiledAttr = _parse(attrs[propName]);
//          var dualDataBindingPossible = compiledAttr != null && compiledAttr is List && compiledAttr.assign; // typeof(compiledAttr)!="array" && compiledAttr && compiledAttr.assign; // very fragile, replace it as soon as possible
//          if (dualDataBindingPossible) {
//            ((String propName) {
//              // set up one of the bindings
//              scope.watch(scopeTargetIdentifier+"."+propName, (newValue, oldValue) {
//                if (newValue != oldValue) {
//                  scope.context[propName] = target[propName];
//                }
//              });
//
//              // set up the other one
//              scope.watch(propName, (newValue, oldValue) {
//                if(newValue != oldValue){
//                  target[propName] = scope.context[propName];
//                }
//              });
//            })(propName);
//          }
//        }
//      }
//    }
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

@Decorator(selector:"table[$tableDirective]")
class Grid extends GridController {

//  GridController _controller;
  
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
  
  Grid(dom.Element gridElement, NodeAttrs attrs, Compiler compiler, Scope scope, Parser parse, Timeout timeout, Injector injector) : 
    super (compiler, scope, gridElement, attrs, parse, timeout, injector) {
    
    dom.TableElement templateElement = gridElement as dom.TableElement;
    templateElement.classes.add(tableCssClass);
    
    // make sure the header is present
    dom.TableSectionElement tableHeadElement = templateElement.querySelector("thead");
    if (tableHeadElement == null) {
      tableHeadElement = templateElement.createTHead();
    }
    
    dom.TableRowElement tableHeadRowTemplate = tableHeadElement.querySelector("tr");
    if (tableHeadRowTemplate == null){
      tableHeadRowTemplate = tableHeadElement.addRow();
    }
    tableHeadRowTemplate.attributes[headerDirective] = "";
    // help a bit with the attributes
    tableHeadRowTemplate.querySelectorAll("th[field-name]").forEach((dom.Element el) {
      el.attributes[columnDirectiveAttribute] = "";
    });

    // make sure the footer is present
    dom.TableSectionElement tableFooterElement = templateElement.querySelector("tfoot");
    if (tableFooterElement == null) {
      tableFooterElement = templateElement.createTFoot();
    }
    
    dom.TableRowElement tableFooterRowTemplate = tableFooterElement.querySelector("tr");
    if (tableFooterRowTemplate == null) {
      tableFooterRowTemplate = tableFooterElement.addRow();
    }
    if (tableFooterRowTemplate.querySelectorAll("td").length == 0) {
      dom.TableCellElement fullTableLengthFooterCell = tableFooterRowTemplate.addCell() 
      ..attributes["colspan"] = "999"; //TODO: fix this hack

      dom.DivElement footerOpsContainer = new dom.DivElement() //$("<div>")
      ..attributes[footerDirectiveAttribute] = "";
      fullTableLengthFooterCell.append(footerOpsContainer);
    }

    // make sure the body is present
    dom.TableSectionElement tableBodyElement = templateElement.querySelector("tbody");
    if (tableBodyElement == null) {
      tableBodyElement = templateElement.createTBody();
    }
    
    dom.TableRowElement tableBodyRowTemplate = tableBodyElement.querySelector("tr");
    if (tableBodyRowTemplate == null) {
      tableBodyRowTemplate = tableBodyElement.addRow();
    }
    tableBodyElement.attributes[bodyDirectiveAttribute] = "";
  }
}

@Decorator(selector:"[$headerDirective]")
class GridHeader {
  
  Scope _scope;
  dom.Element _element;
  NodeAttrs _attrs;
  Grid _controller;
  
  Injector _injector;
  Compiler _compiler;
  
  GridHeader(this._scope, this._element, this._attrs, this._controller, this._injector, this._compiler) {
    // deal with the situation where no column definition exists on the th elements in the table
    if (_element.querySelectorAll("th").length == 0) {
      if (_controller.gridOptions.items != null && _controller.gridOptions.items.length > 0) {
        // no columns defined for the header, attempt to identify the properties and populate the columns definition
        for (var propName in _controller.gridOptions.items){
          // exclude the library properties
          RegExp libProps = new RegExp(r"^[_\$]");
          //if (!propName.match(/^[_\$]/g)) {
          if (libProps.hasMatch(propName)) {
            // create the th definition and add the column directive, serialised
            //var headerCellElement = $("<th>").attr(columnDirectiveAttribute, "").attr("field-name", propName).appendTo(_element);
            dom.TableCellElement headerCellElement = new dom.TableCellElement()
            ..attributes[columnDirectiveAttribute] = ""
            ..attributes["field-name"] = propName;
            _element.append(headerCellElement);
            //$compile(headerCellElement)(scope);
            compile(headerCellElement, _injector, _compiler, scope:_scope);
          }
        }
      }
      else
      {
        // watch for items to arrive and re-run the compilation then
        _controller.scheduleRecompilationOnAvailableItems();
      }
    }
  }
}

@Decorator(selector:"[$columnDirective]")
class GridColumn implements AttachAware {
  int columnIndex;

  Scope _scope;
  dom.Element _element;
  NodeAttrs _attrs;
  Grid _controller;
  
  Injector _injector;
  Compiler _compiler;
  
  GridColumn(this._scope, this._element, this._attrs, this._controller, this._injector, this._compiler) {
    var isValid = _element.tagName == "TH";
    if(!isValid){
        throw "The template has an invalid header column template element. Column templates must be defined on TH elements inside THEAD/TR";
    }

    // set up the scope for the column inside the header
    // the directive can be present on the header's td elements but also on the body's elements but we extract column information from the header only
    columnIndex = _element.parent.querySelectorAll("th").indexOf(_element);
    if (columnIndex < 0) {
        return;
    }
    
    _scope.context['.gridOptions'] = _controller.gridOptions;
    _scope.context['.toggleSorting'] = (propertyName) { 
      _controller.toggleSorting(propertyName);
    };
    _scope.context['.filter'] = "";
    _scope.watch("filter", (String newValue, String oldValue) {
      if (newValue != oldValue) {
        _controller.setFilter(_scope.context['currentGridColumnDef'].fieldName, newValue);
      }
    });

    // prepare the child scope
    var columnDefSetup = () {
        _scope.context['.currentGridColumnDef'].fieldName = _attrs["fieldName"];
        // typeof (_attrs["displayName"]) == "undefined" ? _controller.splitByCamelCasing(_attrs["fieldName"]) : _attrs["displayName"];
        _scope.context['.currentGridColumnDef'].displayName = _attrs.containsKey("displayName") ? _attrs["displayName"] : _controller.splitByCamelCasing(_attrs["fieldName"]);
        // _attrs["enableFiltering"] == "true" || (typeof(_attrs["enableFiltering"])=="undefined" && _scope.context['.gridOptions.enableFiltering);
        _scope.context['.currentGridColumnDef'].enableFiltering = _attrs["enableFiltering"] == "true" || (!_attrs.containsKey("enableFiltering") && _scope.context['gridOptions'].enableFiltering);
        // _attrs["enableSorting"]=="true" || (typeof(_attrs["enableSorting"])=="undefined" && _scope.context['gridOptions'].enableSorting);
        _scope.context['.currentGridColumnDef'].enableSorting = _attrs["enableSorting"] == "true" || (!_attrs.containsKey("enableSorting") && _scope.context['gridOptions'].enableSorting);
        _scope.context['.currentGridColumnDef'].displayAlign = _attrs["displayAlign"];
        _scope.context['.currentGridColumnDef'].displayFormat = _attrs["displayFormat"];
        _scope.context['.currentGridColumnDef'].cellWidth = _attrs["cellWidth"];
        _scope.context['.currentGridColumnDef'].cellHeight = _attrs["cellHeight"];
    };

    _scope.context['currentGridColumnDef'] = new IGridColumnOptions();
    columnDefSetup();

    _scope.watch("[gridOptions.enableFiltering,gridOptions.enableSorting]", (bool newValue, bool oldValue) {
      columnDefSetup();
    });
    _controller.setColumnOptions(columnIndex, _scope.context['currentGridColumnDef']);
    _element.attributes.remove(columnDirectiveAttribute);
  }
  
  void attach() {
    // we're sure we're inside the header
    if(_scope.context['currentGridColumnDef']){
      if(!_scope.context['currentGridColumnDef'].fieldName){
          throw "The column definition for trNgGrid must contain the field name";
      }

      if (_scope.context['currentGridColumnDef'].cellWidth) {
          _element.style.width = _scope.context['currentGridColumnDef'].cellWidth;
      }
      if (_scope.context['currentGridColumnDef'].cellHeight) {
          _element.style.height = _scope.context['currentGridColumnDef'].cellHeight;
      }

      if (_element.text == "") {
        //prepopulate
        var cellContentsElement = new dom.DivElement()
        ..classes.add(cellCssClass);

        var cellContentsTitleSortElement = new dom.DivElement()
        ..classes.add(cellTitleSortCssClass);
        cellContentsElement.append(cellContentsTitleSortElement);

        // the column title was not specified, attempt to include it and recompile
        var cellTitleElement = new dom.DivElement()
        ..classes.add(titleCssClass)
        ..text = _scope.context['currentGridColumnDef'].displayName;
        cellContentsTitleSortElement.append(cellTitleElement);

        var cellSortTitleElement = new dom.DivElement()
        ..attributes[sortDirectiveAttribute] = "";
        cellContentsTitleSortElement.append(cellSortTitleElement);

        var cellFilterTitleElement = new dom.DivElement()
        ..attributes[filterColumnDirectiveAttribute] = "";
        cellContentsElement.append(cellFilterTitleElement);

        //_element.append(cellContentsElement);

        // pass the outside scope
        var newCellContentsElement = compile(cellContentsElement, _injector, _compiler, scope:_scope);
        _element.append(newCellContentsElement);
      }
    }
  }
}

@Component(selector:"[$sortDirective]", 
    useShadowDom:false,
    template: """<div ng-show='currentGridColumnDef.enableSorting' ng-click='toggleSorting(currentGridColumnDef.fieldName)' title='Sort' class='$sortCssClass'>
<div ng-class=\"{'$sortActiveCssClass':gridOptions.orderBy==currentGridColumnDef.fieldName,'$sortInactiveCssClass':gridOptions.orderBy!=currentGridColumnDef.fieldName,'$sortReverseCssClass':gridOptions.orderByReverse}\">
</div>
</div>""")
class GridSort {
}

@Component(selector:"[$filterColumnDirective]", 
    useShadowDom:false,
    template: """<div ng-show='currentGridColumnDef.enableFiltering' class='$filterColumnCssClass'>
<div class='$filterInputWrapperCssClass'>
<input class='form-control input-sm' type='text' ng-model='filter'/>
</div>
</div>
""")
class GridColumnFilter {
}

@Formatter(name: 'paging')
class PagingFilter implements Function {
  call(List input, IGridOptions gridOptions) {
    //currentPage?:number, pageItems?:number
    if (input != null) {
      gridOptions.totalItems = input.length;
    }
    
    if (gridOptions.pageItems == null || input == null || input.length == 0) {
      return input;
    }
    
    if (gridOptions.currentPage == null) {
        gridOptions.currentPage = 0;
    }

    var startIndex = gridOptions.currentPage * gridOptions.pageItems;
    if (startIndex >= input.length) {
        gridOptions.currentPage = 0;
        startIndex = 0;
    }
    var endIndex = gridOptions.currentPage * gridOptions.pageItems + gridOptions.pageItems;

/*              
  // Update: Not called for server-side paging
  if(startIndex>=input.length){
    // server side paging, ignore the operation
    return input;
  }
*/
    return input.getRange(startIndex, endIndex);
  }
}

@Decorator(selector:"[$bodyDirective]")
class GridBody implements AttachAware {
 
  dom.Element bodyTemplateRow;
  
  Scope _scope;
  dom.Element _element;
  NodeAttrs _attrs;
  Grid _controller;
  
  Injector _injector;
  Compiler _compiler;
  
  
  GridBody(this._scope, this._element, this._attrs, this._controller, this._injector, this._compiler) {
    
    // we cannot allow angular to use the body row template just yet
    bodyTemplateRow = _element.querySelector("tr");
    _element.children.clear(); //contents().remove();
  }
  
  void attach() {
    // set up the scope
    _scope.context['gridOptions'] = _controller.gridOptions;
    _scope.context['toggleItemSelection'] = (item) { 
      _controller.toggleItemSelection(item);
    };

    // find the body row template, which was initially excluded from the compilation
    // apply the ng-repeat
    var ngRepeatAttrValue = "gridItem in gridOptions.items";
    if(_scope.context['gridOptions'].onDataRequired){
        // data is retrieved externally, watchers set up in the controller take care of calling this method
    }
    else{
        // the grid's internal mechanisms are active
        ngRepeatAttrValue += " | filter:gridOptions.filterBy | filter:gridOptions.filterByFields | orderBy:gridOptions.orderBy:gridOptions.orderByReverse | paging:gridOptions";
    }

    bodyTemplateRow.attributes["ng-repeat"] = ngRepeatAttrValue;
    if (!bodyTemplateRow.attributes.containsKey("ng-click")){
      bodyTemplateRow.attributes["ng-click"] = "toggleItemSelection(gridItem)";
    }
    bodyTemplateRow.attributes["ng-class"] = "{'$selectedRowCssClass':gridOptions.selectedItems.indexOf(gridItem)>=0}";

    bodyTemplateRow.attributes[rowPageItemIndexAttribute] = r"{{$index}}";
    for (int index = 0; index < _scope.context['gridOptions'].gridColumnDefs.length; index++ ) {
      IGridColumnOptions columnOptions = _scope.context['gridOptions'].gridColumnDefs[index];
        dom.Element cellTemplateElement = bodyTemplateRow.querySelector("td:nth-child(${index+1})");
        String cellTemplateFieldName = cellTemplateElement.attributes["field-name"]; // cellTemplateElement.is("[" + columnDirectiveAttribute + "]");
        bool createInnerCellContents = false;

        if (cellTemplateFieldName != columnOptions.fieldName) {
            // inconsistencies between column definition and body cell template
            createInnerCellContents = true;

            var newCellTemplateElement = new dom.DivElement();
//            if (cellTemplateElement.length == 0)
//                bodyTemplateRow.append(newCellTemplateElement);
//            else
//                cellTemplateElement.insert(0, newCellTemplateElement);
            
            bodyTemplateRow.append(newCellTemplateElement);

            cellTemplateElement = newCellTemplateElement;
        }
        else {
            // create the content if the td had no children
            createInnerCellContents = (cellTemplateElement.text == "");
        }

        if (createInnerCellContents) {
            var cellContentsElement = new dom.DivElement()
            ..classes.add(cellCssClass);
            if (columnOptions.fieldName != null) {
                // according to the column options, a model bound cell is needed here
                cellContentsElement.attributes["field-name"] = columnOptions.fieldName;
                var cellContentsElementText = "{{gridItem.${columnOptions.fieldName}";
                if (columnOptions.displayFormat != null) {
                    // add the display filter
                    if (columnOptions.displayFormat.codeUnitAt(0) != '|' && columnOptions.displayFormat.codeUnitAt(0) != '.') {
                        cellContentsElementText += " | "; // assume an angular filter by default
                    }
                    cellContentsElementText += columnOptions.displayFormat;
                }
                cellContentsElementText += "}}";
                cellContentsElement.text = cellContentsElementText;
            }
            else {
                cellContentsElement.text = "Invalid column match inside the table body";
            }

            cellTemplateElement.append(cellContentsElement);
        }

        if (columnOptions.displayAlign != null) {
            cellTemplateElement.classes.add("text-${columnOptions.displayAlign}");
        }
        if (columnOptions.cellWidth != null) {
            cellTemplateElement.style.width = columnOptions.cellWidth;
        }
        if (columnOptions.cellHeight != null) {
            cellTemplateElement.style.height = columnOptions.cellHeight;
        }
    }

    // now we need to compile, but in order for this to work, we need to have the dom in place
    // also we remove the column directive, it was just used to mark data bound body columns
    bodyTemplateRow.querySelectorAll("td[$columnDirectiveAttribute]").forEach((dom.Element el) {
      el.attributes.remove(columnDirectiveAttribute);
    });
    bodyTemplateRow.attributes.remove(bodyDirectiveAttribute);
    //
    var compiledElement = compile(bodyTemplateRow, _injector, _compiler, scope:_scope);
    // compiledInstanceElement ???
    _element.append(compiledElement);
  }
}

@Component(selector:"[$footerDirective]", 
    useShadowDom:false,
    template: """<div class="$footerOpsContainerCssClass">
<span $globalFilterDirectiveAttribute=""/>
<span $pagerDirectiveAttribute=""/>
</div>""")
class GridFooter {
}

@Component(selector:"[$globalFilterDirective]", 
    useShadowDom:false,
    template: """<span ng-show="gridOptions.enableFiltering" class="pull-left form-group">
<input class="form-control" type="text" ng-model="gridOptions.filterBy" placeholder="Search"/>
</span>""")
class GridGlobalFilter {
  
  Scope _scope;
  Grid _controller;
    
  GridGlobalFilter(this._scope, this._controller) {
    _scope.context['gridOptions'] = _controller.gridOptions;
  }
}

@Component(selector:"[$pagerDirective]", 
    useShadowDom:false,
    template: """<span class="pull-right form-group">
<ul class="pagination">
<li>
<a href="#" ng-show="pageCanGoBack" ng-click="navigatePrevPage(event)" title="Previous Page">&lArr;</a>
</li>
<li class="disabled" style="white-space: nowrap;">
<span ng-hide="totalItemsCount">No items to display</span>
<span ng-show="totalItemsCount">{{startItemIndex+1}} - {{endItemIndex+1}} displayed
<span>, {{totalItemsCount}} in total</span>
</span>
// (page {{gridOptions.currentPage}})
</li>
<li>
<a href="#" ng-show="pageCanGoForward" ng-click="navigateNextPage(event)" title="Next Page">&rArr;</a>
<li>
</ul>
</span>""")
class GridPager implements AttachAware {

  Scope _scope;
  Grid _controller;
    
  GridPager(this._scope, this._controller) {
    setupScope(_scope, _controller);
  }
  
  void attach() {
    _scope.watch("[gridOptions.currentPage, gridOptions.items.length, gridOptions.totalItems, gridOptions.pageItems]", (List newValues, List oldValues) {
        setupScope(_scope, _controller);
    });
  }

  setupScope(IGridFooterScope scope, Grid controller) {
      _scope.context['gridOptions'] = controller.gridOptions;
      _scope.context['isPaged'] = !!_scope.context['gridOptions'].pageItems;

      // do not set scope.gridOptions.totalItems, it might be set from the outside
      _scope.context['totalItemsCount'] = _scope.context['gridOptions'].totalItems != null
          ? _scope.context['gridOptions'].totalItems
          :_scope.context['gridOptions'].items != null ? _scope.context['gridOptions'].items.length : 0;

      _scope.context['startItemIndex'] = _scope.context['isPaged'] ? _scope.context['gridOptions'].pageItems * _scope.context['gridOptions'].currentPage : 0;
      _scope.context['endItemIndex'] = _scope.context['isPaged'] ? _scope.context['startItemIndex'] + _scope.context['gridOptions'].pageItems-1 : _scope.context['totalItemsCount'] - 1;
      if (_scope.context['endItemIndex'] >= _scope.context['totalItemsCount']) {
          _scope.context['endItemIndex'] = _scope.context['totalItemsCount'] - 1;
      }
      if (_scope.context['endItemIndex'] < _scope.context['startItemIndex']) {
          _scope.context['endItemIndex'] = _scope.context['startItemIndex'];
      }

      _scope.context['pageCanGoBack'] = _scope.context['isPaged'] && _scope.context['gridOptions'].currentPage > 0;
      _scope.context['pageCanGoForward'] = _scope.context['isPaged'] && _scope.context['endItemIndex'] <_scope.context['totalItemsCount'] - 1;
      _scope.context['navigateNextPage'] = (dom.Event event) {
          _scope.context['gridOptions'].currentPage = _scope.context['gridOptions'].currentPage + 1;
          event.preventDefault();
          event.stopPropagation();
      };
      _scope.context['navigatePrevPage'] = (dom.Event event) {
          _scope.context['gridOptions'].currentPage = _scope.context['gridOptions'].currentPage - 1;
          event.preventDefault();
          event.stopPropagation();
      };
  }
  

}
