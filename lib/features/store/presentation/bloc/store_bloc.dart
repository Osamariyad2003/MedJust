import 'package:bloc/bloc.dart';
import 'package:med_just/core/models/store_model.dart';
import 'package:med_just/features/store/data/store_repo.dart';
import 'store_event.dart';
import 'store_state.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final StoreRepository _repository;

  // Local items list for cart management
  List<Product> items = [];

  StoreBloc({required StoreRepository repository})
    : _repository = repository,
      super(StoreInitial()) {
    on<LoadAllProducts>(_onLoadAllProducts);
    on<LoadProductsByCategory>(_onLoadProductsByCategory);
    on<LoadProductDetails>(_onLoadProductDetails);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<LoadCart>(_onLoadCart);
    on<ClearCart>(_onClearCart);
    on<SaveOrder>(_onSaveOrder);
  }

  Future<void> _onLoadAllProducts(
    LoadAllProducts event,
    Emitter<StoreState> emit,
  ) async {
    emit(StoreLoading());
    try {
      final products = await _repository.getAllProducts();
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(StoreError('Failed to load products: $e'));
    }
  }

  Future<void> _onLoadProductsByCategory(
    LoadProductsByCategory event,
    Emitter<StoreState> emit,
  ) async {
    emit(StoreLoading());
    try {
      final products = await _repository.getProductsByCategory(
        event.categoryId,
      );
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(StoreError('Failed to load products for this category: $e'));
    }
  }

  Future<void> _onLoadProductDetails(
    LoadProductDetails event,
    Emitter<StoreState> emit,
  ) async {
    emit(StoreLoading());
    try {
      final product = await _repository.getProductById(event.productId);
      if (product != null) {
        emit(ProductDetailsLoaded(product));
      } else {
        emit(const StoreError('Product not found'));
      }
    } catch (e) {
      emit(StoreError('Failed to load product details: $e'));
    }
  }

  Future<void> _onAddToCart(AddToCart event, Emitter<StoreState> emit) async {
    // Add to local items list
    final index = items.indexWhere((p) => p.id == event.product.id);
    if (index == -1) {
      items.add(event.product.copyWith(quantity: 1));
    } else {
      final current = items[index];
      items[index] = current.copyWith(quantity: (current.quantity ?? 1) + 1);
      print("Cart Items: ${items.length}");
    }
    emit(CartLoaded(List<Product>.from(items)));
    print("Cart Items: ${items.length}");
    await _repository.addToCart(event.product);
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCart event,
    Emitter<StoreState> emit,
  ) async {
    // Remove from local items list
    items.removeWhere((p) => p.id == event.productId);
    emit(CartLoaded(List<Product>.from(items)));
    // Optionally, also update repository if you want persistence
    await _repository.removeFromCart(event.productId);
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<StoreState> emit) async {
    // Load from repository for persistence
    final cartItems = await _repository.getCartItems();
    items = List<Product>.from(cartItems);
    emit(CartLoaded(items));
  }

  Future<void> _onClearCart(ClearCart event, Emitter<StoreState> emit) async {
    items.clear();
    emit(CartLoaded([]));
    await _repository.clearCart();
  }

  Future<void> _onSaveOrder(SaveOrder event, Emitter<StoreState> emit) async {
    emit(StoreLoading());
    try {
      await _repository.saveToFirebaseOrder(
        productsIds: event.productsIds,
        totalAmount: event.totalAmount,
        shippingAddress: event.shippingAddress,
        userId: event.userId,
        userPhone: event.userPhone,
      );
      emit(OrderSaved());
    } catch (e) {
      emit(OrderSaveError(e.toString()));
    }
  }
}
