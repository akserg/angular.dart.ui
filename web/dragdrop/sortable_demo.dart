// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

@Controller(
    selector: '[sortable-simple-controller]',
    publishAs: 'sortCtrl')
class SortableController {

  List<String> listOne = ['1 - Coffee','2 - Orange Juice','3 - Red Wine','4 - Unhealty drink!','5 - Water'];
  
  SortableController() {
    print("sort controller ready");
  }
  
  void addEntry() {
    listOne.add( (listOne.length + 1).toString() + " - New");
  }
  
  void removeEntry() {
      listOne.removeLast();
  }

}
