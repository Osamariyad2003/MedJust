import 'package:flutter/material.dart';
import 'package:med_just/core/models/store_model.dart';

class ProductGridItem extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductGridItem({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth;
        final imageHeight = itemWidth * 0.7; // Responsive image height
        final nameFontSize = (itemWidth * 0.09).clamp(12.0, 18.0);
        final priceFontSize = (itemWidth * 0.08).clamp(11.0, 16.0);
        final iconSize = (itemWidth * 0.18).clamp(28.0, 48.0);

        return Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child:
                      product.images.isNotEmpty
                          ? Image.network(
                            product.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: iconSize,
                                ),
                              );
                            },
                          )
                          : Container(
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.image_not_supported,
                              size: iconSize,
                            ),
                          ),
                ),

                // Product details
                Padding(
                  padding: EdgeInsets.all(itemWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: nameFontSize,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: itemWidth * 0.02),
                      Text(
                        '${product.price.toStringAsFixed(2)} \$',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: priceFontSize,
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
    );
  }
}
