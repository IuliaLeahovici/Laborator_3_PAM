
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/product.dart';

class ProductRepository {
  Future<Map<String, dynamic>> loadData() async {

    // Intarziere de 3 secunde pentru testarea Loading
    await Future.delayed(
      const Duration(seconds: 3),
    );

    // Incarcarea asincrona a fisierului JSON
    final jsonString = await rootBundle.loadString(
      'assets/data/products.json',
    );

    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  Future<List<Product>> loadProducts() async {
    final data = await loadData();

    final homePage = data['homePage'] as Map<String, dynamic>;
    final productPage = data['productPage'] as Map<String, dynamic>;

    final allProducts = <Product>[];
    final seenIds = <String>{};

    void addProducts(List<dynamic> items) {
      for (final item in items) {
        final product = Product.fromJson(
          item as Map<String, dynamic>,
        );

        if (seenIds.add(product.id)) {
          allProducts.add(product);
        }
      }
    }

    addProducts(homePage['featureProducts'] as List<dynamic>);
    addProducts(homePage['recommended'] as List<dynamic>);

    final detail = productPage['product'] as Map<String, dynamic>;

    addProducts([detail]);
    addProducts(detail['similarProducts'] as List<dynamic>);

    return allProducts;
  }
}
