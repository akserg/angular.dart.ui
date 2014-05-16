// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void carouselTests() {

  
  describe('', () {
    TestBed _;
    Scope scope;
    Timeout timeout;
    
    beforeEach(() {
      setUpInjector();
      module((Module module) {
        module.install(new TimeoutModule());
        module.install(new CarouselModule());
      });
      
      inject((TestBed tb, Scope s, TemplateCache cache, Timeout t) {
        _ = tb;
        scope = s;
        addToTemplateCache(cache, 'packages/angular_ui/carousel/carousel.html');
        addToTemplateCache(cache, 'packages/angular_ui/carousel/slide.html');
        addToTemplateCache(cache, 'packages/angular_ui/carousel/slide.css');
        timeout = t;
      });
    });
    
    afterEach(tearDownInjector);
    
    void cleanup() {
      microLeap();
      timeout.flush(cancel:true);
    }
    
    describe('basics', () {
      
      dom.Element createElement([html = null]) {
            
        scope.context['slides'] = [
          {'active':false,'content':'one'},
          {'active':false,'content':'two'},
          {'active':false,'content':'three'}
        ];
        scope.context['interval'] = 50000;
        scope.context['nopause'] = null;
        
        dom.Element element = _.compile(html != null ? html : '''
          <carousel interval="interval" no-transition="true" no-pause="nopause">
            <slide ng-repeat="slide in slides" active="slide['active']">{{slide['content']}}</slide>
          </carousel>'''.trim());
        
         microLeap();
         scope.rootScope.apply();
         microLeap();
         scope.rootScope.apply();
        
        return element;
      };
      
      void testSlideActive(slideIndex) {
        for (var i = 0; i < scope.context['slides'].length; i++) {
          if (i == slideIndex) {
            expect(scope.context['slides'][i]['active']).toBe(true);
          } else {
            expect(scope.context['slides'][i]['active']).not.toBe(true);
          }
        }
      }
      
      it('should set the selected slide to active = true', async(inject(() {
        dom.Element element = createElement();
        
        expect(scope.context['slides'][0]['content']).toEqual('one');

        scope.apply("slides[0]['active']=true");
        testSlideActive(0);
        
        cleanup();
      })));
      
      it('should create clickable prev nav button', async(inject(() {
        dom.Element element = createElement();
        
        var navPrev = ngQuery(element, 'a.left');
        var navNext = ngQuery(element, 'a.right');

        expect(navPrev.length).toBe(1);
        expect(navNext.length).toBe(1);
        
        cleanup();
      })));
      
      it('should display clickable slide indicators', async(inject(() {
        dom.Element element = createElement();
        
        var indicators = ngQuery(element, 'ol.carousel-indicators > li');
        expect(indicators.length).toBe(3);
        
        cleanup();
      })));
      
      it('should hide navigation when only one slide', async(inject(() {
        dom.Element element = createElement();
        
        scope.context['slides'] = [{'active':false,'content':'one'}];
        scope.apply();

        var indicators = ngQuery(element, 'ol.carousel-indicators > li');
        expect(indicators.length).toBe(0);
        
        var navNext = ngQuery(element, 'a.right')[0];
        expect(navNext).toHaveClass('ng-hide');
        
        var navPrev = ngQuery(element, 'a.left')[0];
        expect(navPrev).toHaveClass('ng-hide');
        
        cleanup();
      })));
      
      it('should show navigation when there are 3 slides', async(inject(() {
        dom.Element element = createElement();
        
        var indicators = ngQuery(element, 'ol.carousel-indicators > li');
        expect(indicators.length).not.toBe(0);
        
        var navNext = ngQuery(element, 'a.right')[0];
        expect(navNext).not.toHaveClass('ng-hide');
        
        var navPrev = ngQuery(element, 'a.left')[0];
        expect(navPrev).not.toHaveClass('ng-hide');
        
        cleanup();
      })));
      
      it('should go to next when clicking next button', async(inject(() {
        dom.Element element = createElement();
        
        var navNext = ngQuery(element, 'a.right')[0];
        testSlideActive(0);
        
        _.triggerEvent(navNext, 'click');
        testSlideActive(1);
        
        _.triggerEvent(navNext, 'click');
        testSlideActive(2);
        
        _.triggerEvent(navNext, 'click');
        testSlideActive(0);
        
        cleanup();
      })));
      
      it('should go to prev when clicking prev button', async(inject(() {
        dom.Element element = createElement();
        
        var navPrev = ngQuery(element, 'a.left')[0];
        testSlideActive(0);
        
        _.triggerEvent(navPrev, 'click');
        testSlideActive(2);
        
        _.triggerEvent(navPrev, 'click');
        testSlideActive(1);
        
        _.triggerEvent(navPrev, 'click');
        testSlideActive(0);
        
        cleanup();
      })));
      
      it('should select a slide when clicking on slide indicators', async(inject(() {
        dom.Element element = createElement();
        
        var indicators = ngQuery(element, 'ol.carousel-indicators > li');
        _.triggerEvent(indicators[1], 'click');
        testSlideActive(1);
        
        cleanup();
      })));
      
//      it('shouldnt go forward if interval is NaN or negative', async(inject(() {
//        dom.Element element = createElement();
//        
//        testSlideActive(0);
//        
//        scope.apply('interval = -1');
//        //no timeout to flush, interval watch doesn't make a new one when interval is invalid
//        testSlideActive(0);
//        
//        scope.apply('interval = 1000');
//        microLeap();
//        timeout.flush();
//        testSlideActive(1);
//        
//        scope.apply('interval = false');
//        testSlideActive(1);
//        
//        scope.apply('interval = 1000');
//        microLeap();
//        timeout.flush();
//        testSlideActive(2);
//        
//        cleanup();
//      })));
      
//      it('should bind the content to slides', async(inject(() {
//        dom.Element element = createElement();
//        
//        var contents = ngQuery(element, 'div.item');
//
//        expect(contents.length).toBe(3);
//        expect(contents[0].text).toEqual('one');
//        expect(contents[1].text).toEqual('two');
//        expect(contents[2].text).toEqual('three');
//
//        scope.apply(() {
//          scope.context['slides'][0]['content'] = 'what';
//          scope.context['slides'][1]['content'] = 'no';
//          scope.context['slides'][2]['content'] = 'maybe';
//        });
//
//        expect(contents[0].text).toEqual('what');
//        expect(contents[1].text).toEqual('no');
//        expect(contents[2].text).toEqual('maybe');
//        
//        cleanup();
//      })));
      
//      it('should be playing by default and cycle through slides', async(inject(() {
//        dom.Element element = createElement();
//        
//        testSlideActive(0);
//        
//        timeout.flush();
//        testSlideActive(1);
//        
//        timeout.flush();
//        testSlideActive(2);
//        
//        timeout.flush();
//        testSlideActive(0);
//        
//        cleanup();
//      })));
      
//      it('should pause and play on mouseover', async(inject(() {
//        dom.Element element = createElement();
//        
//        testSlideActive(0);
//        
//        timeout.flush();
//        testSlideActive(1);
//        
//        _.triggerEvent(element, 'mouseenter');
//        expect(timeout.flush).toThrow();//pause should cancel current timeout
//        testSlideActive(1);
//        
//        _.triggerEvent(element, 'mouseleave');
//        timeout.flush();
//        testSlideActive(2);
//        
//        cleanup();
//      })));
      
//      it('should not pause on mouseover if noPause', async(inject(() {
//        dom.Element element = createElement();
//        
//        scope.apply('nopause = true');
//        testSlideActive(0);
//        
//        _.triggerEvent(element, 'mouseenter');
//        timeout.flush();
//        testSlideActive(1);
//        
//        _.triggerEvent(element, 'mouseleave');
//        timeout.flush();
//        testSlideActive(2);
//        
//        cleanup();
//      })));
      
      it('should remove slide from dom and change active slide', async(inject(() {
        dom.Element element = createElement();
        
        scope.apply('slides[2]["active"] = true');
        testSlideActive(2);
        
        scope.apply('slides.removeRange(0,1)');
        expect(ngQuery(element, 'div.item').length).toBe(2);
        testSlideActive(1);
        
        scope.apply('slides.removeRange(0,1)');
        expect(ngQuery(element, 'div.item').length).toBe(1);
        testSlideActive(0);
        
        cleanup();
      })));
      
//      it('should change dom when you reassign ng-repeat slides array', async(inject(() {
//        dom.Element element = createElement();
//        
//        scope.context['slides'] = [
//          {'active':false,'content':'new1'},
//          {'active':false,'content':'new2'}
//        ];
//        
//        scope.apply();
//        
//        var contents = ngQuery(element, 'div.item');
//        expect(contents.length).toBe(2);
//        expect(contents[0].text).toBe('new1');
//        expect(contents[1].text).toBe('new2');
//        
//        cleanup();
//      })));
      
//      it('should not change if next is clicked while transitioning', async(inject(() {
//        dom.Element element = createElement();
//        
//        var carouselScope = elm.children().scope();
//        var next = elm.find('a.right');
//
//        testSlideActive(0);
//        carouselScope.$currentTransition = true;
//        next.click();
//
//        testSlideActive(0);
//
//        carouselScope.$currentTransition = null;
//        next.click();
//        testSlideActive(1);
//        
//        cleanup();
//      })));
      
//      it('issue 1414 - should not continue running timers after scope is destroyed', async(inject(() {
//        dom.Element element = createElement();
//        
//        testSlideActive(0);
//        timeout.flush();
//        scope.destroy();
//        expect(timeout.flush()).not.toThrow('No deferred tasks to be flushed');
//        
//        cleanup();
//      })));
    });
  });
}