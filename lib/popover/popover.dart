// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.popover;

import 'dart:html' as dom;
import "package:angular/angular.dart";
import "package:angular/core_dom/module_internal.dart";
import 'package:angular_ui/tooltip/tooltip.dart';
import 'package:angular_ui/utils/timeout.dart';
import 'package:angular_ui/utils/position.dart';
import 'package:angular_ui/utils/utils.dart';

/**
 * Popover Module.
 */
class PopoverModule extends Module {
  PopoverModule() {
    install(new TooltipModule());
    bind(Popover);
  }
}

@Decorator(selector:'[popover]') 
//@Component(selector:'popover', useShadowDom: false)
class Popover extends TooltipBase {
  
  var template = '<div><div class="arrow"></div><div class="popover-inner"><h3 class="popover-title"></h3><div class="popover-content"></div></div></div>';
  
  dom.Element _popoverTitle;
  dom.DivElement _popoverContent;
  
  Popover(dom.Element element, NodeAttrs attrs, Timeout timeout, TooltipConfig config, Interpolate interpolate, Position position, Injector injector, Compiler compiler) : 
    super("popover", 'popover', 'click', element, attrs, timeout, config, interpolate, position, injector, compiler);
  
  @override
  void createTooltip() {
    super.createTooltip();
    //
    _popoverTitle = tooltip.querySelector(".popover-title");
    _popoverContent = tooltip.querySelector(".popover-content");
  }
  
  void render() {
    tooltip.classes.clear();
    tooltip.classes.add('popover');
    //
    var _placement = tt_placement;
    if (_placement != null && _placement.length > 0) {
      tooltip.classes.add(_placement);
    }
    //
    var _in = toBool(eval(scope, tt_isOpen));
    if (_in) {
      tooltip.classes.add('in');
    }
    //
    var _fade = toBool(eval(scope, tt_animation));
    if (_fade) {
      tooltip.classes.add('fade');
    }
    //
    String txt;
    if (_popoverTitle != null) {
      txt = tt_title;
      if (txt != null && txt.trim().length > 0) {
        _popoverTitle.setInnerHtml(txt);
        _popoverTitle.classes.remove('ng-hide');
      } else {
        _popoverTitle.classes.add('ng-hide');
      }
    } else {
      _popoverTitle.classes.add('ng-hide');
    }
    if (_popoverContent != null) {
      txt = tt_content;
      _popoverContent.setInnerHtml(txt == null ? '' : txt);
    }
  }
}

