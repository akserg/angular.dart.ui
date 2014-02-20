// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void tabsTests() {
  
  describe('Testing Tabs:', () {
    
    HttpRequest request;
   
    setUp(() {
      String url = 'packages/angular_ui/alert/alert.html';  
      request = new HttpRequest();
      request.open("GET", url, async : false);
      request.send();
    });
   
    it("should print html template", () {
      print(request.statusText); // ok
      print('----------------- ALERT ---------------------');
      print(request.responseText); // "(resource text)"
    });
    
  });
}
