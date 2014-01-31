library angular.ui.helper.extend;

Map extend(Map dst, List<Map> src) {
  var tmpSrc = new List<Map>.from(src);

  while(tmpSrc.length > 0) {
    if(tmpSrc[0] != null) {
      tmpSrc[0].forEach((k, v) {
        if(v != null) {
          dst[k] = copy(v);
        }
      });
    }
    tmpSrc.removeAt(0);
  }
  return dst;
}

dynamic copy(source, [destination]) {
  var dst;
  if(destination != null) {
    if(source is List) {
      dst = new List();
      source.forEach((e) => dst.add(copy(e, dst)));
    } else if(source is Map) {
      dst = new Map();
      source.forEach((k, v) => dst[k] = copy(v));
    } else {
      return source;
    }
  } else {
    if(source is List) {
      dst = [];
      source.forEach((e) => dst.add(copy(e, dst)));
    } else if(source is Map) {
      dst = {};

      source.forEach((k, v) => dst[k] = copy(v));
    } else {
      return source;
    }
  }
  return dst;
}