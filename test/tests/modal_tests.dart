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
    
    beforeEach(() {
      setUpInjector();
      module((Module module) {
        module.install(new ModalModule());
      });
      inject((TestBed tb, Modal m, Timeout t, Scope s, TemplateCache c) { 
        _ = tb;
        modal = m;
        timeout = t;
        //
        scope = s;
        rootScope = s.rootScope;
        //
        cache = c;
        addToTemplateCache(cache, 'packages/angular_ui/modal/window.html');
      });
    });

    afterEach(tearDownInjector);
    
    /**
     * Trigger / listen for event on dom.document.body.
     * Seems doesn't work at all. Need to find the way how fire keyboard events.
     */
    void triggerKeyDown(dom.EventTarget element, int keyCode) {
      var streamDown = dom.KeyEvent.keyUpEvent.forTarget(element);
      var subscription4 = streamDown.listen(
          (e) => print('streamDown listener ${e.keyCode}'));
      streamDown.add(new dom.KeyEvent('keydown', keyCode: keyCode));
    };
    
    void houskeepking() {
      dom.document.body.querySelectorAll("modal-window").forEach((el) {
        modal.hide();
        el.remove();
      });
    }
    
    bool toHaveModalOpenWithContent({String content:'', String selector:null}) {
      return dom.document.body.querySelectorAll("modal-window").any((dom.Element el) {
        if (el.style.display == 'block') {
          if (selector != null) {
            el = el.querySelector(selector);
          }
          if (el.innerHtml.contains(content)) {
            return true;
          }
        }
        return false;
      });
    }
    
    bool toHaveBackdrop() => dom.document.body.querySelector('.modal-backdrop') != null;
    
    int toHaveModalOpen() {
      int res = 0;
      dom.document.body.querySelectorAll("modal-window").forEach((dom.Element el){
        if (el.style.display == 'block') {
          res++;
        }
      });
      return res;
    }
    
    void close(result) {
      modal.close(result);
      rootScope.rootScope.apply();
    }

    void dismiss(String reason) {
      modal.dismiss(reason);
      timeout.flush();
      rootScope.rootScope.apply();
    }
    
    void clickOnBackdrop() {
      // Find last backdrop
      dom.Element el = dom.document.body.querySelectorAll('.modal-backdrop').last;
      if (el != null) {
        _.triggerEvent(el, 'click');
        timeout.flush();
        rootScope.rootScope.apply();
      }
    }
    
    it('should open and dismiss a modal with a minimal set of options', () {
      ModalInstance inst = modal.open(new ModalOptions(template:"<div>Content</div>"), scope);
      inst.opened.then((value) {
        //
        expect(toHaveModalOpen()).toEqual(1);
        expect(toHaveModalOpenWithContent(content:'Content', selector:'div')).toBeTruthy();
        expect(toHaveBackdrop()).toBeTruthy();
        //
        dismiss('closing in test');
        //
        expect(toHaveModalOpen()).toEqual(0);
        expect(toHaveBackdrop()).toBeFalsy();
        //
        houskeepking();
      });
      expect(inst.opened, completes);
    });
    
    it('should open a modal from templateUrl', () {
      cache.put('content.html', new HttpResponse(200, '<div>URL Content</div>'));
      
      ModalInstance inst = modal.open(new ModalOptions(templateUrl: 'content.html'), scope);
      inst.opened.then((value) {
        //
        expect(toHaveModalOpen()).toEqual(1);
        expect(toHaveModalOpenWithContent(content:'URL Content', selector:'div')).toBeTruthy();
        expect(toHaveBackdrop()).toBeTruthy();
        //
        dismiss('closing in test');
        //
        expect(toHaveModalOpen()).toEqual(0);
        expect(toHaveBackdrop()).toBeFalsy();
        //
        houskeepking();
      });
      expect(inst.opened, completes);
    });
    
    it('should support closing on backdrop click', () {
      ModalInstance inst = modal.open(new ModalOptions(template: '<div>Content</div>'), scope);
      inst.opened.then((value) {
        //
        expect(toHaveModalOpen()).toEqual(1);
        // Trigger click event on backdrop
        _.triggerEvent(dom.document.body.querySelector('.modal-backdrop'), 'click');
        timeout.flush();
        rootScope.rootScope.apply();
        //
        expect(toHaveModalOpen()).toEqual(0);
        expect(toHaveBackdrop()).toBeFalsy();
        //
        houskeepking();
      });
      expect(inst.opened, completes);
    });
    
    it('should resolve returned promise on close', () {
      ModalInstance inst = modal.open(new ModalOptions(template: '<div>Content</div>'), scope);
      inst.opened.then((value) {
        expect(inst.result, completion(equals('closed ok')));
        //
        close('closed ok');
        //
        houskeepking();
      });
      expect(inst.opened, completes);
    });
    
    it('should reject returned promise on dismiss', () {
      ModalInstance inst = modal.open(new ModalOptions(template: '<div>Content</div>'), scope);
      inst.opened.then((value) {
        expect(inst.result, throwsA(equals('esc')));
        //
        dismiss('esc');
        //
        houskeepking();
      });
      expect(inst.opened, completes);
    });
    
    it('should not have any backdrop element if backdrop set to false', () {
      ModalInstance inst = modal.open(new ModalOptions(template: '<div>No backdrop</div>', backdrop: 'false'), scope);
      inst.opened.then((value) {
        expect(toHaveModalOpen()).toEqual(1);
        expect(toHaveBackdrop()).toBeFalsy();
        //
        houskeepking();
      });
      expect(inst.opened, completes);
    });
    
    it('should not close modal on backdrop click if backdrop is specified as "static"', () {
      ModalInstance inst = modal.open(new ModalOptions(template: '<div>Content</div>', backdrop: 'static'), scope);
      inst.opened.then((value) {
        expect(toHaveModalOpen()).toEqual(1);
        // Trigger click event on backdrop
        clickOnBackdrop();
        //
        expect(toHaveModalOpen()).toEqual(1);
        expect(toHaveBackdrop()).toBeTruthy();
        //
        houskeepking();
      });
      expect(inst.opened, completes);
    });
    
    it('should close modal on button (with dismiss="modal") click if backdrop is specified as "static"', () {
      ModalInstance inst = modal.open(new ModalOptions(template: '<div>Content</div><button type="button" class="btn btn-default" data-dismiss="modal">Close</button>', backdrop: 'static'), scope);
      inst.opened.then((value) {
        expect(toHaveModalOpen()).toEqual(1);
        // Trigger click event on close button
        dismiss('closing in test');
        //
        expect(toHaveModalOpen()).toEqual(0);
        expect(toHaveBackdrop()).toBeFalsy();
        //
        houskeepking();
      });
      expect(inst.opened, completes);
    });
    
    it('it should allow opening of multiple modals', () {

      ModalInstance inst = modal.open(new ModalOptions(template: '<div>Content1</div>'), scope);
      ModalInstance inst2 = modal.open(new ModalOptions(template: '<div>Content2</div>'), scope);
      Future f = Future.wait([inst.opened, inst2.opened])..then((values) {
        expect(toHaveModalOpen()).toEqual(2);
        
        dismiss("second");
        
        expect(toHaveModalOpen()).toEqual(1);
        expect(toHaveModalOpenWithContent(content:'Content1', selector:'div')).toBeTruthy();
        
        dismiss("first");
        expect(toHaveModalOpen()).toEqual(0);
        
        houskeepking();
      });
      
      expect(f, completes);
    });
    
    it('should not close any modals on ESC if the topmost one does not allow it', () {

      ModalInstance inst = modal.open(new ModalOptions(template: '<div>Modal1</div>'), scope);
      ModalInstance inst2 = modal.open(new ModalOptions(template: '<div>Modal2</div>', keyboard: false), scope);
      Future f = Future.wait([inst.opened, inst2.opened])..then((values) {
        expect(toHaveModalOpen()).toEqual(2);
        
        triggerKeyDown(dom.document, 27);
        rootScope.rootScope.apply();
        
        expect(toHaveModalOpen()).toEqual(2);
        
        houskeepking();
      });
      
      expect(f, completes);
    });
    
    it('should not close any modals on click if a topmost modal does not have backdrop', () {

      ModalInstance inst = modal.open(new ModalOptions(template: '<div>Modal1</div>'), scope);
      ModalInstance inst2 = modal.open(new ModalOptions(template: '<div>Modal2</div>', backdrop: 'false'), scope);
      Future f = Future.wait([inst.opened, inst2.opened])..then((values) {
        expect(toHaveModalOpen()).toEqual(2);
        
        clickOnBackdrop();
        
        expect(toHaveModalOpen()).toEqual(2);
        
        houskeepking();
      });
      
      expect(f, completes);
    });
    
    it('multiple modals should not interfere with default options', () {
      ModalInstance inst = modal.open(new ModalOptions(template: '<div>Modal1</div>', backdrop: 'false'), scope);
      ModalInstance inst2 = modal.open(new ModalOptions(template: '<div>Modal2</div>'), scope);
      Future f = Future.wait([inst.opened, inst2.opened])..then((values) {
        expect(toHaveModalOpen()).toEqual(2);
        expect(toHaveBackdrop()).toBeTruthy();
        
        houskeepking();
      });
      
      expect(inst.opened, completes);
    });
  });
}
