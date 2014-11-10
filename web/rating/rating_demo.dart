// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

/**
 * Rating bar component.
 */
@Component(
    selector: 'rating-demo',
    templateUrl: 'rating/rating_demo.html',
    useShadowDom: false,
    exportExpressions: const ['customRatingStates']
)
class RatingDemo implements ScopeAware {
  
  Scope scope;
  
  int rate = 7;
  int max = 10;
  bool isReadonly = false;
  int overStar;
  double percent = 100.0;
  int x = 5;
  int y = 2;
  
  List<Map<String,String>> customRatingStates = [
    {'stateOn': 'glyphicon-ok-sign', 'stateOff': 'glyphicon-ok-circle'},
    {'stateOn': 'glyphicon-star', 'stateOff': 'glyphicon-star-empty'},
    {'stateOn': 'glyphicon-heart', 'stateOff': 'glyphicon-ban-circle'},
    {'stateOn': 'glyphicon-heart'},
    {'stateOff': 'glyphicon-off'}
  ];

  void hoveringOver(int value) {
    if(value == null || value == 0.0) {
      percent = 0.0;
    } else {
      overStar = value;
      percent = 100 * (value / max);
    }
  }
}