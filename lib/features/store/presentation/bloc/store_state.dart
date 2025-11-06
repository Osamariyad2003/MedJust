import 'package:equatable/equatable.dart';
import 'package:med_just/core/models/store_model.dart';

abstract class StoreState extends Equatable {
  const StoreState();

  @override
  List<Object?> get props => [];
}

// Initial and loading states
class StoreInitial extends StoreState {}

class StoreLoading extends StoreState {}

// Product list loaded
class ProductsLoaded extends StoreState {
  final List<Product> products;
  const ProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

// Single product details loaded
class ProductDetailsLoaded extends StoreState {
  final Product product;
  const ProductDetailsLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

// Error state
class StoreError extends StoreState {
  final String message;
  const StoreError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cart loaded
class CartLoaded extends StoreState {
  final List<Product> cartItems;
  const CartLoaded(this.cartItems);

  @override
  List<Object?> get props => [cartItems];
}

// Cart updated (optional, for showing a message)
class CartUpdated extends StoreState {
  final List<Product> cartItems;
  final String? message;
  const CartUpdated(this.cartItems, {this.message});

  @override
  List<Object?> get props => [cartItems, message];
}

// Order placed successfully
class OrderSaved extends StoreState {}

// Order save error
class OrderSaveError extends StoreState {
  final String message;
  const OrderSaveError(this.message);

  @override
  List<Object?> get props => [message];
}
