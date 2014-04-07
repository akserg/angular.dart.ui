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
  
    group('Controller', () {
      
      dom.Element elem;
      
      dom.Element createElement() {
        
        scope.context['hello'] = 'hello world';
        
        String html =
        '''<div>
            {{hello}}
            </div>''';
        dom.Element element = _.compile(html.trim());
        
        //Doing it twice or it doesn't work... why!?
        microLeap();
        scope.rootScope.apply();
        microLeap();
        scope.rootScope.apply();
        
        return element;
      };
      
      beforeEach(() { 
        elem = createElement();
      });
        
        it('It should say "hello world" ;)', async(inject(() {
          ngQuery(elem, 'div').toString().contains("world");
        })));
        
    });
    
  });
}


