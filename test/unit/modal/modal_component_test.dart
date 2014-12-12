// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular_ui_test;

testModalComponent() {
  describe("[ModalComponent]", () {
    TestBed _;
    Scope rootScope;
    Timeout timeout;
    Modal modal;
        
    beforeEach(setUpInjector);

    beforeEach(() {
      module((Module _) => _
        ..install(new ModalModule())
      );
      inject((Modal m, Timeout t, Scope scope) { 
        modal = m;
        timeout = t;
        rootScope = scope;
      });
      //return loadTemplates(['/modal/window.html']);
    });
    
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
    
    afterEach(() {
      dom.document.body.querySelectorAll("modal-window").forEach((el) {
        modal.hide();
        el.remove();
      });
    });
    
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
      var modals = dom.document.body.querySelectorAll("modal-window");
      print('!!! modals ${modals.length}');
      modals.forEach((dom.Element el){
        if (el.style.display == 'block') {
          res++;
        }
      });
      return res;
    }
    
    void close(result) {
      modal.close(result);
      rootScope.apply();
    }

    void dismiss(String reason) {
      modal.dismiss(reason);
      timeout.flush();
      rootScope.apply();
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
    
    afterEach(tearDownInjector);

    it('should open and dismiss a modal with a minimal set of options', () {
      ModalInstance inst = modal.open(new ModalOptions(template:"<div>Content</div>"), rootScope);
      
      expect(inst).toBeDefined();
//      inst.opened.then((value) {
//        print("opened $value");
//        expect(toHaveModalOpen()).toEqual(1);
//        expect(toHaveModalOpenWithContent(content:'Content', selector:'div')).toBeTruthy();
//        expect(toHaveBackdrop()).toBeTruthy();
//        //
//        dismiss('closing in test');
//        //
//        expect(toHaveModalOpen()).toEqual(0);
//        expect(toHaveBackdrop()).toBeFalsy();
//        //
////        houskeepking();
//      });
//      expect(inst.opened), completes);
    });
  });
}
