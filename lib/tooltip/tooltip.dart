// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.tooltip;

import 'dart:html' as dom;
import 'dart:async' as async;
import "package:angular/angular.dart";
import "package:angular/core_dom/module_internal.dart";
import 'package:angular_ui/utils/timeout.dart';
import 'package:angular_ui/utils/position.dart';
import 'package:angular_ui/utils/utils.dart';

/**
 * Tooltip Module.
 */
class TooltipModule extends Module {
  TooltipModule() {
    install(new TimeoutModule());
    install(new PositionModule());
    bind(TooltipConfig, toValue:new TooltipConfig());
    bind(Tooltip);
  }
}

@Injectable()
class TooltipConfig {
  // The default options tooltip and popover.
  Map defaultOptions = {
   'placement': 'top',
   'animation': true,
   'popupDelay': 0
  };
  
  // Default hide triggers for each show trigger
  Map triggerMap = {
   'mouseenter': 'mouseleave',
   'click': 'click',
   'focus': 'blur'
  };
  
  // The options specified to the provider globally.
  Map globalOptions = {};
  
  /**
   * `options({})` allows global configuration of all tooltips in the
   * application.
  *
   *   var app = angular.module( 'App', ['ui.bootstrap.tooltip'], function( $tooltipProvider ) {
   *     // place tooltips left instead of top by default
   *     $tooltipProvider.options( { placement: 'left' } );
   *   });
   */
  void set options( value ) {
    globalOptions = value;
  }
  
  /**
   * This allows you to extend the set of trigger mappings available. E.g.:
  *
   *   $tooltipProvider.setTriggers( 'openTrigger': 'closeTrigger' );
   */
  void set triggers(value) {
    triggerMap = value;
  }
  
  /**
   * This is a helper function for translating camel-case to snake-case.
   */
  String snakeCase(String name){
   var regexp = new RegExp('/[A-Z]/');
   var separator = '-';
//   return name.replace(regexp, (letter, pos) {
//     return (pos ? separator : '') + letter.toLowerCase();
//   });
   return name.replaceAllMapped(regexp, (Match match) {
     return (match != null ? separator : '') + match.group(0).toLowerCase();
   });
  }
}

@Component(
    selector:'[tooltip]',
    useShadowDom: false
) 
//@Decorator(selector:'tooltip')
class Tooltip extends TooltipBase {
  
  var template = '<div><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>';
  
  Tooltip(dom.Element element, NodeAttrs attrs, Timeout timeout, TooltipConfig config, Interpolate interpolate, Position position, Injector injector, Compiler compiler) : 
    super("tooltip", 'tooltip', 'mouseenter', element, attrs, timeout, config, interpolate, position, injector, compiler);
  
  void render() {
    tooltip.classes.clear();
    tooltip.classes.add('tooltip');
    //
    var _placement = tt_placement;
    if (_placement != null && _placement.length > 0) {
      tooltip.classes.add(_placement);
    }
    //
    var _in = toBool(eval(_scope, tt_isOpen));
    if (_in) {
      tooltip.classes.add('in');
    }
    //
    var _fade = toBool(eval(_scope, tt_animation));
    if (_fade) {
      tooltip.classes.add('fade');
    }
    //
    dom.Element innerTooltip = tooltip.children[1];
    innerTooltip.setInnerHtml(tt_content);
  }
}

/**
 * Base class for all tooltipable components.
 */
abstract class TooltipBase implements ScopeAware {
  
  Map options;
  
  var directiveName;
  
  var template;
        
  dom.Element tooltip;
  
  var transitionTimeout;
  async.Completer popupTimeout;
  bool appendToBody = false;
  Map triggers;
  bool hasEnableExp = false;      
      
  Scope _scope;
  dom.Element _element;
  NodeAttrs _attrs;
  
  Timeout _timeout;
  TooltipConfig _config;
  String defaultTriggerShow;
  String _type;
  Interpolate _interpolate;
  String prefix = '';
  Position _position;
  Injector _injector;
  Compiler _compiler;
  
  var tt_isOpen, tt_content, tt_title, tt_placement, tt_popupDelay, tt_animation;
  
  TooltipBase(this._type, this.prefix, this.defaultTriggerShow, 
      this._element, this._attrs, this._timeout, this._config, 
      this._interpolate, this._position, this._injector, this._compiler);
  
  Scope get scope => _scope;
  void set scope(Scope scope) {
      _scope = scope;
    
    options = new Map.from(_config.defaultOptions)..addAll(_config.globalOptions);
    
    directiveName = _config.snakeCase(_type);

    appendToBody = options.containsKey('append-to-body') ? options['append-to-body'] : false;
    triggers = getTriggers();
    hasEnableExp = _attrs.containsKey('${prefix}-enable');
      
    // By default, the tooltip is not open.
    // TODO add ability to start tooltip opened
    tt_isOpen = false;

    /**
     * Observe the relevant attributes.
     */
    _attrs.observe(_type, (val) {
      tt_content = val;

      if (val == null && tt_isOpen) {
        hide();
      }
    });
    
    _attrs.observe('${prefix}-title', (val) {
      tt_title = val;
    });
    
    _attrs.observe('${prefix}-placement', (val) {
      tt_placement = val != null ? val : options['placement'];
    });
    
    _attrs.observe('${prefix}-popup-delay', (val) {
      var delay = eval(_scope, val, options['popupDelay']);
      tt_popupDelay = delay is int ? delay : options['popupDelay'];
    });
   
    _attrs.observe('${prefix}-trigger', (val) {
      unregisterTriggers();
  
      triggers = getTriggers( val );
  
      if (triggers['show'] == triggers['hide'] ) {
        _element.addEventListener(triggers['show'], toggleTooltipBind);
      } else {
        _element.addEventListener(triggers['show'], showTooltipBind );
        _element.addEventListener(triggers['hide'], hideTooltipBind );
      }
    });
    
    bool attrAnimation = toBool(_scope.eval(_attrs['${prefix}-animation']));
    tt_animation = attrAnimation != null ? attrAnimation : options['animation'];
    
    _attrs.observe('${prefix}-append-to-body', (val) {
      appendToBody = val != null ? _scope.eval(val) : appendToBody;
    });
    
    // if a tooltip is attached to <body> we need to remove it on
    // location change as its parent scope will probably not be destroyed
    // by the change.
    if (appendToBody) {
      _scope.on('locationChangeSuccess').listen((evt) {
        if (tt_isOpen) {
          hide();
        }
     });
    }
    // Make sure tooltip is destroyed and removed.
    _scope.on(ScopeEvent.DESTROY).listen((evt) {
      _timeout.cancel(transitionTimeout);
      _timeout.cancel(popupTimeout);
      unregisterTriggers();
      removeTooltip();
    });
  }

  /**
   * Returns an object of show and hide triggers.
   *
   * If a trigger is supplied,
   * it is used to show the tooltip; otherwise, it will use the `trigger`
   * option passed to the `$tooltipProvider.options` method; else it will
   * default to the trigger supplied to this directive factory.
   *
   * The hide trigger is based on the show trigger. If the `trigger` option
   * was passed to the `$tooltipProvider.options` method, it will use the
   * mapped trigger from `triggerMap` or the passed trigger if the map is
   * undefined; otherwise, it uses the `triggerMap` value of the show
   * trigger; else it will just use the show trigger.
   */
  Map getTriggers([String trigger = null]) {
    String show = trigger != null ? trigger : options.containsKey('trigger') ? options['trigger'] : defaultTriggerShow;
    String hide = _config.triggerMap.containsKey(show) ? _config.triggerMap[show] : show;
    return {
      'show': show,
      'hide': hide
    };
  }  
  
  // Show the tooltip popup element.
  void show() {

    String scopeContent = tt_content;
    // Don't show empty tooltips.
    if (scopeContent == null || scopeContent.length == 0 ) {
      return null; //angular.noop;
    }
    
    createTooltip();
    
    // If there is a pending remove transition, we must cancel it, lest the
    // tooltip be mysteriously removed.
    if (transitionTimeout != null) {
      _timeout.cancel(transitionTimeout);
    }
    
    // Set the initial positioning.
    tooltip.style.top = "0";
    tooltip.style.left = "0";
    tooltip.style.display = 'inline';
    
    // Now we add it to the DOM because need some info about it. But it's not 
    // visible yet anyway.
    if (appendToBody) {
        dom.document.body.append(tooltip);
    } else {
      _element.parent.append(tooltip);
    }

    positionTooltip();
    
    // And show the tooltip.
    tt_isOpen = true;
    _scope.apply(); // digest required as $apply is not called
    
    render();
    
    positionTooltip();
  }
  
  // Hide the tooltip popup element.
  void hide() {
    // First things first: we don't show it anymore.
    tt_isOpen = false;
    
    //if tooltip is going to be shown after delay, we must cancel this
    _timeout.cancel(popupTimeout);
    
    // And now we remove it from the DOM. However, if we have animation, we 
    // need to wait for it to expire beforehand.
    // FIXME: this is a placeholder for a port of the transitions library.
    if (tt_animation) {
      transitionTimeout = _timeout(removeTooltip, delay:500);
    } else {
      removeTooltip();
    }
  }
  
  void createTooltip() {
    // There can only be one tooltip element per directive shown at once.
    removeTooltip();
    tooltip = compile(template, _injector, _compiler);
  }
  
  void removeTooltip() {
    if (tooltip != null) {
      tooltip.remove();
      tooltip = null;
    }
  }

  
  // Show the tooltip with delay if specified, otherwise show it immediately
  void showTooltipBind([dom.Event evt]) {
    if(hasEnableExp && !_scope.eval(_attrs['${prefix}-enable'])) {
      return;
    }
    
    int delay = tt_popupDelay;
    if (delay != null && delay > 0) {
      popupTimeout = _timeout(show, delay:delay, invokeApply:false);
    } else {
      show();
    }
   }
  
  void hideTooltipBind([dom.Event evt]) {
    _scope.apply(() {
      hide();
    });
  }
  
  
  void toggleTooltipBind([dom.Event evt]) {
    if (!tt_isOpen) {
      showTooltipBind();
    } else {
      hideTooltipBind();
    }
  }

  void positionTooltip() {
    int ttWidth, ttHeight;
    Map ttPosition;
    // Get the position of the directive element.
    //position = appendToBody ? _position.offset(_element) : _position.position(_element);
    dom.Rectangle position = appendToBody ? _element.offset : _element.offset;

    // Get the height and width of the tooltip so we can center it.
    ttWidth = tooltip.offsetWidth;
    ttHeight = tooltip.offsetHeight;
    
    // Calculate the tooltip's top and left coordinates to center it with
    // this directive.
    switch (tt_placement) {
      case 'right':
        ttPosition = {
          'top': position.top + (position.height - ttHeight) / 2,
          'left': position.left + position.width
        };
        break;
      case 'bottom':
        ttPosition = {
          'top': position.top + position.height,
          'left': position.left + (position.width - ttWidth) / 2
        };
        break;
      case 'left':
        ttPosition = {
          'top': position.top + (position.height - ttHeight) / 2,
          'left': position.left - ttWidth
        };
        break;
      default:
        ttPosition = {
          'top': position.top - ttHeight,
          'left': position.left + (position.width - ttWidth) / 2
        };
        break;
    }

    // Now set the calculated positioning.
    tooltip.style.top = "${ttPosition['top']}px";
    tooltip.style.left = "${ttPosition['left']}px";
  }

  void unregisterTriggers() {
    _element.removeEventListener(triggers['show'], showTooltipBind);
    _element.removeEventListener(triggers['hide'], hideTooltipBind);
  }
 
  /**
   * Rendering function.
   */
  void render();
}