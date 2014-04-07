// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void dragdropTests() {

  describe('Drag&Drop', () {
    
    TestBed _;
    Scope scope;
    
    beforeEach(() {
      setUpInjector();
      module((Module module) {
        module.install(new DragDropModule());
      });
      inject((TestBed tb, Scope s) { 
        _ = tb;
        scope = s;
      });
    });
    
    afterEach(tearDownInjector);
  
    group('Move From List To List', () {
      
      bool dragEnabled = true;
      var dragData = "Hello World at " + new DateTime.now().toString();
      dom.Element elem;
      
      dom.Element createElement() {
        
        scope.context['dragEnabled'] = dragEnabled;
        scope.context['dragData'] = dragData;
        scope.context['dragSuccessCallback'] = () {};
        String html =
'''<div>
<div id='dragId'
ui-draggable 
draggable-enabled="dragEnabled" 
draggable-data="dragData" 
on-drag-success="dragSuccessCallback()"
></div>
</div>''';
        dom.Element element = _.compile(html.trim());
        
        //Doing it twice or it doesn't work... why!?
        microLeap();
        scope.rootScope.apply();
        microLeap();
        scope.rootScope.apply();
        
        return element;
      };
      
      it('It should add the "draggable" attribute', async(inject(() {
        dom.Element dragElem = ngQuery(createElement(), '#dragId')[0];
        expect(dragElem).toBeNotNull();
        expect(dragElem.attributes['draggable']).toBeTruthy();
      })));
      
      it('It should not add the "draggable" attribute if the drag is not enabled', async(inject(() {
        dragEnabled = false;
        dom.Element dragElem = ngQuery(createElement(), '#dragId')[0];
        expect(dragElem).toBeNotNull();
        print(dragElem.attributes['draggable']);
        expect(dragElem.attributes['draggable']).toEqual('false');
      })));
        
    });
    
  });
}


