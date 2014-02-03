// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void timeoutTests() {

  
  describe('Testing timeout:', () {
    TestBed _;
    Scope scope;
    Timeout timeout;
    
    beforeEach(setUpInjector);
    beforeEach(module((Module module) {
      module.install(new TimeoutModule());
    }));
    beforeEach(inject((TestBed tb) => _ = tb));
    beforeEach(inject((Scope s) => scope = s));
    beforeEach(inject((Timeout t) => timeout = t));
    
    
    afterEach(tearDownInjector);
    
    it('should delegate functions to timeout', () {
      var counter = 0;
      timeout(() { 
        counter++; 
      });

      expect(counter).toBe(0);

      timeout.flush();
      expect(counter).toBe(1);
    });
  });
  
  describe('Testing timeout exceptiong handler:', () {
    TestBed _;
    Scope scope;
    Timeout timeout;
    TestExceptionHandler exceptionHandler;
    
    beforeEach(setUpInjector);
    beforeEach(module((Module module) {
      module.install(new TimeoutModule());
      module.type(ExceptionHandler, implementedBy:TestExceptionHandler);
    }));
    beforeEach(inject((TestBed tb) => _ = tb));
    beforeEach(inject((Scope s) => scope = s));
    beforeEach(inject((Timeout t) => timeout = t));
    beforeEach(inject((ExceptionHandler e) => exceptionHandler = e));
    
    
    afterEach(tearDownInjector);
    
    it('should delegate exception to the exceptionHandler service', () {
      timeout(() { throw new Exception("Test Error"); });
      
      expect(exceptionHandler.errors).toEqual([]);

      timeout.flush();
      expect(exceptionHandler.errors.length).toEqual(1);
    });
  });
  
  describe('Testing timeout cancel:', () {
    TestBed _;
    Scope scope;
    Timeout timeout;
    
    beforeEach(setUpInjector);
    beforeEach(module((Module module) {
      module.install(new TimeoutModule());
    }));
    beforeEach(inject((TestBed tb) => _ = tb));
    beforeEach(inject((Scope s) => scope = s));
    beforeEach(inject((Timeout t) => timeout = t));
    
    
    afterEach(tearDownInjector);
    
    it('should cancel tasks', () {
      var task1 = jasmine.createSpy('task1'),
          task2 = jasmine.createSpy('task2'),
          task3 = jasmine.createSpy('task3'),
          promise1, promise3;

      promise1 = timeout(task1);
      timeout(task2);
      promise3 = timeout(task3, delay:333);

      timeout.cancel(promise3);
      timeout.cancel(promise1);
      timeout.flush();

      expect(task1).not.toHaveBeenCalled();
      expect(task2).toHaveBeenCalledOnce();
      expect(task3).not.toHaveBeenCalled();
    });
    
    it('should return true if a task was successfully canceled', () {
      var task1 = jasmine.createSpy('task1'),
          task2 = jasmine.createSpy('task2'),
          promise1, promise2;

      promise1 = timeout(task1);
      timeout.flush();
      promise2 = timeout(task2);

      expect(timeout.cancel(promise1)).toBe(false);
      expect(timeout.cancel(promise2)).toBe(true);
    });
    
    it('should not throw a runtime exception when given an undefined promise', () {
      expect(timeout.cancel()).toBe(false);
    });
  });
}

@NgInjectableService()
class TestExceptionHandler implements ExceptionHandler {
  var errors = [];
  
  /**
   * Delegate uncaught exception for central error handling.
  *
  * - [error] The error which was caught.
  * - [stack] The stacktrace.
  * - [reason] Optional contextual information for the error.
  */
  call(dynamic error, dynamic stack, [String reason = '']){
    errors.add(error);
  }
}
