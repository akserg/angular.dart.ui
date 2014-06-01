// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

@Controller(
    selector: '[sortable-simple-controller]',
    publishAs: 'sortCtrl')
class SortableController {

  List<String> listOne = ['Coffee','Orange Juice','Red Wine','Unhealty drink!','Water'];
  
  SortableController() {
  }
  
}


@Controller(
    selector: '[sortable-multi-controller]',
    publishAs: 'sortMultiCtrl')
class SortableMultiController {

  List<String> listOne = ['Sugar Ray Robinson','Muhammad Ali','George Foreman','Joe Frazier','Jake LaMotta'];
  List<String> listTwo = ['Joe Louis','Jack Dempsey','Rocky Marciano','Mike Tyson','Oscar De La Hoya'];
  
  SortableMultiController() {
  }
  
}
