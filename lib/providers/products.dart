import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/models/http_exception.dart';
// import 'product.dart';
import './product.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Black T-Shirt',
    //   description: 'Slim fit cotton round neck T-Shirt',
    //   price: 20.00,
    //   imageUrl:
    //       'https://static.cilory.com/365079-thickbox_default/levis-black-full-sleeves-pre-winter-t-shirt.jpg',
    // ),
    // Product(
    //     id: 'p2',
    //     title: 'Jacket',
    //     description: 'Real Brown Leather jacket',
    //     price: 60.00,
    //     imageUrl:
    //         'https://media.istockphoto.com/photos/mans-blank-black-leather-jacket-backisolated-on-white-wclipping-path-picture-id157440390?k=6&m=157440390&s=612x612&w=0&h=T6FPlhLStJYe9ECm05qNOBowm7uQrQgcEmEhz2IYVsA='),
    // Product(
    //   id: 'p3',
    //   title: 'Trouser',
    //   description: 'Mens Sports Trouser',
    //   price: 25.00,
    //   imageUrl:
    //       'https://5.imimg.com/data5/SELLER/Default/2020/12/FU/FE/AE/66384849/new-product-500x500.jpeg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'Shirts',
    //   description: 'Formal Mens Shirts',
    //   price: 30.00,
    //   imageUrl:
    //       'https://cdn.shopclues.com/images1/thumbnails/91266/320/320/140331852-91266140-1534494280.jpg',
    // ),
  ];
  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if(_showFavoritesOnly){
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }
  // void showFavoritesOnly(){
  //  _showFavoritesOnly = true;
  //  notifyListeners();
  // }
  //
  // void showAll(){
  //  _showFavoritesOnly = false;
  //  notifyListeners();
  // }

  Future<void> fetchAndSetProducts() async {
    const url =
        'https://shop-app-7ff05-default-rtdb.firebaseio.com/products.json';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if(extractedData == null){
        return;
      }
      final List<Product> loadedProduct = [];
      extractedData.forEach((prodId, prodData) {
        loadedProduct.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite: prodData['isFavorite'],
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProduct;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    const url =
        'https://shop-app-7ff05-default-rtdb.firebaseio.com/products.json';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavorite': product.isFavorite,
        }),
      );
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex > 0) {
      final url =
          'https://shop-app-7ff05-default-rtdb.firebaseio.com/products/$id.json';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('.....');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://shop-app-7ff05-default-rtdb.firebaseio.com/products/$id.json';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    existingProduct = null;
  }
}
