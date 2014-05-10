// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

@Controller(
    selector: '[grid-demo-controller]',
    publishAs: 'gridCtrl')
class GridDemoController {
  
  List myItems = [
    {'id':1, 'name':'John'},
    {'id':2, 'name':'Marry'}
  ];
}