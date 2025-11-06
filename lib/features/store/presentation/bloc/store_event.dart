import 'package:equatable/equatable.dart';
import 'package:med_just/core/models/store_model.dart';

abstract class StoreEvent extends Equatable {
  const StoreEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllProducts extends StoreEvent {}

class LoadProductsByCategory extends StoreEvent {
  final String categoryId;

  const LoadProductsByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class LoadProductDetails extends StoreEvent {
  final String productId;

  const LoadProductDetails(this.productId);

  @override
  List<Object?> get props => [productId];
}

class AddToCart extends StoreEvent {
  final Product product;
  const AddToCart(this.product);
}

class DecrementCartItem extends StoreEvent {
  final String productId;

  const DecrementCartItem(this.productId);
}

class IncrementCartItem extends StoreEvent {
  final String productId;

  const IncrementCartItem(this.productId);
}

class RemoveFromCart extends StoreEvent {
  final String productId;
  const RemoveFromCart(this.productId);
}

class LoadCart extends StoreEvent {}

class ClearCart extends StoreEvent {}

class SaveOrder extends StoreEvent {
  final List<String> productsIds;
  final double totalAmount;
  final String shippingAddress;
  final String userId;
  final String userPhone;

  const SaveOrder({
    required this.productsIds,
    required this.totalAmount,
    required this.shippingAddress,
    required this.userId,
    required this.userPhone,
  });

  @override
  List<Object?> get props => [
    productsIds,
    totalAmount,
    shippingAddress,
    userId,
    userPhone,
  ];
}
