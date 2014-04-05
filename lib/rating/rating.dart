// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.rating;

import 'dart:html' as dom;
import 'package:angular/angular.dart';

import 'package:angular_ui/utils/extend.dart';
import 'package:angular_ui/utils/injectable_service.dart';

import 'package:logging/logging.dart' show Logger;
final _log = new Logger('angular.ui.rating');

class RatingModule extends Module {
  RatingModule() {
    type(RatingComponent);
    value(RatingConfig, new RatingConfig());
  }
}

@InjectableService()
class RatingConfig {
  int max = 5;
  String stateOn = null;
  String stateOff = null;
}

@NgComponent(
    selector: 'rating[ng-model]',
    publishAs: 'ctrl',
    templateUrl: 'packages/angular_ui/rating/rating.html',
    applyAuthorStyles: true
)
@NgComponent(
    selector: '[rating][ng-model]',
    publishAs: 'ctrl',
    templateUrl: 'packages/angular_ui/rating/rating.html',
    applyAuthorStyles: true
)
class RatingComponent {
  
  int maxRange = 0;
  String stateOn;
  String stateOff;
  List<Map<String, String>> range;
  int val = 0;
  
  @NgOneWay('readonly')
  bool readonly = false;
  
  @NgCallback('on-hover')
  var onHover;
  
  @NgCallback('on-leave')
  var onLeave;
  
  Scope _scope;
  dom.Element _element;
  NodeAttrs _attrs;
  NgModel _ngModel;
  RatingConfig _ratingConfig;
  
  RatingComponent(this._scope, this._element, this._attrs, this._ngModel, this._ratingConfig) {
    maxRange = _attrs.containsKey('max') ? _scope.parentScope.eval(_attrs['max']) : _ratingConfig.max;
    stateOn = _attrs.containsKey('state-on') ? _scope.parentScope.eval(_attrs['state-on']) : _ratingConfig.stateOn;
    stateOff = _attrs.containsKey('state-off') ? _scope.parentScope.eval(_attrs['state-off']) : _ratingConfig.stateOff;
    
    _ngModel.render = (value) {
      val = _ngModel.viewValue;
    };
    range = _buildTemplateObjects(_attrs.containsKey('rating-states') ? _scope.parentScope.eval(_attrs['rating-states']) : new List(maxRange));
  }
  
  List _buildTemplateObjects(List<Map<String, String>>states) {
    Map<String,String> defaultOptions =
      {
        'stateOn': this.stateOn,
        'stateOff': this.stateOff
      };
  
    if(states != null) {
      for (int i = 0, n = states.length; i < n; i++) {
        while(states.length <= i) {
          states.add({});
        }
        states[i] = extend({ 'index': i }, [states[i], defaultOptions]);
      }
    }
    return states;
  }
  
  void rate(value) {
    if (!readonly ) {
      _ngModel.viewValue = value;
      _ngModel.render(_ngModel.modelValue);
    }
  }
  
  void enter(value) {
    if (!readonly) {
      val = value;
    }
    onHover({'value': value});
  }
  
  void reset() {
    val = _ngModel.viewValue;
    onLeave();
  }
  
  String stateClass(index, Map<String, String> r) {
    if (index < val) {
      return r.containsKey('stateOn') && r['stateOn'] != null ? r['stateOn'] : 'glyphicon-star';
    } else {
      return r.containsKey('stateOff') && r['stateOff'] != null ? r['stateOff'] : 'glyphicon-star-empty';
    }
  }
}