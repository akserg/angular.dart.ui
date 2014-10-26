// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.
part of angular.ui.demo;

@Decorator(selector: '[dd-shopping-demo-controller]'
  //,useShadowDom: false
  )
class DragDropShoppingBasketDemoController {
  
  bool get valid => true;
  
  String value = "me";
  List<Product> availableProducts = [];
  List<Product> shoppingBasket = [];
  
  DragDropShoppingBasketDemoController() {
    print("Starting DragDropShoppingBasketDemoController");
    availableProducts.add(new Product("Blue Shoes", 3, 35));
    availableProducts.add(new Product("Good Jacket", 1, 90));
    availableProducts.add(new Product("Red Shirt", 5, 12));
    availableProducts.add(new Product("Blue Jeans", 4, 60));
    print("Available products: " + availableProducts.toString());
  }
  
  void orderedProduct(Product orderedProduct) {
    print("New ordered product: " + orderedProduct.name);
    orderedProduct.quantity--;
  }
  
  void addToBasket(Product newProduct) {
    print("Add to basket: " + newProduct.name);
    for(Product product in shoppingBasket) {
      if (product.name == newProduct.name) {
        product.quantity++;
        return;
      }
    }
    shoppingBasket.add(new Product(newProduct.name, 1, newProduct.cost));
  }
  
  int totalCost() {
    int cost = 0;
    for(Product product in shoppingBasket) {
      cost+= (product.cost*product.quantity);
    }
    return cost;
  }
}

class Product {
  
  int quantity;
  int cost;
  String name;
  
  Product(this.name, this.quantity, this.cost);

}


@Component(
    selector: '[dd-list-demo-controller]',
    publishAs: 'listCtrl',
    useShadowDom: false)
class DragDropListDemoController {
  
  List<String> todoList = ['Task 1: Fix Blu Bug','Task 2: Create Sortable','Task 3: Improve Tabs','Task 4: Publish new version'];
  List<String> ongoingList = ['Task 5: Create Drag&Drop'];
  List<String> doneList = ['Task 6: Create Alert', 'Task 7: Test Accordion'];
  
  void add(List<String> list, String value) {
    list.add(value);
  }
  
  void remove(List<String> list, String value) {
    list.remove(value);
  }
}


@Component(
    selector: '[dd-custom-image-demo-controller]',
    publishAs: 'customImageCtrl',
    useShadowDom: false)
class DragDropCustomImageDemoController {
  
  DragDropConfig dragdropConfig = new DragDropConfig();
  
  DragDropCustomImageDemoController() {
    dragdropConfig.dragImage = new DragImage(new dom.ImageElement(src: "dragdrop/smile.jpg"));
    dragdropConfig.dropEffect = DataTransferEffect.COPY;
    dragdropConfig.dragEffect = DataTransferEffect.COPY;
  }
 
}


@Component(
    selector: '[dd-handler-demo-controller]',
    publishAs: 'listCtrl',
    useShadowDom: false)
class DragDropHandlerDemoController {
  
  List<String> todoList = ['Task 1: Fix Blu Bug','Task 2: Create Sortable','Task 3: Improve Tabs','Task 4: Publish new version'];
  List<String> doneList = ['Task 6: Create Alert', 'Task 7: Test Accordion'];
  
  void done(String value) {
    todoList.remove(value);
    doneList.add(value);
  }
  
  void undo(String value) {
    doneList.remove(value);
    todoList.add(value);
  }
}