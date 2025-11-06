import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:med_just/core/models/store_model.dart';

abstract class StoreDataSource {
  Future<List<Product>> getAllProducts();
  Future<List<Product>> getProductsByCategory(String categoryId);
  Future<Product?> getProductById(String productId);

  // Cart functions
  Future<void> addToCart(Product product);
  Future<void> removeFromCart(String productId);
  Future<List<Product>> getCartItems();
  Future<void> clearCart();
  Future<void> saveToFirebaseOrder({
    required List<String> productsIds,
    required double totalAmount,
    required String shippingAddress,
    required String userId,
    required String userPhone,
  });
}

class StoreFirestoreDataSource implements StoreDataSource {
  final FirebaseFirestore _firestore;
  List<Product> _cart = [];

  StoreFirestoreDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Product>> getAllProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Product.fromJson({'id': doc.id, ...data});
      }).toList();
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      final snapshot =
          await _firestore
              .collection('products')
              .where('categoryId', isEqualTo: categoryId)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Product.fromJson({'id': doc.id, ...data});
      }).toList();
    } catch (e) {
      print('Error fetching products by category: $e');
      return [];
    }
  }

  @override
  Future<Product?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      return Product.fromJson({'id': doc.id, ...data});
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  Future<void> saveToFirebaseOrder({
    required List<String> productsIds,
    required double totalAmount,
    required String shippingAddress,
    required String userId,
    required String userPhone,
  }) async {
    try {
      await _firestore.collection('orders').add({
        'orderDate': DateTime.now(),
        'productsIds': productsIds,
        'totalAmount': totalAmount,
        'shippingaddress': shippingAddress,
        'userId': userId,
        'userPhone': userPhone,
      });
    } catch (e) {
      print('Error saving order: $e');
      rethrow;
    }
  }

  @override
  Future<void> addToCart(Product product) async {
    _cart.add(product);
  }

  @override
  Future<void> removeFromCart(String productId) async {
    _cart.removeWhere((p) => p.id == productId);
  }

  @override
  Future<List<Product>> getCartItems() async {
    return _cart;
  }

  @override
  Future<void> clearCart() async {
    _cart.clear();
  }
}
