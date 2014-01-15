// The MIT License
// 
// Copyright (c) 2010-2012 Google, Inc. http://angularjs.org
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

library jasmine;

import 'package:unittest/unittest.dart' as unit;
import 'package:angular/utils.dart' as utils;

Function _wrapFn;

_maybeWrapFn(fn) => () {
  if (_wrapFn != null) {
    _wrapFn(fn)();
  } else {
    fn();
  }
};

it(name, fn) => unit.test(name, _maybeWrapFn(fn));
iit(name, fn) => unit.solo_test(name, _maybeWrapFn(fn));
xit(name, fn) {}
xdescribe(name, fn) {}
ddescribe(name, fn) => describe(name, fn, true);


class Describe {
  Describe parent;
  String name;
  bool exclusive;
  List<Function> beforeEachFns = [];
  List<Function> afterEachFns = [];

  Describe(this.name, this.parent, [bool this.exclusive=false]) {
    if (parent != null && parent.exclusive) {
      exclusive = true;
    }
  }

  setUp() {
    beforeEachFns.forEach((fn) => fn());
  }

  tearDown() {
    afterEachFns.forEach((fn) => fn());
  }
}

Describe currentDescribe = new Describe('', null);
bool ddescribeActive = false;

describe(name, fn, [bool exclusive=false]) {
  var lastDescribe = currentDescribe;
  currentDescribe = new Describe(name, lastDescribe, exclusive);
  if (exclusive) {
    name = 'DDESCRIBE: $name';
    ddescribeActive = true;
  }
  try {
    unit.group(name, () {
      unit.setUp(currentDescribe.setUp);
      fn();
      unit.tearDown(currentDescribe.tearDown);
    });
  } finally {
    currentDescribe = lastDescribe;
  }
}

beforeEach(fn) => currentDescribe.beforeEachFns.add(fn);
afterEach(fn) => currentDescribe.afterEachFns.insert(0, fn);

wrapFn(fn) => _wrapFn = fn;

var jasmine = new Jasmine();

class SpyFunctionInvocationResult {
  final List args;
  SpyFunctionInvocationResult(this.args);
}

class SpyFunction {
  String name;
  List<List<dynamic>> invocations = [];
  List<List<dynamic>> invocationsWithoutTrailingNulls = [];
  var _andCallFakeFn;

  SpyFunction([this.name]);
  call([a0, a1, a2, a3, a4, a5]) {
    var args = [];
    args.add(a0);
    args.add(a1);
    args.add(a2);
    args.add(a3);
    args.add(a4);
    args.add(a5);
    invocations.add(args);

    var withoutNulls = new List.from(args);
    while (!withoutNulls.isEmpty && withoutNulls.last == null) {
      withoutNulls.removeLast();
    }
    invocationsWithoutTrailingNulls.add(withoutNulls);

    if (_andCallFakeFn != null) {
      utils.relaxFnApply(_andCallFakeFn, args);
    }
  }

  andCallFake(fn) {
    _andCallFakeFn = fn;
    return this;
  }

  reset() => invocations = [];

  num get count => invocations.length;
  bool get called => count > 0;

  num get callCount => count;
  get argsForCall => invocationsWithoutTrailingNulls;

  firstArgsMatch(a,b,c,d,e,f) {
    var fi = invocations.first;
    assert(fi.length == 6);
    if ("${fi[0]}" != "$a") return false;
    if ("${fi[1]}" != "$b") return false;
    if ("${fi[2]}" != "$c") return false;
    if ("${fi[3]}" != "$d") return false;
    if ("${fi[4]}" != "$e") return false;
    if ("${fi[5]}" != "$f") return false;

    return true;
  }

  get mostRecentCall {
    if (invocations.isEmpty) {
      throw ["No calls"];
    }
    return new SpyFunctionInvocationResult(invocations.last);
  }
}

class Jasmine {
  createSpy([String name]) {
    return new SpyFunction(name);
  }

  SpyFunction spyOn(receiver, methodName) {
    throw ["spyOn not implemented"];
  }
}

main(){
  unit.setUp(currentDescribe.setUp);
  unit.tearDown(currentDescribe.tearDown);
}