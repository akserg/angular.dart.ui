// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.modal;

import 'dart:async' as async;
import 'dart:html' as dom;
import "package:angular/angular.dart";

import 'package:angular_ui/timeout.dart';
import 'package:angular_ui/utils/compile.dart';

/**
 * Modal Module.
 */
class ModalModule extends Module {
  ModalModule() {
    type(ModalWindow);
    type(Modal);
  }
}

/**
 * Modal Window component.
 */
@NgComponent(
    selector: 'modal-window', 
    publishAs: 'm', 
    applyAuthorStyles: true, 
    templateUrl: 'packages/angular_ui/modal/modal.html')
@NgComponent(
    selector: '[modal-window]', 
    publishAs: 'm', 
    applyAuthorStyles: true, 
    templateUrl: 'packages/angular_ui/modal/modal.html')
class ModalWindow implements NgAttachAware {
  
  @NgAttr('windowClass')
  String windowClass = '';
  
  @NgOneWay('animate')
  bool animate = false;
  
  @NgOneWay('keyboard')
  bool keyboard = true;
  
  @NgAttr('backdrop')
  void set backdropAsString(String value) {
    if (value != null) {
      if (value == "static") {
        backdrop = true;
        staticBackdrop = true;
      } else {
        backdrop = value == 'true' ? true : false;
        staticBackdrop = false;
      }
    }
  }
  
  bool backdrop = true;
  
  /** If false, clicking the backdrop closes the dialog. */
  bool staticBackdrop = false;
  
  @NgTwoWay('shown')
  bool shown = false;
  
  dom.Element _element;
  dom.Element get element => _element;
  Modal _modal;
  async.Completer completer;
  
  ModalWindow(this._element, this._modal) {
    _modal.register(_element, this);
  }
  
  void attach() {
    if (_element != null) {
      if (shown) {
        // trigger CSS transitions
        animate = true;
        // focus a freshly-opened modal
        _element.focus(); 
      } else {
        hide();
      }
    }
  }
  
  void close(dom.MouseEvent event) {
    if(!event.defaultPrevented) {
      final dom.Element target = event.target as dom.Element;
      if(target != null && target.dataset['dismiss'] == 'modal') {
        _modal.dismiss('backdrop click');
      }
    }
  }
  
  void onBackdropClicked() {
    if (!staticBackdrop) {
      _modal.hide();
    }
  }
  
  void hide() {
    shown = false;
    _element.style.display = "none";
  }

  void show() {
    shown = true;
    _element.style.display = "block";
  }
}

/**
 * Modal Options.
 */
class ModelOptions extends Expando {
  String windowClass = '';
  bool animate = false;
  bool keyboard = true;
  bool backdrop = true;
  bool shown = false;
}

typedef void CloseHandler(result);
typedef void DismissHandler(String reason);

class ModalInstance {
  final ModalWindow window;
  async.Future result;
  CloseHandler close;
  DismissHandler dismiss;
  
  ModalInstance(this.window);
}

/**
 * Modal service.
 */
@NgInjectableService()
class Modal {
  static const _backdropClass = 'modal-backdrop';
  static Map<dom.Element, ModalWindow> _windows = {};
  
  ModalInstance modalInstance;
  async.Completer completer;
  
  Compile _compile;
  Timeout _timeout;
  TemplateCache templateCache;
  Http http;
  Compiler compiler;
  Injector injector;
  
  Modal(this.compiler, this._timeout, this.templateCache, this.http, this.injector);
  
  void register(dom.Element element, ModalWindow window) {
    _windows[element] = window;
  }
  
  async.Future<dom.Element> open({String template:null, String templateUrl:null, Scope scope:null}) {
    async.Completer completer = new async.Completer();
    getTemplate(template:template, templateUrl:templateUrl).then((String content){
      
      var injector = this.injector;
      if(scope != null) {
        injector = injector.createChild([new Module()..value(Scope, scope)]);
      }
      //
      List<dom.Element> rootElements = toNodeList(content);

      dom.Element rootElement = rootElements.firstWhere((el) { 
        return el is dom.Element && el.tagName.toLowerCase() == "modal-window";
      });
      //
      compiler(rootElements)(injector, rootElements);
      //
      dom.document.body.append(rootElement);
      //
      completer.complete(rootElement);
    }, onError:(error) {
      completer.completeError(error);
    });
    return completer.future;
  }
  
  ModalInstance show(dom.Element element) {
    assert(element != null);
    if (modalInstance == null) {
      completer = new async.Completer();
      modalInstance = new ModalInstance(_windows[element])
        ..result = completer.future
        ..close = (result) { close(result); }
        ..dismiss = (String reason) { dismiss(reason); };
        
      final backDropElement = _getBackdrop(element.ownerDocument, modalInstance.window.backdrop);
      
      modalInstance.window.show();
      
      dom.document.onKeyUp.listen((dom.KeyboardEvent evt) {
        if (evt.keyCode == 27 && modalInstance != null && modalInstance.window.keyboard) {
          dismiss("by escape");
        }
      });
      
      if(backDropElement != null) {
        // Go backdrop to opaque
        backDropElement.classes
          ..remove("in")
          ..add("fade");
    
        _timeout.call((){
          // Add transparancy to backdrop
          backDropElement.classes
            ..remove("fade")
            ..add("in");
        }, delay:250);
        
        if (modalInstance.window.onBackdropClicked != null) {
          backDropElement.onClick.listen((args) => modalInstance.window.onBackdropClicked());
        }
      }
    } else if (modalInstance.window != null && modalInstance.window.element != element) {
      throw new Exception("Only one instance of ModalWindow can be shown");
    }
    return modalInstance;
  }
  
  void hide() {
    if (modalInstance != null) {
  
      if (modalInstance.window.shown) {
        
        final backDropElement = _getBackdrop(modalInstance.window.element.ownerDocument, false);
  
        modalInstance.window.hide();
  
        if(backDropElement != null) {
          backDropElement.classes.remove('in');
        }
  
        _clearOutBackdrop(modalInstance.window.element.ownerDocument);
        
        modalInstance = null;
      }
    }
  }
  
  void _clearOutBackdrop(dom.HtmlDocument doc) {
    final backdrop = _getBackdrop(doc, false);
    
    if(backdrop != null) {
      backdrop.remove();
    }
  }

  dom.Element _getBackdrop(dom.HtmlDocument parentDocument, bool addIfMissing) {
    assert(parentDocument != null);

    dom.Element element = parentDocument.body.querySelector(".${_backdropClass}");
    if(element == null && addIfMissing) {
      element = new dom.DivElement()
        ..classes.add(_backdropClass);
      parentDocument.body.append(element);
    }
    return element;
  }
  
  void close(result) {
    if (modalInstance != null && modalInstance.window.shown) {
      completer.complete(result);
      hide();
    }
  }
  
  void dismiss([reason = '']) {
    if (modalInstance != null && modalInstance.window.shown) {
      completer.completeError(reason);
      hide();
    }
  }
  
  async.Future getTemplate({String template:null, String templateUrl:null}) {
    if (template == null && templateUrl == null) {
      throw new Exception('One of template or templateUrl options is required.');
    }
    if (template != null) {
      async.Completer def = new async.Completer()..complete(template);
      return def.future;
    } else {
      return http.get(templateUrl, cache: templateCache).then((result) => result.data);
    }
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