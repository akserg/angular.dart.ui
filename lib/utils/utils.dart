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