// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.modal;

import 'dart:async' as async;
import 'dart:html' as dom;
import "package:angular/angular.dart";
import 'package:angular_ui/utils/timeout.dart';
import 'package:angular_ui/utils/utils.dart';

/**
 * Modal Module.
 */
class ModalModule extends Module {
  ModalModule() {
    install(new TimeoutModule());
    bind(ModalWindow);
    bind(Modal);
  }
}

/**
 * Modal Window component.
 */
@Component(
    selector: 'modal-window',
    publishAs: 'm',
    useShadowDom: false,
    templateUrl: 'packages/angular_ui/modal/window.html')
@Component(
    selector: '[modal-window]',
    publishAs: 'm',
    useShadowDom: false,
    templateUrl: 'packages/angular_ui/modal/window.html')
class ModalWindow implements AttachAware {

  @NgAttr('windowClass')
  String windowClass = '';

  @NgOneWay('animate')
  bool animate = false;

  @NgOneWay('keyboard')
  bool keyboard = true;
  
  int _index = 0;
  @NgOneWay('index')
  void set index(int value) {
    _index = value;
    print('Index is $value');
  }
  
  int get index => _index;
  
  @NgAttr('backdrop')
  void set backdropAsString(String value) {
    if (value != null) {
      if (value == "static") {
        _backdrop = true;
        _staticBackdrop = true;
      } else {
        _backdrop = value == 'true' ? true : false;
        _staticBackdrop = false;
      }
    }
  }

  bool _backdrop = true;

  /** If false, clicking the backdrop closes the dialog. */
  bool _staticBackdrop = false;

  dom.Element _element;
  Modal _modal;

  ModalWindow(this._element, this._modal);

  void attach() {
    if (_element != null) {
      // trigger CSS transitions
      animate = true;
      // focus a freshly-opened modal
      _element.focus();
    }
  }

  void close(dom.MouseEvent event) {
    if(!event.defaultPrevented) {
      if ((_backdrop && !_staticBackdrop && (event.currentTarget == event.target ||
          (event.target as dom.Element).dataset['dismiss'] == 'modal'))) {
        event.preventDefault();
        event.stopPropagation();
        _modal._top.dismiss('backdrop click');
      }
    }
  }
}

/**
 * Modal Options.
 */
class ModalOptions {
  String windowClass;
  bool animate;
  bool keyboard;
  String backdrop;
  String template;
  String templateUrl;

  ModalOptions({this.windowClass:'', this.animate:true,
    this.keyboard:true, this.backdrop:'true', this.template, this.templateUrl});
}

/**
 * Type definition of close function.
 */
typedef void CloseHandler(result);
/**
 * Type definition of dismiss function.
 */
typedef void DismissHandler(String reason);

/**
 * Instance of modal window to manage [result]s and [close] and [dismiss] functions.
 */
class ModalInstance {
  dom.Element _backDropElement;
  dom.Element _element;
  
  async.Completer _resultCompleter;
  async.Completer _openCompleter;
  
  async.Future get result => _resultCompleter.future;
  async.Future get opened => _openCompleter.future;
  
  bool get _visible => _element.style.display == 'block';
  void set _visible(bool value) {
    _element.style.display = value ? 'block' : 'none';
  }
  
  CloseHandler close;
  DismissHandler dismiss;
}

/**
 * Modal service.
 */
@Injectable()
class Modal {
  static const _backdropClass = 'modal-backdrop';
  static List<ModalInstance> openedWindows = [];
  
  Timeout _timeout;
  TemplateCache _templateCache;
  Http _http;
  Compiler _compiler;
  Injector _injector;
  DirectiveMap _directiveMap;

  /**
   * Create new instance of Modal service.
   */
  Modal(this._compiler, this._timeout, this._templateCache, this._http, this._injector, this._directiveMap);
  
  /**
   * Open new modal window with [options] and optional [scope] and 
   * returns the [ModalInstance].
   */
  ModalInstance open(ModalOptions options, Scope scope) {
    assert(options != null);
    
    async.Completer resultCompleter = new async.Completer();
    async.Completer openCompleter = new async.Completer();
    
    ModalInstance instance = new ModalInstance()
      .._resultCompleter = resultCompleter
      .._openCompleter = openCompleter
      ..close = (result) { close(result); }
      ..dismiss = (String reason) { dismiss(reason); };
    
    async.Future<String> contentFuture = _getContent(template:options.template, templateUrl:options.templateUrl);

    contentFuture
      ..then((String content){
        var injector = _injector.createChild([new Module()..bind(Scope, toValue:scope)]);
        // Check is content valid from modal-window perspective
        if (content.contains('modal-window')) {
          throw new Exception("It is not allowing to have modal-window inside othermodal-window" );
        }
        // Add ModalWindow wrapper
        String html = "<modal-window";
        if (options.animate != null) html += " animate=\"${options.animate}\"";
        if (options.backdrop != null) html += " backdrop=\"${options.backdrop}\"";
        if (options.keyboard != null) html += " keyboard=\"${options.keyboard}\"";
        html += ">$content</modal-window>";
        //
        List<dom.Element> rootElements = toNodeList(html);
  
        instance._element = rootElements.firstWhere((el) {
          return el is dom.Element && el.tagName.toLowerCase() == "modal-window";
        });
        //
        _compiler(rootElements, _directiveMap)(injector, rootElements);
        //
        _show(instance, options);
        //
        dom.document.body.append(instance._element);
        //
        openCompleter.complete(true);
      })
      ..catchError((error) {
        openCompleter.completeError(error);
        resultCompleter.completeError(error);
      });
    
    // Cath exception in safe manner
    resultCompleter.future.catchError((error){});
    openCompleter.future.catchError((error){});
    
    return instance;
  }
  
  /**
   * Prepare [ModalInstance] to show with [options].   
   */
  void _show(ModalInstance modalInstance, ModalOptions options) {
    modalInstance._backDropElement = _createBackdrop(modalInstance._element.ownerDocument, options.backdrop);
    
    modalInstance._visible = true;
    modalInstance._element.attributes["index"] = "${openedWindows.length}";
    
    dom.document.onKeyDown.listen((dom.KeyboardEvent event) {
      if(!event.defaultPrevented) {
        if (event.keyCode == 27 && modalInstance != null && options.keyboard) {
          event.preventDefault();
          event.stopPropagation();
          dismiss("by escape");
        }
      }
    });
    
    if(modalInstance._backDropElement != null) {
      // Go backdrop to opaque
      modalInstance._backDropElement.classes
        ..remove("in")
          ..add("fade");

      _timeout.call((){
        // Add transparancy to backdrop
        modalInstance._backDropElement.classes
          ..remove("fade")
          ..add("in");
      }, delay:250);

      modalInstance._backDropElement.onClick.listen((dom.MouseEvent e) {
        // Call only backdrop on top element
        String backdrop = _top._element.attributes['backdrop'];
        if (backdrop != null && backdrop == 'true') {
          hide();
        }
      });
    }
    //
    openedWindows.add(modalInstance);
  }
  
  /**
   * Hide modal window. Developers must use [close] or [dismiss] methods to 
   * manage process of closing modal window.
   */
  void hide() {
    ModalInstance modalInstance = _top;
    
    if (modalInstance != null) {
      if (modalInstance._visible) {
        modalInstance._visible = false;
        modalInstance._element.attributes.remove("index");

        if(modalInstance._backDropElement != null) {
          modalInstance._backDropElement.classes.remove('in');
          modalInstance._backDropElement.remove();
        }
      }
      openedWindows.remove(modalInstance);
      modalInstance._element.remove();
      modalInstance = null;
    }
  }
  
  /**
   * Close top modal window with [result].
   */
  void close(result) {
    ModalInstance modalInstance = _top;
    
    if (modalInstance != null) {
      if (modalInstance._visible) {
        modalInstance._resultCompleter.complete(result);
      }
    }
    hide();
  }

  /**
   * Dismiss top modal window with optional [reason].
   */
  void dismiss([reason = '']) {
    ModalInstance modalInstance = _top;
    
    if (modalInstance != null) {
      if (modalInstance._visible) {
        modalInstance._resultCompleter.completeError(reason);
      }
    }
    hide();
  }
  
  /*****************/
  
  /**
   * Return topmost [ModalInstance] or null.
   */
  ModalInstance get _top => openedWindows.length > 0 ? openedWindows[openedWindows.length - 1] : null;
  
  /**
   * That method creates backdrop on html page depends on value in [addIfMissing] 
   * which can be equals "true", "false" and "static".
   */
  dom.Element _createBackdrop(dom.HtmlDocument parentDocument, String addIfMissing) {
    assert(parentDocument != null);

    dom.Element element;
    if(addIfMissing == 'static' || addIfMissing == 'true') {
      element = new dom.DivElement()
        ..style.zIndex = '${1040 + openedWindows.length*10}'
        ..classes.add(_backdropClass);
      parentDocument.body.append(element);
    }
    return element;
  }
  
  /*****************/
  
  /**
   * Get content in future from [template] or loaded from [templateUrl].
   */
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
}