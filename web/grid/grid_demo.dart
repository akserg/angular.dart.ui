// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

@Controller(
    selector: '[grid-demo-controller]',
    publishAs: 'gridCtrl')
class GridDemoController {
  
  List selectedItems = [];
  
  List myItems = [
    {'id':1, 'userName':'John'},
    {'id':2, 'userName':'Marry'},
    {'id':3, 'userName':'Marko'},
    {'id':4, 'userName':'Elton'},
    {'id':5, 'userName':'Mario'},
    {'id':6, 'userName':'Antony'},
    {'id':7, 'userName':'King'},
    {'id':8, 'userName':'Peter'},
    {'id':9, 'userName':'Anton'},
    {'id':10, 'userName':'Sergey'},
    {'id':11, 'userName':'Helen'},
    {'id':12, 'userName':'Patrik'},
    {'id':13, 'userName':'Glenn'},
    {'id':14, 'userName':'Jeffrey'},
    {'id':15, 'userName':'Nathan'}
  ];
  
  List myItems2 = [
   {'name':'Anna', 'role':'Manager'},
   {'name':'Lana', 'role':'Admin'}
  ];
                  
}