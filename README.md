angular.ui [![Build Status](https://drone.io/github.com/akserg/angular.dart.ui/status.png)](https://drone.io/github.com/akserg/angular.dart.ui/latest)
===============

Port of Angular-UI to Dart.

###Buttons (ButtonsModule)
There are 2 directives that can make a group of buttons to behave like a set of checkboxes or radio buttons.
Buttons markup:

```
<div buttons-ctrl>

  <h4>Single toggle</h4>
  <pre>{{ctrl.singleModel}}</pre>
  <button type="button" class="btn btn-primary" ng-model="ctrl.singleModel" btn-checkbox>
      Single Toggle
  </button>

  <h4>Checkbox</h4>
  <pre>{{ctrl.leftModel}} - {{ctrl.middleModel}} - {{ctrl.rightModel}}</pre>
  <div class="btn-group">
      <button type="button" class="btn btn-primary" ng-model="ctrl.leftModel" btn-checkbox>Left</button>
      <button type="button" class="btn btn-primary" ng-model="ctrl.middleModel" btn-checkbox>Middle</button>
      <button type="button" class="btn btn-primary" ng-model="ctrl.rightModel" btn-checkbox>Right</button>
  </div>

  <h4>Radio</h4>
  <pre>{{ctrl.radioModel}}</pre>
  <div class="btn-group">
      <button type="button" class="btn btn-primary" ng-model="ctrl.radioModel" btn-radio="Left">Left</button>
      <button type="button" class="btn btn-primary" ng-model="ctrl.radioModel" btn-radio="Middle">Middle</button>
      <button type="button" class="btn btn-primary" ng-model="ctrl.radioModel" btn-radio="Right">Right</button>
  </div>
</div>
```

Buttons Controller Dart code:

```
/**
 * Buttons controller.
 */
@NgController(selector: 'buttons-ctrl', publishAs: 'ctrl')
class ButtonsCtrl {
  
  @NgTwoWay("singleModel")
  var singleModel = '0';
  
  @NgTwoWay("radioModel")
  var radioModel = 'Middle';
  
  @NgTwoWay("leftModel")
  var leftModel = false;
  
  @NgTwoWay("middleModel")
  var middleModel = false;
  
  @NgTwoWay("rightModel")
  var rightModel = false;
}
```