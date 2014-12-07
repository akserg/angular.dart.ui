// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular_ui_test;

testProgressbarComponent() {
  describe("[ProgressbarComponent]", () {
    TestBed _;
    Scope scope;
        
    beforeEach(setUpInjector);

    beforeEach(() {
      module((Module _) => _
        ..install(new ProgressbarModule())
      );
      inject((TestBed tb) { _ = tb; });
      //return loadTemplates(['/progressbar/bar.html', '/progressbar/progressbar.html', '/progressbar/stackedProgress.html']);
    });

    afterEach(tearDownInjector);
    
    String getHtml() {
      return '<progressbar animate="false" value="value">{{value}} %</progressbar>';
    };
    
    Map getScope() {
      return {'value': 22};
    }

    var BAR_CLASS = 'progress-bar';
    
    dom.Element getProgressbar(dom.Element element, [indx = 0]) => ngQuery(element, '.progress-bar')[indx];
    dom.Element getBar(dom.Element element, [indx = 0]) => ngQuery(element, 'bar')[indx];
    
    it('has a "progress" css class', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var shadowElement = shadowRoot.querySelector('progressbar').children.first;
      clockTick();
      
      expect(shadowElement).toHaveClass('progress');
    }));
    
    it('contains one child element with "bar" css class', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var shadowElement = shadowRoot.querySelector('progressbar').children.first;
      clockTick();
      
      expect(shadowElement.children.length).toBe(1);
      expect(getProgressbar(shadowElement)).toHaveClass(BAR_CLASS);
    }));
    
    it('has a "bar" element with expected width', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var shadowElement = shadowRoot.querySelector('progressbar').children.first;
      clockTick();
      
      expect(getProgressbar(shadowElement).style.width).toEqual('22%');
    }));
    
    it('transcludes "bar" text', compileComponent(
        getHtml(), 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var shadowElement = shadowRoot.querySelector('progressbar').children.first;
      clockTick();
      
      expect(shadowElement.text).toContain('22 %');
    }));

    it('it should be possible to add additional classes', compileComponent(
        '<stackedProgress class="progress-striped active" animate="false" max="200"><bar class="pizza" value="value"></bar></stackedProgress>', 
        getScope(), 
        (Scope scope, dom.HtmlElement shadowRoot) {
      var shadowElement = shadowRoot.querySelector('stackedprogress').children.first;
      clockTick();
      clockTick();
      
      expect(shadowElement).toHaveClass('progress-striped');
      expect(shadowElement).toHaveClass('active');
      expect(getBar(shadowElement, 0)).toHaveClass('pizza');
    }));
    
    describe('"max" attribute', () {
      String getHtml() {
        return '<progressbar max="max" animate="false" value="value">{{value}}/{{max}}</progressbar>';
      };
      
      Map getScope() {
        return {'value': 22, 'max': 200};
      }
          
      it('adjusts the "bar" width', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var shadowElement = shadowRoot.querySelector('progressbar').children.first;
        clockTick();
        
        expect(getProgressbar(shadowElement).style.width).toEqual('11%');
      }));

      it('adjusts the "bar" width when value changes', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var shadowElement = shadowRoot.querySelector('progressbar').children.first;
        clockTick();
        
        scope.context['value'] = 60;
        digest();
        expect(getProgressbar(shadowElement).style.width).toEqual('30%');

        scope.context['value'] += 12;
        digest();
        expect(getProgressbar(shadowElement).style.width).toEqual('36%');

        scope.context['value'] = 0;
        digest();
        expect(getProgressbar(shadowElement).style.width).toEqual('0%');
      }));

      it('transcludes "bar" text', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var shadowElement = shadowRoot.querySelector('progressbar').children.first;
        clockTick();
        
        expect(shadowElement.text).toContain('22/200');
      }));
    });
    
    describe('"type" attribute', () {
      
      String getHtml() {
        return '<progressbar value="value" animate="false" type="{{type}}">test</progressbar>';
      };
      
      Map getScope() {
        return {'value': 22, 'type': 'success'};
      }

      it('should use correct classes', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var shadowElement = shadowRoot.querySelector('progressbar').children.first;
        clockTick();
        
        expect(getProgressbar(shadowElement)).toHaveClass(BAR_CLASS);
        expect(getProgressbar(shadowElement)).toHaveClass(BAR_CLASS + '-success');
      }));

      it('should change classes if type changed', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var shadowElement = shadowRoot.querySelector('progressbar').children.first;
        clockTick();
        
        scope.context['type'] = 'warning';
        scope.context['value'] += 1;
        digest();

        expect(getProgressbar(shadowElement)).toHaveClass(BAR_CLASS);
        expect(getProgressbar(shadowElement)).not.toHaveClass(BAR_CLASS + '-success');
        expect(getProgressbar(shadowElement)).toHaveClass(BAR_CLASS + '-warning');
      }));
    });
    
    describe('stacked', () {
      
      String getHtml() {
        return '<stackedProgress animate="false"><bar ng-repeat="o in objects" value="o.value" type="{{o.type}}">{{o.value}}</bar></stackedProgress>';
      };
      
      Map getScope() {
        return {'value': 22, 
                'objects': [
                   { 'value': 10, 'type': 'success' },
                   { 'value': 50, 'type': 'warning' },
                   { 'value': 20, 'type': 'danger' }
                 ]};
      }

      it('contains the right number of bars', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var shadowElement = shadowRoot.querySelector('stackedprogress').children.first;
        clockTick();
        clockTick();
        clockTick();
        clockTick();
        
        expect(shadowElement.querySelectorAll('bar').length).toBe(3);
        for (var i = 0; i < 3; i++) {
          expect(getProgressbar(shadowElement, i)).toHaveClass(BAR_CLASS);
        }
      }));

      it('renders each bar with the appropriate width', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var shadowElement = shadowRoot.querySelector('stackedprogress').children.first;
        clockTick();
        clockTick();
        clockTick();
        clockTick();
        
        expect(getProgressbar(shadowElement, 0).style.width).toEqual('10%');
        expect(getProgressbar(shadowElement, 1).style.width).toEqual('50%');
        expect(getProgressbar(shadowElement, 2).style.width).toEqual('20%');
      }));

      it('uses correct classes', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var shadowElement = shadowRoot.querySelector('stackedprogress').children.first;
        clockTick();
        clockTick();
        clockTick();
        clockTick();
        
        expect(getProgressbar(shadowElement, 0)).toHaveClass(BAR_CLASS + '-success');
        expect(getProgressbar(shadowElement, 0)).not.toHaveClass(BAR_CLASS + '-warning');

        expect(getProgressbar(shadowElement, 1)).not.toHaveClass(BAR_CLASS + '-success');
        expect(getProgressbar(shadowElement, 1)).toHaveClass(BAR_CLASS + '-warning');

        expect(getProgressbar(shadowElement, 2)).not.toHaveClass(BAR_CLASS + '-success');
        expect(getProgressbar(shadowElement, 2)).not.toHaveClass(BAR_CLASS + '-warning');
      }));

      it('should change classes if type changed', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var shadowElement = shadowRoot.querySelector('stackedprogress').children.first;
        clockTick();
        clockTick();
        clockTick();
        clockTick();
        
        scope.context['objects'][0]['type'] = 'warning';
        scope.context['objects'][1]['type'] = '';
        scope.context['objects'][2]['type'] = 'info';

        digest();

        expect(getProgressbar(shadowElement, 0)).not.toHaveClass(BAR_CLASS + '-success');
        expect(getProgressbar(shadowElement, 0)).toHaveClass(BAR_CLASS + '-warning');

        expect(getProgressbar(shadowElement, 1)).not.toHaveClass(BAR_CLASS + '-success');
        expect(getProgressbar(shadowElement, 1)).not.toHaveClass(BAR_CLASS + '-warning');

        expect(getProgressbar(shadowElement, 2)).toHaveClass(BAR_CLASS + '-info');
        expect(getProgressbar(shadowElement, 2)).not.toHaveClass(BAR_CLASS + '-success');
        expect(getProgressbar(shadowElement, 2)).not.toHaveClass(BAR_CLASS + '-warning');
      }));

      it('should change classes if type changed', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        var shadowElement = shadowRoot.querySelector('stackedprogress').children.first;
        clockTick();
        clockTick();
        clockTick();
        clockTick();
        
        scope.context['objects'][0]['type'] = 'info';
        scope.context['objects'][0]['value'] = 70;
        scope.context['objects'].removeAt(1);
        scope.context['objects'].removeAt(1);

        digest();
        clockTick();

        expect(shadowElement.querySelectorAll('bar').length).toBe(1);

        expect(getProgressbar(shadowElement, 0)).toHaveClass(BAR_CLASS + '-info');
        expect(getProgressbar(shadowElement, 0)).not.toHaveClass(BAR_CLASS + '-success');
        expect(getProgressbar(shadowElement, 0)).not.toHaveClass(BAR_CLASS + '-warning');
      }));

    });
  });
}
