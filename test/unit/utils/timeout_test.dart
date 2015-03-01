// Copyright (C) 2013 - 2015 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular_ui_test;

testTimeout() {
  describe("[Timeout]", () {
    TestBed _;
        
    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    beforeEach(() {
      module((Module _) => _
        ..install(new TimeoutModule())
      );
    });

    it('should delegate functions to timeout', inject((Timeout timeout) {
      var counter = 0;
      timeout(() { 
        counter++; 
      });

      expect(counter).toBe(0);

      timeout.flush();
      expect(counter).toBe(1);
    }));
  });
  
  describe("[Timeout Exception Handler]", () {
    TestBed _;
        
    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    beforeEach(() {
      module((Module _) => _
        ..install(new TimeoutModule())
        ..bind(ExceptionHandler, toImplementation:TestExceptionHandler)
      );
    });

    it('should delegate exception to the exceptionHandler service', inject((Timeout timeout, ExceptionHandler handler) {
      timeout(() { throw new Exception("Test Error"); });
      
      expect(handler).toBeAnInstanceOf(TestExceptionHandler);
      TestExceptionHandler exceptionHandler = handler as TestExceptionHandler;
      expect(exceptionHandler.errors).toEqual([]);

      timeout.flush();
      expect(exceptionHandler.errors.length).toEqual(1);
    }));
  });
  
  describe("[Timeout cancel]", () {
    TestBed _;
        
    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    beforeEach(() {
      module((Module _) => _
        ..install(new TimeoutModule())
      );
    });

    it('should cancel tasks', inject((Timeout timeout) {
      var task1 = guinness.createSpy('task1'),
          task2 = guinness.createSpy('task2'),
          task3 = guinness.createSpy('task3'),
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
    }));
    
    it('should return true if a task was successfully canceled', inject((Timeout timeout) {
      var task1 = guinness.createSpy('task1'),
          task2 = guinness.createSpy('task2'),
          promise1, promise2;

      promise1 = timeout(task1);
      timeout.flush();
      promise2 = timeout(task2);

      expect(timeout.cancel(promise1)).toBe(false);
      expect(timeout.cancel(promise2)).toBe(true);
    }));
    
    it('should not throw a runtime exception when given an undefined promise', inject((Timeout timeout) {
      expect(timeout.cancel()).toBe(false);
    }));
  });
}

@Injectable()
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

