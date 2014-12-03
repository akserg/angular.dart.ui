// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular_ui_test;

testCarouselComponent() {
  describe("[CarouselComponent]", () {
    TestBed _;
    Scope scope;
    Timeout timeout;
        
    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    beforeEach(() {
      module((Module _) => _
        ..install(new TimeoutModule())
        ..install(new CarouselModule())
      );
      inject((Timeout t) => timeout = t);
      //return loadTemplates(['/carousel/carousel.html', '/carousel/slide.html', '/carousel/carousel.css']);
      return loadTemplates(['/carousel/slide.css']);
    });
    
    describe('basics', () {
      String getHtml() {
        return '''
<carousel slides="slides" interval="interval" no-transition="true" no-pause="nopause">
  <slide ng-repeat="slide in slides" active="slide['active']">{{slide['content']}}</slide>
</carousel>''';
      };
      
      Map getScope() {
        return {'slides': [
           {'active':false,'content':'one'},
           {'active':false,'content':'two'},
           {'active':false,'content':'three'}
        ],
        'interval':50000,
        'nopause': null};
      }
      
      void testSlideActive(Scope scope, slideIndex) {
        for (var i = 0; i < scope.context['slides'].length; i++) {
          if (i == slideIndex) {
            expect(scope.context['slides'][i]['active']).toBe(true);
          } else {
            expect(scope.context['slides'][i]['active']).toBe(false);
          }
        }
      }

      
      it('should set the selected slide to active = true', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {

        expect(scope.context['slides'][0]['content']).toEqual('one');

        scope.apply("slides[0]['active']=true");
        testSlideActive(scope, 0);
        
        microLeap();
        timeout.flush(cancel:true);
      }));
      
      it('should create clickable prev nav button', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        microLeap();
        digest();
    
        var navPrev = ngQuery(shadowRoot, 'a.left');
        var navNext = ngQuery(shadowRoot, 'a.right');

        expect(navPrev.length).toBe(1);
        expect(navNext.length).toBe(1);
        
        microLeap();
        timeout.flush(cancel:true);
      }));
      
      it('should display clickable slide indicators', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        microLeap();
        digest();
        
        var indicators = ngQuery(shadowRoot, 'ol.carousel-indicators > li');
        expect(indicators.length).toBe(3);
        
        microLeap();
        timeout.flush(cancel:true);
      }));
      
      it('should hide navigation when only one slide', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        microLeap();
        digest();
        
        scope.context['slides'] = [{'active':false,'content':'one'}];
        digest();

        var indicators = ngQuery(shadowRoot, 'ol.carousel-indicators > li');
        expect(indicators.length).toBe(0);
        
        var navNext = ngQuery(shadowRoot, 'a.right')[0];
        expect(navNext).toHaveClass('ng-hide');
        
        var navPrev = ngQuery(shadowRoot, 'a.left')[0];
        expect(navPrev).toHaveClass('ng-hide');
        
        microLeap();
        timeout.flush(cancel:true);
      }));

      it('should show navigation when there are 3 slides', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        microLeap();
        digest();
        
        var indicators = ngQuery(shadowRoot, 'ol.carousel-indicators > li');
        expect(indicators.length).not.toBe(0);
        
        var navNext = ngQuery(shadowRoot, 'a.right')[0];
        expect(navNext).not.toHaveClass('ng-hide');
        
        var navPrev = ngQuery(shadowRoot, 'a.left')[0];
        expect(navPrev).not.toHaveClass('ng-hide');
        
        microLeap();
        timeout.flush(cancel:true);
      }));
      
      it('should go to next when clicking next button', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        microLeap();
        digest();
        
        var navNext = ngQuery(shadowRoot, 'a.right')[0];
        testSlideActive(scope, 0);
        
        navNext.click();
        digest();
        testSlideActive(scope, 1);

        navNext.click();
        digest();
        testSlideActive(scope, 2);
        
        navNext.click();
        digest();
        testSlideActive(scope, 0);
        
        microLeap();
        timeout.flush(cancel:true);
      }));

      it('should go to prev when clicking prev button', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        microLeap();
        digest();
        
        var navPrev = ngQuery(shadowRoot, 'a.left')[0];
        testSlideActive(scope, 0);
        
        navPrev.click();
        digest();
        testSlideActive(scope, 2);
        
        navPrev.click();
        digest();
        testSlideActive(scope, 1);
        
        navPrev.click();
        digest();
        testSlideActive(scope, 0);
        
        microLeap();
        timeout.flush(cancel:true);
      }));
      
      it('should select a slide when clicking on slide indicators', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        microLeap();
        digest();
        
        var indicators = ngQuery(shadowRoot, 'ol.carousel-indicators > li');
        indicators[1].click();
        digest();
        testSlideActive(scope, 1);
        
        microLeap();
        timeout.flush(cancel:true);
      }));

//      it('shouldnt go forward if interval is NaN or negative', compileComponent(
//          getHtml(), 
//          getScope(), 
//          (Scope scope, dom.HtmlElement shadowRoot) {
//        microLeap();
//        digest();
//        
//        testSlideActive(scope, 0);
//        
//        scope.apply('interval = -1');
//        //no timeout to flush, interval watch doesn't make a new one when interval is invalid
//        testSlideActive(scope, 0);
//        
//        scope.apply('interval = 1000');
//        microLeap();
//        timeout.flush();
//        testSlideActive(scope, 1);
//        
//        scope.apply('interval = false');
//        testSlideActive(scope, 1);
//        
//        scope.apply('interval = 1000');
//        microLeap();
//        timeout.flush();
//        testSlideActive(scope, 2);
//        
//        microLeap();
//        timeout.flush(cancel:true);
//      }));
      
      it('should bind the content to slides', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        microLeap();
        digest();
        
        var contents = ngQuery(shadowRoot, 'div.item');

        expect(contents.length).toBe(3);
        expect(contents[0].text.trim()).toEqual('one');
        expect(contents[1].text.trim()).toEqual('two');
        expect(contents[2].text.trim()).toEqual('three');

        scope.apply(() {
          scope.context['slides'][0]['content'] = 'what';
          scope.context['slides'][1]['content'] = 'no';
          scope.context['slides'][2]['content'] = 'maybe';
        });

        expect(contents[0].text.trim()).toEqual('what');
        expect(contents[1].text.trim()).toEqual('no');
        expect(contents[2].text.trim()).toEqual('maybe');
        
        microLeap();
        timeout.flush(cancel:true);
      }));

//      it('should be playing by default and cycle through slides', compileComponent(
//          getHtml(), 
//          getScope(), 
//          (Scope scope, dom.HtmlElement shadowRoot) {
//        microLeap();
//        digest();
//        
//        testSlideActive(scope, 0);
//        
//        timeout.flush();
//        testSlideActive(scope, 1);
//        
//        timeout.flush();
//        testSlideActive(scope, 2);
//        
//        timeout.flush();
//        testSlideActive(scope, 0);
//        
//        microLeap();
//        timeout.flush(cancel:true);
//      }));

//      it('should pause and play on mouseover', compileComponent(
//          getHtml(), 
//          getScope(), 
//          (Scope scope, dom.HtmlElement shadowRoot) {
//        microLeap();
//        digest();
//        
//        testSlideActive(scope, 0);
//        
//        timeout.flush();
//        testSlideActive(scope, 1);
//        
//        _.triggerEvent(shadowRoot, 'mouseenter');
//        expect(timeout.flush).toThrowWith();//pause should cancel current timeout
//        testSlideActive(scope, 1);
//        
//        _.triggerEvent(shadowRoot, 'mouseleave');
//        timeout.flush();
//        testSlideActive(scope, 2);
//        
//        microLeap();
//        timeout.flush(cancel:true);
//      }));

//      it('should not pause on mouseover if noPause', compileComponent(
//          getHtml(), 
//          getScope(), 
//          (Scope scope, dom.HtmlElement shadowRoot) {
//        microLeap();
//        digest();
//        
//        scope.apply('nopause = true');
//        testSlideActive(scope, 0);
//        
//        _.triggerEvent(shadowRoot, 'mouseenter');
//        timeout.flush();
//        testSlideActive(scope, 1);
//        
//        _.triggerEvent(shadowRoot, 'mouseleave');
//        timeout.flush();
//        testSlideActive(scope, 2);
//        
//        microLeap();
//        timeout.flush(cancel:true);
//      }));

      it('should remove slide from dom and change active slide', compileComponent(
          getHtml(), 
          getScope(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        microLeap();
        digest();
        
        scope.apply('slides[2]["active"] = true');
        testSlideActive(scope, 2);
        
        scope.apply('slides.removeRange(0,1)');
        expect(ngQuery(shadowRoot, 'div.item').length).toBe(2);
        testSlideActive(scope, 1);
        
        scope.apply('slides.removeRange(0,1)');
        expect(ngQuery(shadowRoot, 'div.item').length).toBe(1);
        testSlideActive(scope, 0);
        
        microLeap();
        timeout.flush(cancel:true);
      }));

//      it('should change dom when you reassign ng-repeat slides array', compileComponent(
//          getHtml(), 
//          getScope(), 
//          (Scope scope, dom.HtmlElement shadowRoot) {
//        microLeap();
//        digest();
//        
//        scope.context['slides'] = [
//          {'active':false,'content':'new1'},
//          {'active':false,'content':'new2'}
//        ];
//        
//        scope.apply();
//        
//        var contents = ngQuery(shadowRoot, 'div.item');
//        expect(contents.length).toBe(2);
//        expect(contents[0].text).toBe('new1');
//        expect(contents[1].text).toBe('new2');
//        
//        microLeap();
//        timeout.flush(cancel:true);
//      }));
      
    });
  });
}
