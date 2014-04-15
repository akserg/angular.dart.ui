// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.timepicker;

import 'dart:html' as dom;
import "package:angular/angular.dart";

/**
 * Timepicker Module.
 */
class TimepickerModule extends Module {
  TimepickerModule() {
    value(TimepickerConfig, new TimepickerConfig());
    type(Timepicker);
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
 * Datepicker.
 */
@NgComponent(selector: 'timepicker[ng-model]', publishAs: 't',
    applyAuthorStyles: true, 
    templateUrl: 'packages/angular_ui/timepicker/timepicker.html')
@NgComponent(selector: '[timepicker][ng-model]', publishAs: 't', 
    applyAuthorStyles: true, 
    templateUrl: 'packages/angular_ui/timepicker/timepicker.html')
class Timepicker implements NgShadowRootAware {
  
  DateTime selected;
  List meridians;
  
  dom.Element _element;
  TimepickerConfig _timepickerConfig;
  NodeAttrs _attrs;
  NgModel _ngModel;
  Scope _scope;
  Parser _parser;
  
  Timepicker(this._element, this._timepickerConfig, this._attrs, this._ngModel, this._scope, this._parser) {

    selected = new DateTime.now();
    meridians = _attrs.containsKey('meridians') ? _scope.parentScope.eval(_attrs['meridians']) : _timepickerConfig.meridians != null ? _timepickerConfig.meridians : AMPMS;
  }
  
  void onShadowRoot(dom.ShadowRoot shadowRoot) {
    var hourStep = _timepickerConfig.hourStep;
    if (_attrs.containsKey('hourStep')) {
      _scope.parentScope.watch(_parser(_attrs['hourStep']), (value, oldValue) {
        hourStep = int.parse(value);
      });
    }
    
    var minuteStep = _timepickerConfig.minuteStep;
    if (_attrs.containsKey('minuteStep')) {
      _scope.parentScope.watch(_parser(_attrs['minuteStep']), (value, oldValue) {
        minuteStep = int.parse(value);
      });
    }
    
    // 12H / 24H mode
    _scope.context['showMeridian'] = _timepickerConfig.showMeridian;
    if (_attrs.containsKey('showMeridian')) {
      _scope.parentScope.watch(_parser(_attrs['showMeridian']), (value, oldValue) {
        _scope.context['showMeridian'] = !!value;

        if (_ngModel.errorStates['time'] != null) {
          // Evaluate from template
          var hours = getHoursFromTemplate(), 
              minutes = getMinutesFromTemplate();
          if (hours != null && minutes != null) {
            //selected.setHours( hours );
            selected = new DateTime(selected.year, selected.month, selected.day, hours, selected.minute, selected.second, selected.millisecond);
            refresh();
          }
        } else {
          updateTemplate();
        }
      });
    }
        
    // Input elements
    List inputs = ngQuery(_element, 'input'); 
    dom.Element hoursInputEl = inputs[0];
    dom.Element minutesInputEl = inputs[1];
    
    // Respond on mousewheel spin
    var mousewheel = _attrs.containsKey('mousewheel') ? _scope.eval(_attrs['mousewheel']) : _timepickerConfig.mousewheel;
    if (mousewheel != null) {
  
      var isScrollingUp = (e) {
        if (e.originalEvent != null) {
          e = e.originalEvent;
        }
        //pick correct delta variable depending on event
        var delta = (e.wheelDelta) ? e.wheelDelta : -e.deltaY;
        return (e.detail || delta > 0);
      };
           
      hoursInputEl.addEventListener('mousewheel wheel', (e) {
        _scope.apply((isScrollingUp(e)) ? _scope.context['incrementHours']() : _scope.context['decrementHours']());
        e.preventDefault();
      });
           
      minutesInputEl.addEventListener('mousewheel wheel', (e) {
        _scope.apply((isScrollingUp(e)) ? _scope.context['incrementMinutes']() : _scope.context['decrementMinutes']());
        e.preventDefault();
      });
    }
    
    _scope.context['readonlyInput'] = _attrs.containsKey('readonlyInput') ? _scope.eval(_attrs['readonlyInput']) : _timepickerConfig.readonlyInput;
    if (!_scope.context['readonlyInput']) {
      var invalidate = (invalidHours, invalidMinutes) {
        _ngModel.viewValue = null;
//        _ngModel.setValidity('time', false);
        if (invalidHours != null) {
          _scope.context['invalidHours'] = invalidHours;
        }
        if (invalidMinutes != null) {
          _scope.context['invalidMinutes'] = invalidMinutes;
        }
      };

      _scope.context['updateHours'] = () {
        var hours = getHoursFromTemplate();

        if (hours != null ) {
          selected = new DateTime(selected.year, selected.month, selected.day, hours, selected.minute, selected.second, selected.millisecond);
          refresh('h');
        } else {
          invalidate(true);
        }
      };

      hoursInputEl.addEventListener('blur', (e) {
        if (!_scope.context['validHours'] && _scope.context['hours'] < 10) {
          _scope.apply(() {
            _scope.context['hours'] = pad(_scope.context['hours']);
          });
        }
      });

      _scope.context['updateMinutes'] = () {
        var minutes = getMinutesFromTemplate();

        if (minutes != null) {
          selected = new DateTime(selected.year, selected.month, selected.day, selected.hour, minutes, selected.second, selected.millisecond);
          refresh( 'm' );
        } else {
          invalidate(null, true);
        }
      };

      minutesInputEl.addEventListener('blur', (e) {
        if (!_scope.context['invalidMinutes'] && _scope.context['minutes'] < 10 ) {
          _scope.apply(() {
            _scope.context['minutes'] = pad(_scope.context['minutes']);
          });
        }
      });
    } else {
      if (_scope.context.containsKey('updateHours')) {
        _scope.context.remove('updateHours');
      }
      if (_scope.context.containsKey('updateMinutes')) {
          _scope.context.remove('updateMinutes');
      }
    }
    
    _scope.watch('ngModel', (value, prev) {
      var date;
      if (_ngModel.modelValue != null) {
        if (_ngModel.modelValue is DateTime) {
          date = _ngModel.modelValue;
        } else if (_ngModel.modelValue is String) {
          date = DateTime.parse(_ngModel.modelValue);
        } else if (_ngModel.modelValue is int) {
          date = new DateTime.fromMillisecondsSinceEpoch(_ngModel.modelValue);
        }
      } 
      
      if (date == null) {
//        _ngModel.setValidity('time', false);
//        $log.error('Timepicker directive: "ng-model" value must be a Date object, a number of milliseconds since 01.01.1970 or a string representing an RFC2822 or ISO 8601 date.');
      } else {
        selected = date;
        makeValid();
        updateTemplate();
      }
    });
    
//    _ngModel.render = (value) {
//      
//      var date;
//      if (_ngModel.modelValue != null) {
//        if (_ngModel.modelValue is DateTime) {
//          date = _ngModel.modelValue;
//        } else if (_ngModel.modelValue is String) {
//          date = DateTime.parse(_ngModel.modelValue);
//        } else if (_ngModel.modelValue is int) {
//          date = new DateTime.fromMillisecondsSinceEpoch(_ngModel.modelValue);
//        }
//      } 
//      
//      if (date == null) {
//        _ngModel.setValidity('time', false);
////        $log.error('Timepicker directive: "ng-model" value must be a Date object, a number of milliseconds since 01.01.1970 or a string representing an RFC2822 or ISO 8601 date.');
//      } else {
//        selected = date;
//        makeValid();
//        updateTemplate();
//      }
//    };
    
    _scope.context['incrementHours'] = () {
      addMinutes( hourStep * 60 );
    };
    _scope.context['decrementHours'] = () {
      addMinutes( - hourStep * 60 );
    };
    _scope.context['incrementMinutes'] = () {
      addMinutes( minuteStep );
    };
    _scope.context['decrementMinutes'] = () {
      addMinutes( - minuteStep );
    };
    _scope.context['toggleMeridian'] = () {
      addMinutes(12*60*((selected.hour < 12) ? 1 : -1));
    };
  }
  
  // Get _scope.hours in 24H mode if valid
  int getHoursFromTemplate ( ) {
    var hours = int.parse(_scope.context['hours']);
    var valid = _scope.context['showMeridian'] ? (hours > 0 && hours < 13) : (hours >= 0 && hours < 24);
    if (!valid) {
      return null;
    }

    if (_scope.context['showMeridian']) {
      if (hours == 12 ) {
        hours = 0;
      }
      if (_scope.context['meridian'] == meridians[1] ) {
        hours = hours + 12;
      }
    }
    return hours;
   }
  
  int getMinutesFromTemplate() {
    var minutes = int.parse(_scope.context['minutes']);
    return (minutes >= 0 && minutes < 60) ? minutes : null;
  }
  
  String pad(value) {
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
    makeValid();
    _ngModel.viewValue = _parseDate(selected); 
    updateTemplate(keyboardChange);
  }
  
  void makeValid() {
//    _ngModel.setValidity('time', true);
    _scope.context['invalidHours'] = false;
    _scope.context['invalidMinutes'] = false;
  }
  
  void updateTemplate([keyboardChange = null]) {
    var hours = selected.hour;
    var minutes = selected.minute;

    if (_scope.context['showMeridian']) {
      hours = (hours == 0 || hours == 12) ? 12 : hours % 12; // Convert 24 to 12 hour system
    }
    _scope.context['hours'] =  keyboardChange == 'h' ? hours : pad(hours);
    _scope.context['minutes'] = keyboardChange == 'm' ? minutes : pad(minutes);
    _scope.context['meridian'] = selected.hour < 12 ? meridians[0] : meridians[1];
  }
  
  void addMinutes( minutes ) {
    var dt = _parseDate(selected.millisecondsSinceEpoch + minutes * 60000);
    selected = new DateTime(selected.year, selected.month, selected.day, dt.hour, dt.minute, selected.second, selected.millisecond);
    refresh();
  }
}