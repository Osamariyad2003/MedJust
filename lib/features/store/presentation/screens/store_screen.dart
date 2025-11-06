import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_just/core/shared/widgets/loading_indicator.dart';
import 'package:med_just/features/store/presentation/screens/product_details.dart';
import 'package:med_just/features/store/presentation/widgets/category_chip.dart';
import 'package:med_just/features/store/presentation/widgets/product_frid.dart';
import '../bloc/store_bloc.dart';
import '../bloc/store_event.dart';
import '../bloc/store_state.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String? selectedCategory;
  final List<String> categories = ['tool', 'book', 'medical', 'electronics'];

  @override
  void initState() {
    super.initState();
    context.read<StoreBloc>().add(LoadAllProducts());
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width >= 600;
    final crossAxisCount = isTablet ? 3 : 2;
    final gridPadding = isTablet ? 24.0 : 16.0;
    final gridSpacing = isTablet ? 24.0 : 16.0;
    final chipHeight = isTablet ? 70.0 : 60.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Medical Store')),
      body: Column(
        children: [
          _buildCategoryFilter(chipHeight),
          Expanded(
            child: _buildProductsList(crossAxisCount, gridPadding, gridSpacing),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(double chipHeight) {
    return Container(
      height: chipHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1, // +1 for "All" option
        itemBuilder: (context, index) {
          if (index == 0) {
            return CategoryChip(
              label: 'All',
              isSelected: selectedCategory == null,
              onTap: () {
                setState(() {
                  selectedCategory = null;
                });
                context.read<StoreBloc>().add(LoadAllProducts());
              },
            );
          } else {
            final category = categories[index - 1];
            return CategoryChip(
              label: category,
              isSelected: selectedCategory == category,
              onTap: () {
                setState(() {
                  selectedCategory = category;
                });
                context.read<StoreBloc>().add(LoadProductsByCategory(category));
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildProductsList(
    int crossAxisCount,
    double gridPadding,
    double gridSpacing,
  ) {
    return BlocBuilder<StoreBloc, StoreState>(
      builder: (context, state) {
        if (state is StoreLoading) {
          return const Center(child: LoadingIndicator());
        } else if (state is ProductsLoaded) {
          if (state.products.isEmpty) {
            return const Center(child: Text('No products available'));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              double aspectRatio = constraints.maxWidth < 600 ? 0.7 : 0.9;
              return GridView.builder(
                padding: EdgeInsets.all(gridPadding),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: gridSpacing,
                  mainAxisSpacing: gridSpacing,
                  childAspectRatio: aspectRatio,
                ),
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return ProductGridItem(
                    product: product,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  ProductDetailsScreen(productId: product.id),
                        ),
                      );
                    },
                  );
                },
              );
            },
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
                    if (selectedCategory != null) {
                      context.read<StoreBloc>().add(
                        LoadProductsByCategory(selectedCategory!),
                      );
                    } else {
                      context.read<StoreBloc>().add(LoadAllProducts());
                    }
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }
        return const Center(child: Text('Select a category to view products'));
      },
    );
  }
}
