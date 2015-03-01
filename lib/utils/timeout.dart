// Copyright (C) 2013 - 2015 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
library angular.ui.timeout;

import 'dart:async' as async;
import "package:angular/angular.dart";

import 'package:logging/logging.dart' show Logger;
final _log = new Logger('angular.ui.timeout');

/**
 * Timeout Module.
 */
class TimeoutModule extends Module {
  TimeoutModule() {
    bind(Timeout);
  }
}

@Injectable()
class TimeItem {
  Function fn;
  async.Timer timer;
  
  TimeItem(this.fn, this.timer);
}

/**
 * Angular's UI wrapper for `window.setTimeout`. The `fn` function is wrapped into a try/catch
 * block and delegates any exceptions to
 * {@link ng.$exceptionHandler $exceptionHandler} service.
 *
 * The return value of registering a timeout function is a promise, which will be resolved when
 * the timeout is reached and the timeout function is executed.
 *
 * To cancel a timeout request, call `$timeout.cancel(promise)`.
 *
 * In tests you can use {@link ngMock.$timeout `$timeout.flush()`} to
 * synchronously flush the queue of deferred functions.
 */
@Injectable()
class Timeout implements ScopeAware {
  Map<async.Completer, TimeItem> deferreds = new Map<async.Completer, TimeItem>();

  Scope scope;
  ExceptionHandler exceptionHandler;
  Scope rootScope;

  Timeout(Injector injector, this.exceptionHandler) {
  	this.rootScope = injector.get(RootScope);
  }

  /**
   * The [fn] is a function, whose execution should be delayed.
   * The [delay] in milliseconds.
   * If set invokeApply to `false` skips model dirty checking, otherwise
   * will invoke `fn` within the {@link ng.$rootScope.Scope#methods_$apply $apply} block.
   *
   * Promise that will be resolved when the timeout is reached. The value this
   * promise will be resolved with is the return value of the `fn` function.
   */
  async.Completer call(Function fn, {int delay:0, bool invokeApply:true}) {
    assert(fn != null);
    async.Completer deferred = new async.Completer();
    deferred.future.catchError((e, s) {
      //_log.fine('call error $e, $s'); // enabled for hard to find error source
      });
    var timeoutId;

    timeoutId = new async.Timer(new Duration(milliseconds: delay), () {
      try {
        if (!deferred.isCompleted) {
          deferred.complete(fn());
        }
      } catch(e, s) {
        if (!deferred.isCompleted) {
          deferred.completeError(e);
        }
        exceptionHandler(e, s);
      }
      finally {
        deferreds.remove(deferred);
      }
      //
      if (invokeApply) {
        rootScope.apply();
      }
    });

    deferreds[deferred] = new TimeItem(fn, timeoutId);

    return deferred;
  }

  /**
   * Cancels a task associated with the [promise].
   * As a result of this, the promise will be resolved with a rejection.
   */
  bool cancel([async.Completer promise = null]) {
    if (promise != null && deferreds.containsKey(promise)) {
      deferreds[promise].timer.cancel();
      promise.completeError('canceled');
      deferreds.remove(promise);
      return true;
    }
    return false;
  }

  /**
   * Call all functions in [deferreds].
   */
  void flush({bool cancel:false}) {
    deferreds.forEach((async.Completer deferred, TimeItem timeItem) {
      try {
        if (cancel) {
          deferred.completeError('canceled');
        } else {
          deferred.complete(timeItem.fn());
        }
      } catch(e, s) {
        deferred.completeError(e);
        exceptionHandler(e, s);
      } finally {
        timeItem.timer.cancel();
        timeItem.timer = null;
      }
    });
    deferreds.clear();
  }
}