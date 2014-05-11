// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.utils;

import 'dart:html' as dom;
import 'package:intl/intl.dart' as intl;
import "package:angular/angular.dart";

part 'ng_pseudo.dart';

bool toBool(x) {
  if (x is bool) return x;
  if (x is num) return x != 0;
  if (x is String) return (x as String).toLowerCase() == "true";
  return false;
}

int toInt(x) {
  if (x is int) return x;
  if (x is String) return int.parse(x);
  throw new Exception("Can't translate $x to int");
}

dynamic eval(Scope scope, value, [defaultValue = null]) {
  var val = null;
  if (value != null) {
    val = scope.eval(value is String ? value : value.toString());
  }
  return val != null ? val : defaultValue;
}

dom.Element getFirstDiv(dom.DocumentFragment doc) => doc.children.firstWhere(isDiv);

bool isDiv(dom.Element element) => element is dom.DivElement;

dom.Element getFirstUList(dom.DocumentFragment doc) => doc.children.firstWhere(isUList);

bool isUList(dom.Element element) => element is dom.UListElement;

/**
 * Convert an [html] String to a [List] of [Element]s.
 */
List<dom.Element> toNodeList(html) {
  var div = new dom.DivElement();
  div.setInnerHtml(html, treeSanitizer: new NullTreeSanitizer());
  var nodes = [];
  for(var node in div.nodes) {
    nodes.add(node);
  }
  return nodes;
}

// Split array into smaller arrays
List split(List arr, int size) {
  var arrays = [];
  for (int b = 0, e = size;;b += size, e += size) {
    if (e < arr.length) {
      arrays.add(arr.getRange(b, e).toList());
    } else {
      arrays.add(arr.getRange(b, arr.length).toList());
      break;
    }
  }
  return arrays;
}

/**
 * Try treat [model] as [String], [int] or [DateTime] to convert to [DateTime]
 * or return null. If specified the [DateFormat] will be used to parse date.
 */
DateTime parseDate(model, [intl.DateFormat format = null]) {
  DateTime date;
  
  if (model != null) {
    try {
      if (model is String) {
        if (format != null) {
          date = format.parse(model);
        } else {
          date = DateTime.parse(model);
        }
      } else if (model is int) {
        date = new DateTime.fromMillisecondsSinceEpoch(model);
      } else {
        date = model as DateTime;
      }
    } on Exception catch(e) {
      print(e);
    }
  }
  return date;
}

/**
 * Use to compile HTML and activate its directives.
 *
 * If [html] parameter is:
 *
 *   - [String] then treat it as HTML
 *   - [Node] then treat it as the root node
 *   - [List<Node>] then treat it as a collection of nods
 *
 * After the compilation the [rootElements] contains an array of compiled root nodes,
 * and [rootElement] contains the first element from the [rootElemets].
 *
 * An option [scope] parameter can be supplied to link it with non root scope.
 */
dom.Element compile(html, Injector injector, Compiler compiler, {Scope scope, DirectiveMap directives}) {
  List<dom.Node> rootElements;
  if (scope != null) {
    injector = injector.createChild([new Module()..value(Scope, scope)]);
  }
  if (html is String) {
    rootElements = toNodeList(html.trim());
  } else if (html is dom.Node) {
    rootElements = [html];
  } else if (html is List<dom.Node>) {
    rootElements = html;
  } else {
    throw 'Expecting: String, Node, or List<Node> got $html.';
  }
  dom.Element rootElement = rootElements.length > 0 && rootElements[0] is dom.Element ? rootElements[0] : null;
  if (directives == null) {
    directives = injector.get(DirectiveMap);
  }
  View rootView = compiler(rootElements, directives)(injector, rootElements);
  return rootElement;
}
  
/**
 * Split camel case [input] words and join with spases in between.
 */
String splitByCamelCasing(String input) {
  RegExp r = new RegExp(r"(?=[A-Z])");
  List<Match> matches = r.allMatches(input).toList();
  List<String> splitInput;
//  if (matches.length > 0) {
//    splitInput = new List<String>.generate(matches.length, (int index) {
//      return matches[index].group(0);
//    });
//  } else {
    splitInput = [input];
//  }
  // Check is first letter of first word capital and fix it
  if (splitInput.length > 0 && splitInput.first.length > 0) {
    String word = splitInput[0];
    splitInput[0] = word[0].toUpperCase() + word.substring(1);
  }

  return splitInput.join(" ");
}

