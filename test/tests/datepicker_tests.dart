// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void datepickerTests() {

  
  describe('Testing datepicker:', () {
    TestBed _;
    Scope rootScope;
    dom.Element element;
    TemplateCache cache;
    
    beforeEach(setUpInjector);
    beforeEach(module((Module module) {
      module.install(new DatepickerModule());
    }));
    beforeEach(inject((TestBed tb) => _ = tb));
    beforeEach(inject((Scope s) => rootScope = s.$root));
    beforeEach(inject((TemplateCache c) { 
      cache = c;
      
      dom.HttpRequest.getString('packages/angular_ui/datepicker/datepicker.html').then((datepicker_html) { // new
        cache.put('packages/angular_ui/datepicker/datepicker.html', new HttpResponse(200, datepicker_html));
      });
      
//      cache.put('packages/angular_ui/datepicker/datepicker.html', new HttpResponse(200, """
//        <table>
//          <thead>
//            <tr>
//              <th><button type="button" class="btn btn-default btn-sm pull-left" ng-click="d.move(-1)"><i class="glyphicon glyphicon-chevron-left"></i></button></th>
//              <th colspan="{{d.rows[0].length - 2 + (d.showWeekNumbers ? 1 : 0)}}"><button type="button" class="btn btn-default btn-sm btn-block" ng-click="d.toggleMode()"><strong>{{d.title}}</strong></button></th>
//              <th><button type="button" class="btn btn-default btn-sm pull-right" ng-click="d.move(1)"><i class="glyphicon glyphicon-chevron-right"></i></button></th>
//            </tr>
//            <tr ng-show="d.labels != null && d.labels.length > 0" class="h6">
//              <th ng-show="d.showWeekNumbers" class="text-center">#</th>
//              <th ng-repeat="label in d.labels" class="text-center">{{label}}</th>
//            </tr>
//          </thead>
//          <tbody>
//            <tr ng-repeat="row in d.rows">
//              <td ng-show="d.showWeekNumbers" class="text-center"><em>{{ d.getWeekNumber(row.toList()) }}</em></td>
//              <td ng-repeat="dt in row" class="text-center">
//                <button type="button" style="width:100%;" class="btn btn-default btn-sm" ng-class="{'btn-info': dt.selected}" ng-click="d.select(dt.date)" ng-disabled="dt.disabled"><span ng-class="{'text-muted': dt.secondary}">{{dt.label}}</span></button>
//              </td>
//            </tr>
//          </tbody>
//        </table>
//      """));      
    }));
    
    afterEach(tearDownInjector);
    
    Future<dom.Element> createDatepicker() {
      Completer completer = new Completer();
      element = _.compile('<datepicker ng-model="date"></datepicker>', scope:rootScope);
      element.createShadowRoot();
      dom.document.body.append(element);
      rootScope.$digest();
      completer.complete(element);
      return completer.future;
    }
    
    void houskeepking() {
      document.body.querySelectorAll("datepicker").forEach((el) {
        el.remove();
      });
    }
    
    List<Node> shadowRootContent(dom.Element el, String selector) {
      dom.ContentElement content = el.shadowRoot.querySelector("content") as dom.ContentElement;
      return content == null ? [] : content.getDistributedNodes();
    }
    
    describe('', () {
      it('is a `<datepicker>` element', () {
        createDatepicker().then((el) {
          expect(el.tagName).toEqual('DATEPICKER');
          List contents = shadowRootContent(el, '');
          print(contents);
        });
        //expect(shadowRootContent(element, ySelector('thead')).toBeNotNull();
//        expect(element.querySelector('thead').querySelectorAll('tr').length).toBe(2);
      });
    });
  });
}