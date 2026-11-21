
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/product_cubit.dart';
import 'cubit/product_state.dart';
import 'models/product.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  String _selectedCategory = 'women';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  void _openDetails(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          product: product,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/icons/line_icon.png',
            width: 24,
            height: 24,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('GemStore'),
              ),
            );
          },
        ),
        title: const Text(
          'GemStore',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/icons/bell_pin.png',
              width: 24,
              height: 24,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications'),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading ||
              state is ProductInitial) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            );
          }

          if (state is ProductError) {
            return _buildError(state.message);
          }

          if (state is ProductEmpty) {
            return _buildEmpty(state);
          }

          if (state is ProductSuccess) {
            return _buildHomeContent(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<ProductCubit>().loadProducts();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ProductEmpty state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildSearchAndSort(
            state.sortOrder,
          ),
        ),
        const Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off,
                  size: 60,
                  color: Colors.grey,
                ),
                SizedBox(height: 12),
                Text(
                  'No products found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: _clearFilters,
          child: const Text('Clear filters'),
        ),
      ],
    );
  }

  void _clearFilters() {
    _searchController.clear();
    context.read<ProductCubit>().clearFilters();
  }

  Widget _buildHomeContent(ProductSuccess state) {
    final home = state.homePage;

    final categories =
    home['categories'] as List<dynamic>;

    final banner =
    home['heroBanner'] as Map<String, dynamic>;

    final newCollection =
    home['newCollection'] as Map<String, dynamic>;

    final topCollections =
    home['topCollections'] as List<dynamic>;

    final categoryPromos =
    home['categoryPromos'] as List<dynamic>;

    final featureProducts =
    home['featureProducts'] as List<dynamic>;

    final recommended =
    home['recommended'] as List<dynamic>;

    final isFiltered =
        state.searchQuery.isNotEmpty ||
            state.sortOrder != 'default' ||
            state.favoritesOnly;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            _buildCategories(categories),

            const SizedBox(height: 24),

            _buildSearchAndSort(state.sortOrder),

            const SizedBox(height: 20),

            _buildFavoritesButton(state),

            const SizedBox(height: 20),

            if (isFiltered) ...[
              _sectionTitle('Products'),
              const SizedBox(height: 12),
              _buildProductList(
                state.products,
                state,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear filters'),
              ),
            ] else ...[
              _buildHeroBanner(banner),

              const SizedBox(height: 30),

              _sectionTitle('Featured Products'),

              const SizedBox(height: 16),

              _buildProductsFromJson(
                featureProducts,
                state,
              ),

              const SizedBox(height: 24),

              _buildNewCollection(newCollection),

              const SizedBox(height: 24),

              _sectionTitle('Recommended'),

              const SizedBox(height: 16),

              _buildRecommended(
                recommended,
                state,
              ),

              const SizedBox(height: 30),

              _sectionTitle('Top Collection'),

              const SizedBox(height: 16),

              ...topCollections.map((item) {
                final collection =
                item as Map<String, dynamic>;

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 16,
                  ),
                  child: _buildCollectionBanner(
                    collection,
                  ),
                );
              }),

              const SizedBox(height: 16),

              _buildCategoryPromos(categoryPromos),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(List<dynamic> categories) {
    const localIcons = {
      'women': 'assets/icons/women_icon.png',
      'men': 'assets/icons/men_icon.png',
      'accessories':
      'assets/icons/glasses_icon.png',
      'beauty': 'assets/icons/brush_icon.png',
    };

    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: categories.map((item) {
        final category =
        item as Map<String, dynamic>;

        final id = category['id'] as String;
        final name = category['name'] as String;

        final selected = _selectedCategory == id;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = id;
            });

            // JSON-ul nu asociaza produsele
            // cu categorii individuale.
            ScaffoldMessenger.of(context)
                .showSnackBar(
              SnackBar(
                content: Text(
                  'Selected category: $name',
                ),
                duration: const Duration(
                  seconds: 1,
                ),
              ),
            );
          },
          child: Column(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? Colors.black
                      : const Color(0xFFEFEFEF),
                ),
                child: Center(
                  child: Image.asset(
                    localIcons[id] ??
                        'assets/icons/women_icon.png',
                    width: 30,
                    height: 30,
                    color: selected
                        ? Colors.white
                        : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: selected
                      ? Colors.black
                      : Colors.grey,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchAndSort(String sortOrder) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (value) {
            context
                .read<ProductCubit>()
                .searchProducts(value);
          },
          decoration: InputDecoration(
            hintText: 'Search products...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                context
                    .read<ProductCubit>()
                    .searchProducts('');
              },
            ),
            filled: true,
            fillColor: const Color(0xFFF7F7F9),
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(
              Icons.sort,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text('Sort by'),
            const Spacer(),
            DropdownButton<String>(
              value: sortOrder,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: 'default',
                  child: Text('Default'),
                ),
                DropdownMenuItem(
                  value: 'price_asc',
                  child: Text('Price: Low to High'),
                ),
                DropdownMenuItem(
                  value: 'price_desc',
                  child: Text('Price: High to Low'),
                ),
                DropdownMenuItem(
                  value: 'name',
                  child: Text('Name A-Z'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  context
                      .read<ProductCubit>()
                      .sortProducts(value);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFavoritesButton(
      ProductSuccess state,
      ) {
    return Row(
      children: [
        const Icon(
          Icons.favorite_border,
          size: 20,
        ),
        const SizedBox(width: 8),
        const Text('Favorites only'),
        const Spacer(),
        Switch(
          value: state.favoritesOnly,
          activeThumbColor: Colors.black,
          onChanged: (value) {
            context
                .read<ProductCubit>()
                .showFavoritesOnly(value);
          },
        ),
      ],
    );
  }

  Widget _buildHeroBanner(
      Map<String, dynamic> banner,
      ) {
    return Container(
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _networkImage(
              banner['imageUrl'] as String,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(
                      alpha: 0.4,
                    ),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              top: 28,
              right: 20,
              child: Text(
                banner['title'] as String,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: List.generate(
                  (banner['slides'] as num).toInt(),
                      (index) {
                    final active =
                        index == banner['activeSlide'];

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      width: active ? 10 : 6,
                      height: active ? 10 : 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active
                            ? Colors.white
                            : Colors.white70,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsFromJson(
      List<dynamic> items,
      ProductSuccess state,
      ) {
    final products = items
        .map(
          (item) => Product.fromJson(
        item as Map<String, dynamic>,
      ),
    )
        .toList();

    return _buildProductList(products, state);
  }


  Widget _buildProductList(
      List<Product> products,
      ProductSuccess state,
      ) {
    if (products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No products found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 275,

      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, _) =>
        const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final product = products[index];

          return GemProductCard(
            product: product,
            isFavorite:
            state.isFavorite(product.id),
            onFavorite: () {
              context
                  .read<ProductCubit>()
                  .toggleFavorite(product.id);
            },
            onTap: () => _openDetails(product),
          );
        },
      ),
    );
  }

  Widget _buildNewCollection(
      Map<String, dynamic> collection,
      ) {
    return _buildCollectionBanner(collection);
  }

  Widget _buildRecommended(
      List<dynamic> items,
      ProductSuccess state,
      ) {
    return SizedBox(
      height: 115,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) =>
        const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final product = Product.fromJson(
            items[index] as Map<String, dynamic>,
          );

          return GestureDetector(
            onTap: () => _openDetails(product),
            child: Container(
              width: 255,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.04,
                    ),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(10),
                    child: SizedBox(
                      width: 75,
                      height: 85,
                      child: _networkImage(
                        product.imageUrl,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow:
                          TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _price(product),
                          style: const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            context
                                .read<ProductCubit>()
                                .toggleFavorite(
                              product.id,
                            );
                          },
                          child: Icon(
                            state.isFavorite(
                              product.id,
                            )
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: state.isFavorite(
                              product.id,
                            )
                                ? Colors.red
                                : Colors.grey,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCollectionBanner(
      Map<String, dynamic> collection,
      ) {
    return SizedBox(
      width: double.infinity,
      height: 190,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _networkImage(
              collection['imageUrl'] as String,
            ),
            Container(
              color: Colors.black.withValues(
                alpha: 0.2,
              ),
            ),
            Positioned(
              left: 20,
              bottom: 24,
              right: 20,
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  if (collection['label'] != null)
                    Text(
                      collection['label'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  const SizedBox(height: 5),
                  Text(
                    collection['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPromos(
      List<dynamic> promos,
      ) {
    return Row(
      children: promos.map((item) {
        final promo =
        item as Map<String, dynamic>;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            child: ClipRRect(
              borderRadius:
              BorderRadius.circular(14),
              child: SizedBox(
                height: 200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _networkImage(
                      promo['imageUrl'] as String,
                    ),
                    Container(
                      color: Colors.black.withValues(
                        alpha: 0.15,
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 10,
                      right: 10,
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            promo['category'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            promo['title'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}

class GemProductCard extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  const GemProductCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 145,
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(12),
                    child: SizedBox.expand(
                      child: _networkImage(
                        product.imageUrl,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: onFavorite,
                      child: Container(
                        padding:
                        const EdgeInsets.all(7),
                        decoration:
                        const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isFavorite
                              ? Colors.red
                              : Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _price(product),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _price(Product product) {
  final symbol =
  product.currency == 'USD'
      ? '\$'
      : product.currency;

  return '$symbol ${product.price.toStringAsFixed(2)}';
}

Widget _networkImage(String url) {
  return Image.network(
    url,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      return Container(
        color: const Color(0xFFF2F2F2),
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey,
            size: 36,
          ),
        ),
      );
    },
    loadingBuilder: (context, child, progress) {
      if (progress == null) {
        return child;
      }

      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.grey,
        ),
      );
    },
  );
}
