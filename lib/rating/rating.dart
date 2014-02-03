library angular.ui.rating;

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
    selector: 'rating',
    publishAs: 'ctrl',
    //templateUrl: 'packages/angular_ui/rating/rating.html',
    template: r'''
<span ng-mouseleave="ctrl.reset()">
  <i ng-repeat="r in ctrl.range" ng-mouseenter="ctrl.enter($index + 1)" ng-click="ctrl.rate($index + 1)" class="glyphicon" ng-class="ctrl.stateClass($index, r)"></i>
</span>
''',
    applyAuthorStyles: true
)
class RatingComponent implements NgAttachAware {
  final Scope _scope;
  final RatingConfig _config;

  int _max; // could be restored to simple field after #431 is fixed (after 0.9.5+2) - see also attach below
  //@NgOneWay('max') int max;
  @NgOneWay('max') set max(int value) {
    print('Max: $value');
    _max = value;
    attachTmp();
  }
  int get max => _max;

  int _value = 0;
  @NgTwoWay('value') int get value => _value;
  set value(int val) {
    _value = val;
    reset();
  }
  @NgTwoWay('readonly') bool isReadonly = false;
  @NgCallback('on-hover') var onHover;
  @NgCallback('on-leave') var onLeave;
  @NgTwoWay('rating-states') List<Map<String,String>> ratingStates;
  @NgTwoWay('state-on') String stateOn;
  @NgTwoWay('state-off') String stateOff;

  int val = 0;
  List<Map> range;

  RatingComponent(this._scope, this._config ) {
    _log.fine('RatingComponent');
  }

  List<Map<String,String>> createRateObjects(List<Map<String,String>> states) {
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

  void rate (int value) {
    if(this.value != value && !isReadonly) {
      this.value = value;
    }
  }

  void enter(int value) {
    if(!isReadonly) {
      this.val = value;
    }
    onHover({'value': value});
  }

  void reset() {
    val = value;
    onLeave();
  }

  String stateClass(int index, Map r) {
    String c;
    if(index < val) {
      c = (r['stateOn'] != null) ? r['stateOn'] : 'glyphicon-star';
    } else {
      c = (r['stateOff'] != null) ? r['stateOff'] : 'glyphicon-star-empty';
    }
    return c;
  }

  void attachTmp() { // move content back to attach when bug #431 is fixed (after 0.9.5+2)
    _log.fine('Max: $max');
    int maxRange = max != null ? max : _config.max;
    stateOn = stateOn != null ? stateOn : _config.stateOn;
    stateOff = stateOff != null ? stateOff : _config.stateOff;

    range = ratingStates != null ?
        createRateObjects(copy(ratingStates)) :
          this.createRateObjects(new List(maxRange));
    reset();

    //_scope.$watch(() => value, reset);

  }
  void attach() {
  }
}