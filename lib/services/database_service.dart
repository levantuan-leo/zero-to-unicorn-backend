import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import 'package:flutter_ecommerce_backend/models/models.dart';

class DatabaseService {
  final cf.FirebaseFirestore _firebaseFirestore = cf.FirebaseFirestore.instance;

  Stream<List<Order>> getOrders() {
    return _firebaseFirestore.collection('orders').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Order.fromSnapshot(doc)).toList();
    });
  }

  Stream<List<Order>> getPendingOrders() {
    return _firebaseFirestore
        .collection('orders')
        .where('isCancelled', isEqualTo: false)
        .where('isDelivered', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Order.fromSnapshot(doc)).toList();
    });
  }

  Stream<List<Product>> getProducts() {
    return _firebaseFirestore
        .collection('products')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromSnapshot(doc)).toList();
    });
  }

  Future<List<OrderStats>> getOrderStats() {
    return _firebaseFirestore
        .collection('order_stats')
        .orderBy('dateTime')
        .get()
        .then((querySnapshot) => querySnapshot.docs
            .asMap()
            .entries
            .map((entry) => OrderStats.fromSnapshot(entry.value, entry.key))
            .toList());
  }

  Future<void> addProduct(Product product) {
    return _firebaseFirestore.collection('products').add(product.toMap());
  }

  Future<void> updateField(
    Product product,
    String field,
    dynamic newValue,
  ) async {
    return _firebaseFirestore
        .collection('products')
        .doc(product.id)
        .update({field: newValue});
  }

  Future<void> updateOrder(
    Order order,
    String field,
    dynamic newValue,
  ) {
    return _firebaseFirestore
        .collection('orders')
        .doc(order.id.toString())
        .update({field: newValue});
  }
}
