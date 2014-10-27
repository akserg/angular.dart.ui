// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

@Component(
    selector: '[sortable-simple-controller]',
    templateUrl: 'dragdrop/sortable_demo_simple.html',
    useShadowDom: false
    )
class SortableController {

  List<String> listOne = ['Coffee','Orange Juice','Red Wine','Unhealty drink!','Water'];
  
  SortableController() {
  }
  
}


@Component(
    selector: '[sortable-multi-controller]',
    templateUrl: 'dragdrop/sortable_demo_multi.html',
    useShadowDom: false
    )
class SortableMultiController {

  List<String> listBoxers = ['Sugar Ray Robinson','Muhammad Ali','George Foreman','Joe Frazier','Jake LaMotta','Joe Louis','Jack Dempsey','Rocky Marciano','Mike Tyson','Oscar De La Hoya'];
  List<String> listTeamOne = [];
  List<String> listTeamTwo = [];
  
  SortableMultiController() {
  }
  
}
