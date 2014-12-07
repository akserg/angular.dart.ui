// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

@Component(
    selector: 'carousel-demo',
    templateUrl: 'carousel/carousel_demo.html',
    useShadowDom: false)
class CarouselDemo implements ScopeAware {

  Scope scope;
  
  int _myInterval = 2;
  int get myInterval {
    return _myInterval;
  }
  set myInterval(value) {
    try {
      _myInterval = toInt(value);
    } on Error catch(ex) {
      _myInterval = 0;
    }
  }
  
  List<Map<String,dynamic>> slides = [];

  CarouselDemo() {

    for (int i = 0; i < 4; i++) {
      addSlide();
    }
  }

  void addSlide() {
    int newWidth = 600 + slides.length;
    slides.add({
      'image': 'http://placekitten.com/g/${newWidth}/300',
      'text': ['More','Extra','Lots of','Surplus'][slides.length % 4] + ' ' +
        ['Cats', 'Kittys', 'Felines', 'Cutes'][slides.length % 4]
    });
  }
}
