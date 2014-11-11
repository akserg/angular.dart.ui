// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.timepicker;

import 'dart:html' as dom;
import "package:angular/angular.dart";
import "package:angular/core_dom/module_internal.dart";
import 'package:angular_ui/utils/utils.dart';

/**
 * Timepicker Module.
 */
class TimepickerModule extends Module {
  TimepickerModule() {
    bind(TimepickerConfig, toValue:new TimepickerConfig());
    bind(Timepicker);
  }
}

class TimepickerConfig {
  int hourStep = 1;
  int minuteStep = 1;
  bool showMeridian = true;
  List meridians = null;
  bool readonlyInput = false;
  bool mousewheel = true;
}

const List AMPMS = const ['AM','PM'];

/**
 * Timepicker.
 */
@Component(
    selector: 'timepicker[ng-model]',
//    templateUrl: 'packages/angular_ui/timepicker/timepicker.html',
    template: '''
<table>
  <tbody>
    <tr class="text-center">
      <td><a ng-click="incrementHours()" class="btn btn-link"><span class="glyphicon glyphicon-chevron-up"></span></a></td>
      <td>&nbsp;</td>
      <td><a ng-click="incrementMinutes()" class="btn btn-link"><span class="glyphicon glyphicon-chevron-up"></span></a></td>
      <td ng-show="showMeridian"></td>
    </tr>
    <tr id="times">
      <td style="width:50px;" class="form-group" ng-class="{'has-error': invalidHours}">
        <!--input id="hours" type="text" ng-change="updateHours()" class="form-control text-center" ng-mousewheel="incrementHours()" ng-readonly="readonlyInput" maxlength="2"-->
        <input id="hours" type="text" ng-change="updateHours()" class="form-control text-center" ng-readonly="readonlyInput" maxlength="2">
      </td>
      <td>:</td>
      <td style="width:50px;" class="form-group" ng-class="{'has-error': invalidMinutes}">
        <!--input id="minutes" type="text" ng-change="updateMinutes()" class="form-control text-center" ng-mousewheel="incrementMinutes()" ng-readonly="readonlyInput" maxlength="2"-->        
        <input id="minutes" type="text" ng-change="updateMinutes()" class="form-control text-center" ng-readonly="readonlyInput" maxlength="2">
      </td>
      <td ng-show="showMeridian"><button type="button" class="btn btn-default text-center" ng-click="toggleMeridian()">{{meridian}}</button></td>
    </tr>
    <tr class="text-center">
      <td><a ng-click="decrementHours()" class="btn btn-link"><span class="glyphicon glyphicon-chevron-down"></span></a></td>
      <td>&nbsp;</td>
      <td><a ng-click="decrementMinutes()" class="btn btn-link"><span class="glyphicon glyphicon-chevron-down"></span></a></td>
      <td ng-show="showMeridian"></td>
    </tr>
  </tbody>
</table>''',
    useShadowDom: false 
)
//@Component(selector: '[timepicker][ng-model]', publishAs: 't', 
//    useShadowDom: false, 
//    templateUrl: 'packages/angular_ui/timepicker/timepicker.html')
class Timepicker implements ShadowRootAware, ScopeAware {
  
  DateTime selected;
  List meridians;
  
  dom.Element _element;
  TimepickerConfig _timepickerConfig;
  NodeAttrs _attrs;
  NgModel _ngModel;
  
  Scope scope;
  
  var hourStep = 0, minuteStep = 0, showMeridian = false, readonlyInput = false, mousewheel = false;
  
  var invalidHours, invalidMinutes, updateHours, validHours, hours, updateMinutes, minutes, meridian;
  
  incrementHours () => addMinutes( hourStep * 60 );
  decrementHours () => addMinutes( - hourStep * 60 );
  incrementMinutes () => addMinutes( minuteStep );
  decrementMinutes () => addMinutes( - minuteStep );
  toggleMeridian () => addMinutes(12*60*((selected.hour < 12) ? 1 : -1));
  
  Timepicker(this._element, this._timepickerConfig, this._attrs, this._ngModel) {
    selected = new DateTime.now();
  }
  
  void onShadowRoot(dom.ShadowRoot shadowRoot) {
    meridians = _attrs.containsKey('meridians') ? scope.parentScope.eval(_attrs['meridians']) : _timepickerConfig.meridians != null ? _timepickerConfig.meridians : AMPMS;
    
    hourStep = _timepickerConfig.hourStep;
    if (_attrs.containsKey('hour-step')) {
      scope.parentScope.watch(_attrs['hour-step'], (value, oldValue) {
        hourStep = toInt(value);
      });
    }
    
    minuteStep = _timepickerConfig.minuteStep;
    if (_attrs.containsKey('minute-step')) {
      scope.parentScope.watch(_attrs['minute-step'], (value, oldValue) {
        minuteStep = toInt(value);
      });
    }
    
    // 12H / 24H mode
    showMeridian = _timepickerConfig.showMeridian;
    if (_attrs.containsKey('show-meridian')) {
      scope.parentScope.watch(_attrs['show-meridian'], (value, oldValue) {
        showMeridian = !!value;

        if (_ngModel.errorStates['time'] != null) {
          // Evaluate from template
          var hours = getHoursFromTemplate(), 
              minutes = getMinutesFromTemplate();
          if (hours != null && minutes != null) {
            selected = new DateTime(selected.year, selected.month, selected.day, hours, selected.minute, selected.second, selected.millisecond);
            refresh();
          }
        } else {
          _updateTemplate();
        }
      });
    }
        
    // Input elements
    List inputs = ngQuery(_element, 'input'); 
    dom.Element hoursInputEl = inputs[0];
    dom.Element minutesInputEl = inputs[1];
    
    // Respond on mousewheel spin
    mousewheel = _attrs.containsKey('mousewheel') ? scope.eval(_attrs['mousewheel']) : _timepickerConfig.mousewheel;
    if (mousewheel != null) {
  
      var isScrollingUp = (dom.WheelEvent e) {
        return e.deltaX > 0 || e.deltaY < 0;
      };
           
      hoursInputEl.onMouseWheel.listen((e) {
        scope.apply((isScrollingUp(e)) ? incrementHours() : decrementHours());
        e.preventDefault();
      });
      
      minutesInputEl.onMouseWheel.listen((e) {
        scope.apply((isScrollingUp(e)) ? incrementMinutes() : decrementMinutes());
        e.preventDefault();
      });
    }
    
    readonlyInput = _attrs.containsKey('readonly-input') ? scope.eval(_attrs['readonly-input']) : _timepickerConfig.readonlyInput;
    if (!readonlyInput) {
      updateHours = () {
        var hours = getHoursFromTemplate();

        if (hours != null ) {
          selected = new DateTime(selected.year, selected.month, selected.day, hours, selected.minute, selected.second, selected.millisecond);
          refresh('h');
        } else {
          _invalidate(hours: true);
        }
      };

      hoursInputEl.addEventListener('blur', (e) {
        if (!validHours && hours < 10) {
          scope.apply(() {
            hours = _pad(hours);
          });
        }
      });

      updateMinutes = () {
        var minutes = getMinutesFromTemplate();

        if (minutes != null) {
          selected = new DateTime(selected.year, selected.month, selected.day, selected.hour, minutes, selected.second, selected.millisecond);
          refresh( 'm' );
        } else {
          _invalidate(minutes: true);
        }
      };

      minutesInputEl.addEventListener('blur', (e) {
        if (!invalidMinutes && minutes < 10 ) {
          scope.apply(() {
            minutes = _pad(minutes);
          });
        }
      });
    } else {
      updateHours = null;
      updateMinutes = null;
    }
    
    _ngModel.render = (value) {
      DateTime date = parseDate(_ngModel.modelValue);
      if (date == null) {
//        _ngModel.setValidity('time', false);
//        $log.error('Timepicker directive: "ng-model" value must be a Date object, a number of milliseconds since 01.01.1970 or a string representing an RFC2822 or ISO 8601 date.');
      } else {
        selected = date;
        _makeValid();
        _updateTemplate();
      }
    };
  }

  _invalidate({bool hours:false, bool minutes:false}) {
    _ngModel.viewValue = null;
//    _ngModel.setValidity('time', false);
  }
  
  // Get _scope.hours in 24H mode if valid
  int getHoursFromTemplate ( ) {
    var hours_ = int.parse(hours);
    var valid = showMeridian ? (hours_ > 0 && hours_ < 13) : (hours_ >= 0 && hours_ < 24);
    if (!valid) {
      return null;
    }

    if (showMeridian) {
      if (hours_ == 12 ) {
        hours_ = 0;
      }
      if (meridian == meridians[1] ) {
        hours_ = hours_ + 12;
      }
    }
    return hours_;
   }
  
  int getMinutesFromTemplate() {
    var minutes_ = int.parse(minutes);
    return (minutes_ >= 0 && minutes_ < 60) ? minutes_ : null;
  }
  
  String _pad(value) {
    if (value != null) {
      String val = value.toString();
      return val.length < 2 ? '0${value}' : val;
    }
    return null;
  }
  
  DateTime _parseDate(value) {
    if (value != null) {
      if (value is DateTime) {
        return value;
      } else if (value is String) {
        return DateTime.parse(value);
      } else if (value is int) {
        return new DateTime.fromMillisecondsSinceEpoch(value);
      }
    }
    return null;
  }
  
  // Call internally when we know that model is valid.
  void refresh([keyboardChange = null]) {
    _makeValid();
    _ngModel.viewValue = _parseDate(selected); 
    _updateTemplate(keyboardChange);
  }
  
  void _makeValid() {
//    _ngModel.setValidity('time', true);
    invalidHours = false;
    invalidMinutes = false;
  }
  
  void _updateTemplate([keyboardChange = null]) {
    var hours = selected.hour;
    var minutes = selected.minute;

    if (toBool(showMeridian)) {
      hours = (hours == 0 || hours == 12) ? 12 : hours % 12; // Convert 24 to 12 hour system
    }
    hours =  keyboardChange == 'h' ? hours : _pad(hours);
    minutes = keyboardChange == 'm' ? minutes : _pad(minutes);
    meridian = selected.hour < 12 ? meridians[0] : meridians[1];
    
    dom.InputElement hoursEl = ngQuery(_element, "#hours").first;
    if (hoursEl != null) {
      hoursEl.value = hours;
    }
    dom.InputElement minutesEl = ngQuery(_element, "#minutes").first;
    if (minutesEl != null) {
      minutesEl.value = minutes;
    }
  }
  
  void addMinutes( minutes ) {
    var dt = _parseDate(selected.millisecondsSinceEpoch + minutes * 60000);
    selected = new DateTime(selected.year, selected.month, selected.day, dt.hour, dt.minute, selected.second, selected.millisecond);
    refresh();
  }
}