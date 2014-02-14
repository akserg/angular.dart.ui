// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.utils;

import 'dart:html' as dom;
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

dom.Element getFirstDiv(dom.DocumentFragment doc) => doc.children.firstWhere(isDiv);

bool isDiv(dom.Element element) => element is dom.DivElement;

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