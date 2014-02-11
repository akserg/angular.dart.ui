// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.test;

void porgressbarTests() {
  describe('Testing progressbar:', () {
    Scope $rootScope;
    Injector injector;
    Compiler $compile;
    TemplateCache cache;
    dom.Element shadowElement;
    dom.Element element;

    beforeEach(setUpInjector);

    dom.Element compileElement(String htmlText) {
      List<Node> elements = $(htmlText);
      $compile(elements, injector.get(DirectiveMap))(injector, elements);
      $rootScope.$digest();
      microLeap();
      return elements[0];
    }

    void loadTemplatesToCache() {
      cache.put('packages/angular_ui/progressbar/progressbar.html', new HttpResponse(200,
        '<div class="progress" ng-class="ctrl.classes">'+
        '  <div class="progress-bar" ng-class="[ctrl.type, \'progress-bar-\' + ctrl.type]">'+
        '    <content></content>'+
        '  </div>'+
        '</div>'));
      cache.put('packages/angular_ui/progressbar/stackedProgress.html', new HttpResponse(200,
        '<div class="progress" ng-class="classes">'+
        '  <content></content>'+
        '</div><br>'));
      cache.put('packages/angular_ui/progressbar/bar.html', new HttpResponse(200,
        '<div class="progress-bar" ng-class="[ctrl.type, \'progress-bar-\' + ctrl.type,  ctrl.classes]" ng-pseudo="x-bar">'+
        '  <content></content>'+
        '</div>'));
    }

    beforeEach(module((Module module) {
      module.install(new ProgressbarModule());
      return (Injector _injector) {
        injector = _injector;
        $compile = injector.get(Compiler);
        $rootScope = injector.get(Scope);
        cache = injector.get(TemplateCache);
        loadTemplatesToCache();
        $rootScope.value = 22;
        element = compileElement('<progressbar animate="false" value="value">{{value}} %</progressbar>');
        shadowElement = getFirstDiv(element.shadowRoot);
      };
    }));

    afterEach(tearDownInjector);

    var BAR_CLASS = 'progress-bar';

    dom.Element getProgressbarChildBar() {
      return shadowElement.children[0];
    }

    dom.Element getProgressChildBar(i) {
      return getFirstDiv(element.children[i].shadowRoot);
    }

    it('has a "progress" css class', async(inject(() {
      expect(shadowElement).toHaveClass('progress');
    })));

    it('contains one child element with "bar" css class', async(inject(() {
      expect(shadowElement.children.length).toBe(1);
      expect(getProgressbarChildBar()).toHaveClass(BAR_CLASS);
    })));

    it('has a "bar" element with expected width', async(inject(() {
      expect(getProgressbarChildBar().style.width).toEqual('22%');
    })));

    it('transcludes "bar" text', async(inject(() {
      expect(element.text).toEqual('22 %');
    })));

    it('it should be possible to add additional classes', async(inject(() {
      element = compileElement('<stackedProgress class="progress-striped active" animate="false" max="200"><bar class="pizza" value="value"></bar></stackedProgress>');
      shadowElement = getFirstDiv(element.shadowRoot);
      $rootScope.$digest();

      expect(shadowElement).toHaveClass('progress-striped');
      expect(shadowElement).toHaveClass('active');
      expect(getProgressChildBar(0)).toHaveClass('pizza');
    })));

    describe('"max" attribute', () {
      beforeEach(module(() {
        return () {
          $rootScope.max = 200;
          $rootScope.value = 22;
          element = compileElement('<progressbar max="max" animate="false" value="value">{{value}}/{{max}}</progressbar>');
          shadowElement = getFirstDiv(element.shadowRoot);
        };
      }));

      it('adjusts the "bar" width', async(inject(() {
        expect(getProgressbarChildBar().style.width).toEqual('11%');
      })));

      it('adjusts the "bar" width when value changes', async(inject(() {
        $rootScope.value = 60;
        $rootScope.$digest();
        expect(getProgressbarChildBar().style.width).toEqual('30%');

        $rootScope.value += 12;
        $rootScope.$digest();
        expect(getProgressbarChildBar().style.width).toEqual('36%');

        $rootScope.value = 0;
        $rootScope.$digest();
        expect(getProgressbarChildBar().style.width).toEqual('0%');
      })));

      it('transcludes "bar" text', async(inject(() {
        expect(element.text).toEqual('22/200');
      })));
    });

    describe('"type" attribute', () {
      beforeEach(module(() {
        return () {
          $rootScope.type = 'success';
          $rootScope.value = 22;
          element = compileElement('<progressbar value="value" animate="false" type="{{type}}">test</progressbar>');
          $rootScope.$digest();
          shadowElement = getFirstDiv(element.shadowRoot);
        };
      }));

      it('should use correct classes', async(inject(() {
        expect(getProgressbarChildBar()).toHaveClass(BAR_CLASS);
        expect(getProgressbarChildBar()).toHaveClass(BAR_CLASS + '-success');
      })));

      it('should change classes if type changed', async(inject(() {
        $rootScope.type = 'warning';
        $rootScope.value += 1;
        $rootScope.$digest();

        var barEl = getProgressbarChildBar();
        expect(barEl).toHaveClass(BAR_CLASS);
        expect(barEl).not.toHaveClass(BAR_CLASS + '-success');
        expect(barEl).toHaveClass(BAR_CLASS + '-warning');
      })));
    });

    describe('stacked', () {
      beforeEach(module(() {
        return () {
          $rootScope.objects = [
            { 'value': 10, 'type': 'success' },
            { 'value': 50, 'type': 'warning' },
            { 'value': 20 }
          ];
          element = compileElement('<stackedProgress animate="false"><bar ng-repeat="o in objects" value="o.value" type="{{o.type}}">{{o.value}}</bar></stackedProgress>');
          $rootScope.$digest();
          shadowElement = getFirstDiv(element.shadowRoot);
        };
      }));

      it('contains the right number of bars', async(inject(() {
        expect(element.children.length).toBe(3);
        for (var i = 0; i < 3; i++) {
          expect(getProgressChildBar(i)).toHaveClass(BAR_CLASS);
        }
      })));

      it('renders each bar with the appropriate width', async(inject(() {
        expect(getProgressChildBar(0).style.width).toEqual('10%');
        expect(getProgressChildBar(1).style.width).toEqual('50%');
        expect(getProgressChildBar(2).style.width).toEqual('20%');
      })));

      it('uses correct classes', async(inject(() {
        expect(getProgressChildBar(0)).toHaveClass(BAR_CLASS + '-success');
        expect(getProgressChildBar(0)).not.toHaveClass(BAR_CLASS + '-warning');

        expect(getProgressChildBar(1)).not.toHaveClass(BAR_CLASS + '-success');
        expect(getProgressChildBar(1)).toHaveClass(BAR_CLASS + '-warning');

        expect(getProgressChildBar(2)).not.toHaveClass(BAR_CLASS + '-success');
        expect(getProgressChildBar(2)).not.toHaveClass(BAR_CLASS + '-warning');
      })));

      it('should change classes if type changed', async(inject(() {
        $rootScope.objects[0]['type'] = 'warning';
        $rootScope.objects[1]['type'] = '';
        $rootScope.objects[2]['type'] = 'info';

        $rootScope.$digest();

        expect(getProgressChildBar(0)).not.toHaveClass(BAR_CLASS + '-success');
        expect(getProgressChildBar(0)).toHaveClass(BAR_CLASS + '-warning');

        expect(getProgressChildBar(1)).not.toHaveClass(BAR_CLASS + '-success');
        expect(getProgressChildBar(1)).not.toHaveClass(BAR_CLASS + '-warning');

        expect(getProgressChildBar(2)).toHaveClass(BAR_CLASS + '-info');
        expect(getProgressChildBar(2)).not.toHaveClass(BAR_CLASS + '-success');
        expect(getProgressChildBar(2)).not.toHaveClass(BAR_CLASS + '-warning');
      })));

      it('should change classes if type changed', async(inject(() {
        $rootScope.objects[0]['type'] = 'info';
        $rootScope.objects[0]['value'] = 70;
        $rootScope.objects.removeAt(1);
        $rootScope.objects.removeAt(1);

        $rootScope.$digest();

        expect(element.children.length).toBe(1);

        expect(getProgressChildBar(0)).toHaveClass(BAR_CLASS + '-info');
        expect(getProgressChildBar(0)).not.toHaveClass(BAR_CLASS + '-success');
        expect(getProgressChildBar(0)).not.toHaveClass(BAR_CLASS + '-warning');
      })));

    });
  });
}