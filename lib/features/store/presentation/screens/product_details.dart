import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_just/core/di/di.dart';
import 'package:med_just/core/shared/widgets/loading_indicator.dart';
import 'package:med_just/features/store/data/store_repo.dart';
import 'package:med_just/features/store/presentation/screens/cart_screen.dart';
import 'package:med_just/features/store/presentation/widgets/image_carousel.dart';
import 'package:med_just/features/store/presentation/widgets/price_tag.dart';
import '../bloc/store_bloc.dart';
import '../bloc/store_event.dart';
import '../bloc/store_state.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String productId;

  const ProductDetailsScreen({Key? key, required this.productId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              StoreBloc(repository: di<StoreRepository>())
                ..add(LoadProductDetails(productId)),
      child: BlocConsumer<StoreBloc, StoreState>(
        listener: (context, state) {
          if (state is StoreError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                state is ProductDetailsLoaded
                    ? state.product.name
                    : 'Product Details',
              ),
            ),
            body: _buildBody(context, state),
            bottomNavigationBar:
                state is ProductDetailsLoaded
                    ? ProductBottomBar(state: state)
                    : null,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, StoreState state) {
    if (state is StoreLoading) {
      return const Center(child: LoadingIndicator());
    } else if (state is ProductDetailsLoaded) {
      final product = state.product;
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel if available
            product.images.isNotEmpty
                ? ImageCarousel(images: product.images)
                : Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported, size: 64),
                ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  PriceTag(price: product.price),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : 'No description available',
                  ),
                  const SizedBox(height: 16),
                  SpecificationsCard(product: product),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (state is StoreError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<StoreBloc>().add(LoadProductDetails(productId));
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    return const Center(child: LoadingIndicator());
  }
}

class ProductBottomBar extends StatelessWidget {
  final ProductDetailsLoaded state;
  const ProductBottomBar({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<StoreBloc>().add(AddToCart(state.product));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Added to cart')));
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => BlocProvider.value(
                          value: context.read<StoreBloc>(),
                          child: const CartScreen(),
                        ),
                  ),
                );
              },
              icon: Icon(Icons.shopping_cart),
              label: Text('Add to Cart'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SpecificationsCard extends StatelessWidget {
  final dynamic product;
  const SpecificationsCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Specifications',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InfoRow(label: 'Category', value: product.categoryId),
            InfoRow(label: 'ID', value: product.id),
            InfoRow(
              label: 'Added on',
              value:
                  '${product.createdAt.day}/${product.createdAt.month}/${product.createdAt.year}',
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const InfoRow({Key? key, required this.label, required this.value})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
