// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void modalTests() {
  
  describe("Testing Modals. Basic scenarios with default options", () {
    TestBed _;
    Scope scope, rootScope;
    dom.Element element;
    TemplateCache cache;
    Timeout timeout;
    Modal modal;
    
    beforeEach(setUpInjector);
    beforeEach(module((Module module) {
      module.install(new ModalModule());
    }));
    beforeEach(inject((TestBed tb) => _ = tb));
    beforeEach(inject((Scope s) { 
      scope = s;
      rootScope = s.$root;
      //
      
    }));
    beforeEach(inject((Timeout t) => timeout = t));
    beforeEach(inject((TemplateCache c) {
      cache = c;
      cache.put('packages/angular_ui/modal/window.html', new HttpResponse(200, '<div tabindex="-1" class="modal {{ m.windowClass }}" ng-class="{in: m.animate.toString()}" ng-style="{\'z-index\': \'1050\', \'display\': \'block\'}" ng-click="m.close(\$event)"> <div class="modal-dialog"> <div class="modal-content"> <content></content> </div> </div> </div>'));
    }));
    beforeEach(inject((Modal m) => modal = m));
    
    afterEach(tearDownInjector);
    
    // Trigger / listen for event on document.body
    void triggerKeyDown(dom.EventTarget element, int keyCode) {
      var streamDown = KeyEvent.keyUpEvent.forTarget(element);
      var subscription4 = streamDown.listen(
          (e) => print('streamDown listener ${e.keyCode}'));
      streamDown.add(new KeyEvent('keydown', keyCode: keyCode));
    };
    
    void houskeepking() {
      var el = document.body.querySelector("modal-window");
      if (el != null) {
        el.remove();
      };
    }
    
    bool toHaveModalOpen() {
      var el = document.body.querySelector("modal-window");
      return el.style.display == 'block';
    }
    
    bool toHaveModalOpenWithContent(dom.Element el, {String content:'', String selector:null}) {
      if (selector != null) {
        el = el.querySelector(selector);
      }
      return el.innerHtml == content;
    }
    
    bool toHaveBackdrop() => document.body.querySelector('.modal-backdrop') != null;
    
    void close(result) {
      modal.close(result);
      rootScope.$digest();
    }

    void dismiss(String reason) {
      modal.dismiss(reason);
      timeout.flush();
      rootScope.$digest();
    }
    
    it('should open and dismiss a modal with a minimal set of options', () {
      Future<dom.Element> f = modal.create(new ModalOptions(template: '<div>Content</div>'));
      f.then((el) {
        modal.show(el);
        //
        expect(toHaveModalOpen()).toBeTruthy();
        expect(toHaveModalOpenWithContent(el, content:'Content', selector:'div')).toBeTruthy();
        expect(toHaveBackdrop()).toBeTruthy();
        //
        dismiss('closing in test');
        //
        expect(toHaveModalOpen()).toBeFalsy();
        expect(toHaveBackdrop()).toBeFalsy();
        //
        houskeepking();
      });
      expect(f, completes);
    });
    
    it('should open a modal from templateUrl', () {
      cache.put('content.html', new HttpResponse(200, '<div>URL Content</div>'));
      
      Future<dom.Element> f = modal.create(new ModalOptions(templateUrl: 'content.html'));
      f.then((el) {
        modal.show(el);
        //
        expect(toHaveModalOpen()).toBeTruthy();
        expect(toHaveModalOpenWithContent(el, content:'URL Content', selector:'div')).toBeTruthy();
        expect(toHaveBackdrop()).toBeTruthy();
        //
        dismiss('closing in test');
        //
        expect(toHaveModalOpen()).toBeFalsy();
        expect(toHaveBackdrop()).toBeFalsy();
        //
        houskeepking();
      });
      expect(f, completes);
    });
    
    it('should support closing on backdrop click', () {
      Future<dom.Element> f = modal.create(new ModalOptions(template: '<div>Content</div>'));
      f.then((el) {
        modal.show(el);
        //
        expect(toHaveModalOpen()).toBeTruthy();
        // Trigger click event on backdrop
        _.triggerEvent(document.body.querySelector('.modal-backdrop'), 'click');
        timeout.flush();
        rootScope.$digest();
        //
        expect(toHaveModalOpen()).toBeFalsy();
        expect(toHaveBackdrop()).toBeFalsy();
        //
        houskeepking();
      });
      expect(f, completes);
    });
    
    it('should resolve returned promise on close', () {
      Future<dom.Element> f = modal.create(new ModalOptions(template: '<div>Content</div>'));
      f.then((el) {
        ModalInstance inst = modal.show(el);
        expect(inst.result, completion(equals('closed ok')));
        //
        close('closed ok');
        //
        houskeepking();
      });
      expect(f, completes);
    });
    
    it('should reject returned promise on dismiss', () {
      Future<dom.Element> f = modal.create(new ModalOptions(template: '<div>Content</div>'));
      f.then((el) {
        ModalInstance inst = modal.show(el);
        expect(inst.result, throwsA(equals('esc')));
        //
        dismiss('esc');
        //
        houskeepking();
      });
      expect(f, completes);
    });
    
    it('should not have any backdrop element if backdrop set to false', () {
      Future<dom.Element> f = modal.create(new ModalOptions(template: '<div>No backdrop</div>', backdrop: 'false'));
      f.then((el) {
        modal.show(el);
        
        expect(toHaveModalOpen()).toBeTruthy();
        expect(toHaveBackdrop()).toBeFalsy();
        //
        houskeepking();
      });
      expect(f, completes);
    });
    
    it('should not close modal on backdrop click if backdrop is specified as "static"', () {
      Future<dom.Element> f = modal.create(new ModalOptions(template: '<div>Content</div>', backdrop: 'static'));
      f.then((el) {
        modal.show(el);
        
        expect(toHaveModalOpen()).toBeTruthy();
        // Trigger click event on backdrop
        _.triggerEvent(document.body.querySelector('.modal-backdrop'), 'click');
        timeout.flush();
        rootScope.$digest();
        //
        expect(toHaveModalOpen()).toBeTruthy();
        expect(toHaveBackdrop()).toBeTruthy();
        //
        houskeepking();
      });
      expect(f, completes);
    });
    
  });
}
