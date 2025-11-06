import 'package:med_just/core/models/store_model.dart';
import 'store_data_source.dart';

class StoreRepository {
  final StoreDataSource _dataSource;

  StoreRepository({StoreDataSource? dataSource})
    : _dataSource = dataSource ?? StoreFirestoreDataSource();

  Future<List<Product>> getAllProducts() async {
    try {
      return await _dataSource.getAllProducts();
    } catch (e) {
      print('Repository error getting all products: $e');
      return [];
    }
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      return await _dataSource.getProductsByCategory(categoryId);
    } catch (e) {
      print('Repository error getting products by category: $e');
      return [];
    }
  }

  Future<Product?> getProductById(String productId) async {
    try {
      return await _dataSource.getProductById(productId);
    } catch (e) {
      print('Repository error getting product by id: $e');
      return null;
    }
  }

  // Cart functions
  Future<void> addToCart(Product product) => _dataSource.addToCart(product);
  Future<void> removeFromCart(String productId) =>
      _dataSource.removeFromCart(productId);
  Future<List<Product>> getCartItems() => _dataSource.getCartItems();
  Future<void> clearCart() => _dataSource.clearCart();

  Future<void> saveToFirebaseOrder({
    required List<String> productsIds,
    required double totalAmount,
    required String shippingAddress,
    required String userId,
    required String userPhone,
  }) async {
    await _dataSource.saveToFirebaseOrder(
      productsIds: productsIds,
      totalAmount: totalAmount,
      shippingAddress: shippingAddress,
      userId: userId,
      userPhone: userPhone,
    );
  }
}
