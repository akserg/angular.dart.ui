library angular.ui.utils;

bool toBool(x) {
  if (x is bool) return x;
  if (x is num) return x != 0;
  if (x is String) return (x as String).toLowerCase() == "true";
  return false;
}