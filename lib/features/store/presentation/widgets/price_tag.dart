import 'package:flutter/material.dart';

class PriceTag extends StatelessWidget {
  final double price;

  const PriceTag({Key? key, required this.price}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Text(
        '${price.toStringAsFixed(2)} \$',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
          fontSize: 18,
        ),
      ),
    );
  }
}
