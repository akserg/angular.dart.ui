library angular.ui.typeahead;

import 'dart:html' as dom;
import 'dart:async';
import 'dart:math';

import 'package:angular/angular.dart';
import 'package:angular/core/module_internal.dart';

import 'package:angular_ui/utils/utils.dart';
import 'package:angular_ui/utils/position.dart';

part 'typeahead_parser.dart';
part 'typeahead_highlight.dart';
part 'typeahead_popup.dart';
part 'typeahead_decorator.dart';

class TypeaheadModule extends Module {

  TypeaheadModule() {
    type(TypeaheadParser);
    type(TypeaheadHighlightFilter);
    type(TypeaheadMatch);
    type(TypeaheadPopup);
    type(TypeaheadDecorator);
  }
}