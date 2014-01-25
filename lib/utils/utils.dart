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