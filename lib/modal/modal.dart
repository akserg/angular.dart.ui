// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.modal;

import 'dart:async' as async;
import 'dart:html' as dom;
import "package:angular/angular.dart";

import 'package:angular_ui/timeout.dart';

/**
 * Modal Module.
 */
class ModalModule extends Module {
  ModalModule() {
    install(new TimeoutModule());
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
    templateUrl: 'packages/angular_ui/modal/window.html')
@NgComponent(
    selector: '[modal-window]',
    publishAs: 'm',
    applyAuthorStyles: true,
    templateUrl: 'packages/angular_ui/modal/window.html')
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

  bool _visible = false;

  @NgTwoWay('show')
  void set visible(bool value) {
    _visible = value;
    if (value) {
      _visible = true;
      _element.style.display = "block";
    } else {
      _visible = false;
      _element.style.display = "none";
    }
  }

  bool get visible => _visible;

  dom.Element _element;
  dom.Element get element => _element;
  Modal _modal;

  ModalWindow(this._element, this._modal) {
    _modal._register(_element, this);
  }

  void attach() {
    if (_element != null) {
      if (_visible) {
        // trigger CSS transitions
        animate = true;
        // focus a freshly-opened modal
        _element.focus();
      } else {
        visible = false;
      }
    }
  }

  void close(dom.MouseEvent event) {
    if(!event.defaultPrevented) {
      if ((backdrop && !staticBackdrop && (event.currentTarget == event.target ||
          (event.target as dom.Element).dataset['dismiss'] == 'modal'))) {
        _modal.dismiss('backdrop click');
      }
    }
  }

  void _onBackdropClicked() {
    if (!staticBackdrop) {
      _modal.hide();
    }
  }
}

/**
 * Modal Options.
 */
class ModalOptions extends Expando {
  String windowClass;
  bool animate;
  bool keyboard;
  String backdrop;
  String template;
  String templateUrl;

  ModalOptions({this.windowClass:'', this.animate:true,
    this.keyboard:true, this.backdrop:'true', this.template, this.templateUrl});
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

  Timeout _timeout;
  TemplateCache _templateCache;
  Http _http;
  Compiler _compiler;
  Injector _injector;
  DirectiveMap _directiveMap;

  Modal(this._compiler, this._timeout, this._templateCache, this._http, this._injector, this._directiveMap);

  void _register(dom.Element element, ModalWindow window) {
    _windows[element] = window;
  }

  async.Future<dom.Element> create(ModalOptions options, {Scope scope:null}) {
    async.Completer createCompleter = new async.Completer();
    _getContent(template:options.template, templateUrl:options.templateUrl).then((String content){

      var injector = this._injector;
      if(scope != null) {
        injector = injector.createChild([new Module()..value(Scope, scope)]);
      }
      // Check is content valid from modal-window perspective
      if (content.contains('modal-window')) {
        throw new Exception("It is not allowing to have 'modal-window' in content of modal-window" );
      }
      // Add ModalWindow wrapper
      String html = "<modal-window";
      if (options.animate != null) html += " animate=\"${options.animate}\"";
      if (options.backdrop != null) html += " backdrop=\"${options.backdrop}\"";
      if (options.keyboard != null) html += " keyboard=\"${options.keyboard}\"";
      html += ">$content</modal-window>";
      //
      List<dom.Element> rootElements = _toNodeList(html);

      dom.Element rootElement = rootElements.firstWhere((el) {
        return el is dom.Element && el.tagName.toLowerCase() == "modal-window";
      });
      //
      _compiler(rootElements, _directiveMap)(injector, rootElements);
      //
      dom.document.body.append(rootElement);
      //
      createCompleter.complete(rootElement);
    }, onError:(error) {
      createCompleter.completeError(error);
    });
    return createCompleter.future;
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

      modalInstance.window.visible = true;

      dom.document.onKeyDown.listen((dom.KeyboardEvent evt) {
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

        if (modalInstance.window._onBackdropClicked != null) {
          backDropElement.onClick.listen((args) => modalInstance.window._onBackdropClicked());
        }
      }
      // Cath exception in safe manner
      completer.future.catchError((error){});
    } else if (modalInstance.window != null && modalInstance.window.element != element) {
      throw "Only one instance of ModalWindow can be shown";
    }
    return modalInstance;
  }

  void hide() {
    if (modalInstance != null) {

      if (modalInstance.window.visible) {

        final backDropElement = _getBackdrop(modalInstance.window.element.ownerDocument, false);

        modalInstance.window.visible = false;

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
    if (modalInstance != null && modalInstance.window.visible) {
      completer.complete(result);
      hide();
    }
  }

  void dismiss([reason = '']) {
    if (modalInstance != null && modalInstance.window.visible) {
      completer.completeError(reason);
      hide();
    }
  }

  async.Future _getContent({String template:null, String templateUrl:null}) {
    if (template == null && templateUrl == null) {
      throw new Exception('One of template or templateUrl options is required.');
    }
    if (template != null) {
      async.Completer def = new async.Completer()..complete(template);
      return def.future;
    } else {
      return _http.get(templateUrl, cache: _templateCache).then((result) => result.data);
    }
  }

  /**
   * Convert an [html] String to a [List] of [Element]s.
   */
  List<dom.Element> _toNodeList(html) {
    var div = new dom.DivElement();
    div.setInnerHtml(html, treeSanitizer: new NullTreeSanitizer());
    var nodes = [];
    for(var node in div.nodes) {
      nodes.add(node);
    }
    return nodes;
  }
}