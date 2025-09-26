import 'cart_item.dart';
import 'product.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
}

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final OrderStatus status;
  final String shippingAddress;
  final String billingAddress;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? trackingNumber;
  final String? notes;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.billingAddress,
    required this.paymentMethod,
    required this.createdAt,
    this.updatedAt,
    this.trackingNumber,
    this.notes,
  });

  factory Order.fromMap(Map<String, dynamic> data, String id) {
    return Order(
      id: id,
      userId: data['userId'] ?? '',
      items:
          (data['items'] as List<dynamic>?)
              ?.map(
                (item) => CartItem(
                  id: item['id'] ?? '',
                  product: Product.fromMap(
                    item['product'],
                    item['product']['id'] ?? '',
                  ),
                  quantity: item['quantity'] ?? 0,
                  addedAt: item['addedAt'] is int
                      ? DateTime.fromMillisecondsSinceEpoch(item['addedAt'])
                      : item['addedAt']?.toDate() ?? DateTime.now(),
                ),
              )
              .toList() ??
          [],
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${data['status']}',
        orElse: () => OrderStatus.pending,
      ),
      shippingAddress: data['shippingAddress'] ?? '',
      billingAddress: data['billingAddress'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
      createdAt: data['createdAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] is int
                ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'])
                : data['updatedAt']?.toDate())
          : null,
      trackingNumber: data['trackingNumber'],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items
          .map(
            (item) => {
              'id': item.id,
              'product': item.product.toMap(),
              'quantity': item.quantity,
              'addedAt': item.addedAt.millisecondsSinceEpoch,
            },
          )
          .toList(),
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'shippingAddress': shippingAddress,
      'billingAddress': billingAddress,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'trackingNumber': trackingNumber,
      'notes': notes,
    };
  }

  Order copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    double? totalAmount,
    OrderStatus? status,
    String? shippingAddress,
    String? billingAddress,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? trackingNumber,
    String? notes,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'Order{id: $id, userId: $userId, totalAmount: $totalAmount, status: $status}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
