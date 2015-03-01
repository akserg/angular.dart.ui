**Carousel** creates a carousel similar to bootstrap's image carousel.
Use a `<carousel>` element with `<slide>` elements inside it.  It will automatically cycle through the slides at a given rate, and a current-index variable will be kept in sync with the currently visible slide.

## Demo
Use the `<carousel>` element in your html
```html
<div style="height: 305px">
  <carousel interval="2500">
    <slide ng-repeat="item in slides" active="item['active']">
      <img ng-src="{{item['image']}}" style="margin:auto;">
      <div class="carousel-caption">
        <h4>Slide {{$index}}</h4>
        <p>{{item['text']}}</p>
      </div>
    </slide>
  </carousel>
</div>
```

Generate the slide content in dart
```dart
@Component(
    selector: 'carousel-demo',
    templateUrl: 'your_html.html',
    useShadowDom: false)
class CarouselDemo {
  List<Map<String,dynamic>> slides = [];

  /// Generate 4 start slides
  CarouselDemo() {
    for (int i = 0; i < 4; i++) {
      addSlide();
    }
  }

  /// Function to generate random cat picture slides
  void addSlide() {
    int newWidth = 600 + slides.length;
    slides.add({
      'image': 'http://placekitten.com/g/${newWidth}/300',
      'text': ['More','Extra','Lots of','Surplus'][slides.length % 4] + ' ' +
        ['Cats', 'Kittys', 'Felines', 'Cutes'][slides.length % 4]
    });
  }
}
```

Add full URL address to `your_html.html` into the list of angular trasformers in `pubspec.yaml` file:

```
transformers:
- angular:
    html_files:
      - .../your_html.html
```