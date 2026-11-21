
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository repository;

  ProductCubit(this.repository)
      : super(const ProductInitial());

  Map<String, dynamic> _data = {};
  List<Product> _allProducts = [];

  final Set<String> _favorites = {};

  String _searchQuery = '';
  String _sortOrder = 'default';
  bool _favoritesOnly = false;

  Future<void> loadProducts() async {
    emit(const ProductLoading());

    try {
      final data = await repository.loadData();

      final homePage =
      data['homePage'] as Map<String, dynamic>;

      final productPage =
      data['productPage'] as Map<String, dynamic>;

      final products = <Product>[];
      final seenIds = <String>{};

      void addProducts(List<dynamic> items) {
        for (final item in items) {
          final product = Product.fromJson(
            item as Map<String, dynamic>,
          );

          if (seenIds.add(product.id)) {
            products.add(product);
          }
        }
      }

      addProducts(
        homePage['featureProducts'] as List<dynamic>,
      );

      addProducts(
        homePage['recommended'] as List<dynamic>,
      );

      final detail =
      productPage['product'] as Map<String, dynamic>;

      addProducts([detail]);

      addProducts(
        detail['similarProducts'] as List<dynamic>,
      );

      _data = data;
      _allProducts = products;

      final actions = detail['actions'];

      if (actions is Map<String, dynamic> &&
          actions['isFavorite'] == true) {
        _favorites.add(detail['id'] as String);
      }

      _updateProducts();
    } catch (e) {
      emit(ProductError(
        'Eroare la incarcarea datelor: $e',
      ));
    }
  }

  void searchProducts(String query) {
    _searchQuery = query;
    _updateProducts();
  }

  void sortProducts(String order) {
    _sortOrder = order;
    _updateProducts();
  }

  void toggleFavorite(String productId) {
    if (!_favorites.add(productId)) {
      _favorites.remove(productId);
    }

    _updateProducts();
  }

  void showFavoritesOnly(bool value) {
    _favoritesOnly = value;
    _updateProducts();
  }

  void clearFilters() {
    _searchQuery = '';
    _sortOrder = 'default';
    _favoritesOnly = false;
    _updateProducts();
  }

  void _updateProducts() {
    if (_data.isEmpty) return;

    var filtered = _allProducts.where((product) {
      final matchesSearch = product.name
          .toLowerCase()
          .contains(_searchQuery.trim().toLowerCase());

      final matchesFavorites =
          !_favoritesOnly ||
              _favorites.contains(product.id);

      return matchesSearch && matchesFavorites;
    }).toList();

    switch (_sortOrder) {
      case 'price_asc':
        filtered.sort(
              (a, b) => a.price.compareTo(b.price),
        );
        break;

      case 'price_desc':
        filtered.sort(
              (a, b) => b.price.compareTo(a.price),
        );
        break;

      case 'name':
        filtered.sort(
              (a, b) => a.name.compareTo(b.name),
        );
        break;
    }

    if (_allProducts.isEmpty) {
      emit(ProductEmpty(
        searchQuery: _searchQuery,
        sortOrder: _sortOrder,
        favoritesOnly: _favoritesOnly,
      ));
      return;
    }

    emit(ProductSuccess(
      data: _data,
      products: List.unmodifiable(filtered),
      allProducts: List.unmodifiable(_allProducts),
      favorites: Set.unmodifiable(_favorites),
      searchQuery: _searchQuery,
      sortOrder: _sortOrder,
      favoritesOnly: _favoritesOnly,
    ));
  }
}
