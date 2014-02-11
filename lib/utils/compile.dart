// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.compile;

import 'dart:html' as dom;
import "package:angular/angular.dart";
import 'package:angular_ui/utils/injectable_service.dart';

/**
 * Compile Module.
 */
class CompileModule extends Module {
  CompileModule() {
    type(Compile);
  }
}


/**
 * This is copy of TestBed class without some methods.
 */
@InjectableService()
class Compile {

  final Injector injector;
  final Scope rootScope;
  final Compiler compiler;
  final Parser parser;

  dom.Element rootElement;
  List<dom.Node> rootElements;
  Block rootBlock;

  Compile(this.injector, this.rootScope, this.compiler, this.parser);

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
  dom.Element call(html, {Scope scope}) {
    var injector = this.injector;
    if(scope != null) {
      injector = injector.createChild([new Module()..value(Scope, scope)]);
    }
    if (html is String) {
      rootElements = toNodeList(html);
    } else if (html is dom.Node) {
      rootElements = [html];
    } else if (html is List<dom.Node>) {
      rootElements = html;
    } else {
      throw 'Expecting: String, Node, or List<Node> got $html.';
    }
    rootElement = rootElements[0];
    rootBlock = compiler(rootElements)(injector, rootElements);
    return rootElement;
  }

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
}