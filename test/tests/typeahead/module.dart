library angular.ui.typeahead.tests;

import 'dart:html' as dom;

import '../../_specs.dart';
import 'package:angular_ui/utils/utils.dart';
import 'package:angular_ui/typeahead/module.dart';

import 'package:angular/core/module_internal.dart';

part 'typeahead_parser_tests.dart';
part 'typeahead_highlight_tests.dart';
part 'typeahead_popup_tests.dart';
part 'typeahead_tests.dart';

void typeaheadTests() {
  describe('syntax parser', typeaheadParserTests);
  describe('highlight filter', typeaheadHighlightFilterTests);
  describe('typeaheadPopup', typeaheadPopupTests);
  describe('typeahead', typeaheadComponentTests);
}

/**
 * It adds an html template into the TemplateCache.
 */
void addToTemplateCache(TemplateCache cache, String path) {
  dom.HttpRequest request = new dom.HttpRequest();
  request.open("GET", path, async : false);
  request.send();
  cache.put(path, new HttpResponse(200, request.responseText));
}