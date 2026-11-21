
import '../models/product.dart';

abstract class ProductState {
  const ProductState();
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductSuccess extends ProductState {
  final Map<String, dynamic> data;
  final List<Product> products;
  final List<Product> allProducts;
  final Set<String> favorites;

  final String searchQuery;
  final String sortOrder;
  final bool favoritesOnly;

  const ProductSuccess({
    required this.data,
    required this.products,
    required this.allProducts,
    required this.favorites,
    this.searchQuery = '',
    this.sortOrder = 'default',
    this.favoritesOnly = false,
  });

  Map<String, dynamic> get homePage =>
      data['homePage'] as Map<String, dynamic>;

  Map<String, dynamic> get productPage =>
      data['productPage'] as Map<String, dynamic>;

  bool isFavorite(String productId) {
    return favorites.contains(productId);
  }
}

class ProductEmpty extends ProductState {
  final String message;
  final String searchQuery;
  final String sortOrder;
  final bool favoritesOnly;

  const ProductEmpty({
    this.message = 'Nu au fost gasite produse.',
    this.searchQuery = '',
    this.sortOrder = 'default',
    this.favoritesOnly = false,
  });
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);
}
