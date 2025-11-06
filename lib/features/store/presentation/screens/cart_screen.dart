import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_just/core/models/store_model.dart';
import 'package:med_just/features/auth/presentation/controller/auth_bloc.dart';
import 'package:med_just/features/auth/presentation/controller/auth_state.dart';
import 'package:med_just/features/store/presentation/bloc/store_bloc.dart';
import 'package:med_just/features/store/presentation/bloc/store_event.dart';
import 'package:med_just/features/store/presentation/bloc/store_state.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  initState() {
    super.initState();
    context.read<StoreBloc>().add(LoadCart());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        centerTitle: true,
        actions: [
          BlocBuilder<StoreBloc, StoreState>(
            builder: (context, state) {
              final items = context.read<StoreBloc>().items;

              if (items.isNotEmpty) {
                return IconButton(
                  tooltip: 'Clear cart',
                  icon: const Icon(Icons.delete_sweep_rounded),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Clear Cart'),
                            content: const Text(
                              'Are you sure you want to remove all items from your cart?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                    );
                    if (confirmed == true) {
                      context.read<StoreBloc>().add(ClearCart());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cart cleared')),
                      );
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<StoreBloc, StoreState>(
        builder: (context, state) {
          final items = context.read<StoreBloc>().items;

          final subtotal = items.fold<double>(
            0,
            (s, p) => s + p.price * (p.quantity ?? 1),
          );
          const shipping = 0.0;
          final total = subtotal + shipping;

          if (items.isEmpty) {
            return _EmptyCart(onBrowse: () => Navigator.pop(context));
          }

          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final product = items[i];
                      return Dismissible(
                        key: ValueKey(product.id),
                        direction: DismissDirection.endToStart,
                        background: _SwipeBg(
                          color: cs.error,
                          icon: Icons.delete_outline,
                        ),
                        onDismissed:
                            (_) => context.read<StoreBloc>().add(
                              RemoveFromCart(product.id),
                            ),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: InkWell(
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: cs.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child:
                                        (product.images.isNotEmpty &&
                                                product.images.first.isNotEmpty)
                                            ? Image.network(
                                              product.images.first,
                                              fit: BoxFit.cover,
                                            )
                                            : Icon(
                                              Icons.image_not_supported_rounded,
                                              color: cs.onSurfaceVariant,
                                            ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '\$${product.price.toStringAsFixed(2)}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleSmall?.copyWith(
                                            color: cs.primary,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            _QtyBtn(
                                              icon: Icons.remove_rounded,
                                              onTap:
                                                  () => context
                                                      .read<StoreBloc>()
                                                      .add(
                                                        DecrementCartItem(
                                                          product.id,
                                                        ),
                                                      ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                  ),
                                              child: Text(
                                                '${product.quantity ?? 1}',
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.titleMedium,
                                              ),
                                            ),
                                            _QtyBtn(
                                              icon: Icons.add_rounded,
                                              onTap:
                                                  () => context
                                                      .read<StoreBloc>()
                                                      .add(
                                                        IncrementCartItem(
                                                          product.id,
                                                        ),
                                                      ),
                                            ),
                                            IconButton(
                                              tooltip: 'Remove',
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                              ),
                                              onPressed:
                                                  () => context
                                                      .read<StoreBloc>()
                                                      .add(
                                                        RemoveFromCart(
                                                          product.id,
                                                        ),
                                                      ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Remove',
                                    icon: const Icon(Icons.close_rounded),
                                    onPressed:
                                        () => context.read<StoreBloc>().add(
                                          RemoveFromCart(product.id),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    border: Border(top: BorderSide(color: cs.outlineVariant)),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SummaryRow(
                          label: 'Subtotal',
                          value: '\$${subtotal.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 6),
                        _SummaryRow(
                          label: 'Shipping',
                          value:
                              shipping == 0
                                  ? 'Free'
                                  : '\$${shipping.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 10),
                        _SummaryRow(
                          label: 'Total',
                          value: '\$${total.toStringAsFixed(2)}',
                          strong: true,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed:
                                items.isNotEmpty
                                    ? () {
                                      final user =
                                          context.read<AuthBloc>().currentUser;
                                      print(user?.phone);

                                      if (user == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Please sign in and complete your profile with a phone number to place an order',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      context.read<StoreBloc>().add(
                                        SaveOrder(
                                          productsIds:
                                              items.map((p) => p.id).toList(),
                                          totalAmount: total,
                                          shippingAddress: user.address ?? '',
                                          userId: user.id,
                                          userPhone: user.phone,
                                        ),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Order placed'),
                                        ),
                                      );
                                    }
                                    : null,
                            child: const Text('Checkout'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;
  const _SummaryRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    final styleBase = Theme.of(context).textTheme.bodyLarge!;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style:
                strong
                    ? styleBase.copyWith(fontWeight: FontWeight.w700)
                    : styleBase,
          ),
        ),
        Text(
          value,
          style:
              strong
                  ? styleBase.copyWith(fontWeight: FontWeight.w800)
                  : styleBase,
        ),
      ],
    );
  }
}

class _SwipeBg extends StatelessWidget {
  final Color color;
  final IconData icon;
  const _SwipeBg({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Ink(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: cs.onSurface),
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final VoidCallback onBrowse;

  const _EmptyCart({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 72,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Explore the store and add items you like.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onBrowse,
            child: const Text('Browse products'),
          ),
        ],
      ),
    );
  }
}
