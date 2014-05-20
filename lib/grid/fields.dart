// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please seegriddropdown_toggle;
part of angular.ui.grid;

class Fields {
  
  FieldGetterFactory _fieldGetterFactory;
  
  Fields(this._fieldGetterFactory);
  
  String getField(item, String name) {
    var val;
    if (item is Map) {
      val = item[name];
    } else if (item is List) {
      val = item.toString();
    } else {
      Function itemGetter = _fieldGetterFactory.getter(item, name);
      val = itemGetter(item);
    }
    
    return val == null ? '' : val.toString();
  }
}