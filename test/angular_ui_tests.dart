// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

library angular_ui_test;

import 'package:guinness/guinness_html.dart';
import 'dart:async';
import 'dart:html' as dom;

import 'package:angular/angular.dart';
import 'package:angular/mock/module.dart';
import 'package:angular/mock/test_injection.dart';

import 'package:angular_ui/buttons/buttons.dart';

part 'unit/buttons/checkbox_component_test.dart';
part 'unit/buttons/radiobutton_component_test.dart';

main(){
  guinnessEnableHtmlMatchers();

  testCheckboxComponent();
  testRadiobuttonComponent();

  guinness.initSpecs();
}

loadTemplates(List<String> templates){
  updateCache(template, response) => inject((TemplateCache cache) => cache.put(template, response));

  final futures = templates.map((template) =>
    dom.HttpRequest.request('packages/angular_ui' + template.substring(4), method: "GET").
    then((_) => updateCache(template, new HttpResponse(200, _.response))));

  return Future.wait(futures);
}

compileComponent(String html, Map scope, callback){
  return async(() {
    inject((TestBed tb) {
      final s = tb.rootScope.createChild(scope);
      final el = tb.compile('<div>$html</div>', scope: s);

      microLeap();
      digest();

      callback(s, el);
    });
  });
}

digest(){
  inject((TestBed tb) { tb.rootScope.apply(); });
}
