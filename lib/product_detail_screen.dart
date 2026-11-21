
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/product_cubit.dart';
import 'cubit/product_state.dart';
import 'models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState
    extends State<ProductDetailScreen> {
  String? selectedColor;
  String? selectedSize;
  int imageIndex = 0;

  Map<String, dynamic>? _details(ProductSuccess state) {
    final product = state.productPage['product'];

    if (product is Map<String, dynamic> &&
        product['id'] == widget.product.id) {
      return product;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is! ProductSuccess) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text(
                state is ProductError
                    ? state.message
                    : 'Product details unavailable',
              ),
            ),
          );
        }

        final details = _details(state);
        final product = widget.product;

        final gallery = details == null
            ? <String>[product.imageUrl]
            : ((details['galleryImageUrls'] as List?)
            ?.cast<String>() ??
            <String>[
              details['mainImageUrl'] as String,
            ]);

        final colors =
            (details?['availableColors'] as List?) ?? [];

        final sizes =
            (details?['availableSizes'] as List?) ?? [];

        final availability =
            (details?['sizeAvailability'] as Map?) ?? {};

        final reviews =
            (details?['reviews'] as List?) ?? [];

        final similar =
            (details?['similarProducts'] as List?) ?? [];

        selectedColor ??= details?['selectedColor'] as String?;
        selectedSize ??= details?['selectedSize'] as String?;

        final favorite = state.isFavorite(product.id);

        return Scaffold(
          backgroundColor: Colors.white,

          bottomNavigationBar: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF343434),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              top: false,
              child: InkWell(
                onTap: () {
                  // AICI se pune acțiunea existentă
                  // de adăugare în coș.
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 22,
                    bottom: 12,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag,
                            color: Colors.white,
                            size: 23,
                          ),
                          SizedBox(width: 15),
                          Text(
                            'Add To Cart',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                    ],
                  ),
                ),
              ),
            ),
          ),

          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    height: 470,
                    child: Stack(
                        children: [
                          Positioned.fill(
                            child: PageView.builder(
                              itemCount: gallery.length,
                              onPageChanged: (index) {
                                setState(() {
                                  imageIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return Image.network(
                                  gallery[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                  const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 48,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // BUTON BACK
                          Positioned(
                            top: 15,
                            left: 20,
                            child: SafeArea(
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ),
                          ),

                          // BUTON FAVORITE
                          Positioned(
                            top: 15,
                            right: 20,
                            child: SafeArea(
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  icon: Icon(
                                    favorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    context
                                        .read<ProductCubit>()
                                        .toggleFavorite(product.id);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              ),
              if (gallery.length > 1) ...[
                Transform.translate(
                  offset: const Offset(0, -50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      gallery.length,
                          (index) => Container(
                        width: imageIndex == index ? 9 : 6,
                        height: imageIndex == index ? 9 : 6,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: imageIndex == index
                              ? Colors.black
                              : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 0),


              Container(
                transform: Matrix4.translationValues(0, -50, 0),
                padding: const EdgeInsets.fromLTRB(30, 35, 30, 25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 18,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF252525),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Text(
                          '${product.currency == "USD" ? "\$" : product.currency} ${product.price.toStringAsFixed(2)}',                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

              if (details?['rating'] != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    ...List.generate(
                      5,
                          (index) => const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.star,
                          color: Color(0xFF4E9286),
                          size: 22,
                        ),
                      ),
                    ),

                    const SizedBox(width: 5),

                    const Text(
                      '(83)',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Divider(
                  color: Color(0xFFEEEEEE),
                  thickness: 1,
                ),

                const SizedBox(height: 25),
              ],



              if (colors.isNotEmpty || sizes.isNotEmpty) ...[
                const SizedBox(height: 1),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // COLOR
                    if (colors.isNotEmpty)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Color',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              children: colors.map((item) {
                                final color = item as Map<String, dynamic>;
                                final id = color['id'] as String;
                                final hex = (color['value'] as String)
                                    .replaceFirst('#', '');

                                final selected = selectedColor == id;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() => selectedColor = id);
                                  },
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: selected
                                          ? Border.all(
                                        color: Colors.grey.shade400,
                                        width: 1.5,
                                      )
                                          : null,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(
                                          int.parse('FF$hex', radix: 16),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                    // SIZE
                    if (sizes.isNotEmpty)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 35),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Size',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              children: sizes.map((item) {
                                final size = item.toString();
                                final available =
                                    availability[size] != false;
                                final selected = selectedSize == size;

                                return GestureDetector(
                                  onTap: available
                                      ? () {
                                    setState(() {
                                      selectedSize = size;
                                    });
                                  }
                                      : null,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: selected
                                          ? const Color(0xFF505050)
                                          : const Color(0xFFF7F7F7),
                                    ),
                                    child: Text(
                                      size,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: selected
                                            ? Colors.white
                                            : available
                                            ? Colors.black87
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
              ],

              if (details?['description'] != null) ...[
                const SizedBox(height: 22),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 26,
                      color: Colors.black87,
                    ),
                  ],
                ),
                const Divider(
                  height: 25,
                  thickness: 1,
                  color: Color(0xFFEEEEEE),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF777777),
                      height: 1.6,
                    ),
                    children: [
                      TextSpan(
                        text: '${details?['description'] ?? ''}  ',
                      ),
                      const TextSpan(
                        text: 'Read more',
                        style: TextStyle(
                          color: Color(0xFF508A7B),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF508A7B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],


              if (details?['ratingBreakdown'] is List) ...[
                const SizedBox(height: 28),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reviews',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down),
                  ],
                ),

                const Divider(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${details?['rating'] ?? 4.9}',
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 8, bottom: 10),
                          child: Text(
                            'OUT OF 5',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: List.generate(
                            5,
                                (_) => const Icon(
                              Icons.star,
                              color: Color(0xFF508F80),
                              size: 19,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${details?['ratingCount'] ?? 83} ratings',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                ...(details!['ratingBreakdown'] as List).map((item) {
                  final row = item as Map<String, dynamic>;
                  final percentage =
                  (row['percentage'] as num).toDouble();

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 15,
                          child: Text(
                            '${row['stars']}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.star,
                          color: Color(0xFF508F80),
                          size: 15,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 5,
                            backgroundColor: Colors.grey.shade200,
                            color: const Color(0xFF508F80),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 38,
                          child: Text(
                            '${row['percentage']}%',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 22),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${details?['reviewCount'] ?? reviews.length} Reviews',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const Row(
                      children: [
                        Text(
                          'WRITE A REVIEW',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.edit,
                          color: Colors.grey,
                          size: 15,
                        ),
                      ],
                    ),
                  ],
                ),
              ],

              if (reviews.isNotEmpty) ...[
                const SizedBox(height: 24),

                ...reviews.map((item) {
                  final review = item as Map<String, dynamic>;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                review['avatarUrl'] as String,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review['author'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: List.generate(
                                      5,
                                          (index) => Icon(
                                        Icons.star,
                                        size: 14,
                                        color: index <
                                            ((review['rating'] as num)
                                                .round())
                                            ? const Color(0xFF508F80)
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              review['createdAtLabel'] as String,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          review['text'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],


              if (similar.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Similar Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 210,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: similar.length,
                    separatorBuilder: (_, _) =>
                    const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final other = Product.fromJson(
                        similar[index] as Map<String, dynamic>,
                      );

                      return GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(
                                    product: other,
                                  ),
                            ),
                          );
                        },
                        child: SizedBox(
                          width: 135,
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius:
                                BorderRadius.circular(12),
                                child: Image.network(
                                  other.imageUrl,
                                  width: 135,
                                  height: 145,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                other.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '\$${other.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 24),

              SizedBox(
                height: 52,
              ),

              if (details == null) ...[
                const SizedBox(height: 10),
                const Text(
                  'Additional details are not available ',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],

                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

