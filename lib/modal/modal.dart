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
    useShadowDom: false,
    //templateUrl: 'packages/angular_ui/modal/window.html'
    template: r'''
<div tabindex="-1" class="modal {{ windowClass }}"
    ng-style="{'z-index': '{{1050 + index*10}}', 'display': 'block'}" ng-click="close($event)">
    <div class="modal-dialog {{ sizeClass }}">
      <div class="modal-content">
        <content></content>
      </div>
    </div>
</div>'''
)
class ModalWindow implements AttachAware {

  @NgAttr('windowClass')
  String windowClass = '';

  @NgOneWay('preventAnimation')
  void set visible(bool value) {
    if (_modal._top != null) {
      _modal._top._visible = value;
    }
  }
  
  bool get visible => _modal._top == null ? false : _modal._top._visible;

  @NgOneWay('keyboard')
  bool keyboard = true;
  
  int _index = 0;
  @NgOneWay('index')
  void set index(int value) {
    _index = value;
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

  String _sizeClass = '';
  @NgAttr('size')
  void set size(String value) {
    if (value == 'lg' || value == 'sm') {
      _sizeClass = 'modal-$value';
    }
  }
  
  String get sizeClass => _sizeClass;

  dom.Element _element;
  Modal _modal;
  Timeout _timeout;

  ModalWindow(this._element, this._modal, this._timeout);

  void attach() {
    if (_element != null) {
      // wait 50ms such that .in is added after .fade
      _timeout.call(() {
        // trigger CSS transitions
        visible = true;
        // focus a freshly-opened modal
        _element.focus();
      }, delay:50);
    }
  }

  void close(dom.MouseEvent event) {
    if(!event.defaultPrevented) {
      if (_backdrop && !_staticBackdrop && event.currentTarget == event.target) {
        event.preventDefault();
        event.stopPropagation();
        _modal._top.dismiss('backdrop click');
      }
      if ((event.target as dom.Element).dataset['dismiss'] == 'modal') {
        event.preventDefault();
        event.stopPropagation();
        _modal._top.dismiss('dismiss click');
      }
    }
  }
}

/**
 * Modal Options.
 */
class ModalOptions {
  String windowClass;
  String size;
  bool preventAnimation;
  bool keyboard;
  String backdrop;
  String template;
  String templateUrl;

  ModalOptions({this.windowClass:'', this.size, this.preventAnimation:false,
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
  
  dom.Element get _modalElement => _element.querySelector('.modal');
  
  bool get _visible => _modalElement == null ? false : _modalElement.classes.contains('in');
  void set _visible(bool value) {
    if (_modalElement != null) {
      _modalElement.classes.toggle('in', value);
    }
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
  DirectiveInjector _injector;
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
        // Check is content valid from modal-window perspective
        if (content.contains('modal-window')) {
          throw new Exception("It is not allowing to have modal-window inside othermodal-window" );
        }
        // Add ModalWindow wrapper
        String html = "<modal-window";
        if (options.preventAnimation != null) html += " preventAnimation=\"${options.preventAnimation}\"";
        if (options.backdrop != null) html += " backdrop=\"${options.backdrop}\"";
        if (options.keyboard != null) html += " keyboard=\"${options.keyboard}\"";
        if (options.windowClass != null) html += " windowClass=\"${options.windowClass}\"";
        if (options.size != null) html += " size=\"${options.size}\"";
        html += ">$content</modal-window>";
        //
        List<dom.Element> rootElements = toNodeList(html);

        instance._element = rootElements.firstWhere((el) {
            return el is dom.Element && el.tagName.toLowerCase() == "modal-window";
        });
        //
        _compiler(rootElements, _directiveMap)(scope, _injector, rootElements);
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
        // Start animation
        modalInstance._backDropElement.classes
          ..add("in");
        _timeout.call((){
          // Animation is done
          modalInstance._backDropElement.classes
            ..remove("fade");
        }, delay:250);
      }, delay:1);

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
      // I commented out the statement below because somtimes modalInstance doesn't contain 'in' class.
//      if (modalInstance._visible) {
        modalInstance._visible = false;
        modalInstance._element.attributes.remove("index");

        if(modalInstance._backDropElement != null) {
          modalInstance._backDropElement.classes
            ..add('fade')
            ..remove('in');
          _timeout.call(() {
            modalInstance._backDropElement.remove();
          }, delay:250);
        }
//      }
      openedWindows.remove(modalInstance);
      _timeout.call(() {
        modalInstance._element.remove();
        modalInstance = null;
      }, delay:250);
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
      // Temporary workaround https://github.com/akserg/angular.dart.ui/issues/139
      // regards https://github.com/angular-ui/bootstrap/issues/2970
      element.style.height = '${dom.document.body.scrollHeight}px';
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
