class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int stock;
  final bool isAvailable;
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock,
    this.isAvailable = true,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isFeatured = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromMap(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      stock: _parseStock(data['stock']),
      isAvailable: data['isAvailable'] ?? true,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      isFeatured: data['isFeatured'] ?? false,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
    );
  }

  static int _parseStock(dynamic stock) {
    print(
      '🔍 STOCK PARSING: Valeur reçue: $stock (type: ${stock.runtimeType})',
    );

    if (stock == null) {
      print('⚠️ STOCK PARSING: Stock est null, retour de 0');
      return 0;
    }

    try {
      if (stock is int) {
        print('✅ STOCK PARSING: Stock est un int: $stock');
        return stock;
      }
      if (stock is double) {
        print(
          '✅ STOCK PARSING: Stock est un double: $stock, conversion en int: ${stock.toInt()}',
        );
        return stock.toInt();
      }
      if (stock is String) {
        print(
          '✅ STOCK PARSING: Stock est une string: $stock, conversion en int: ${int.parse(stock)}',
        );
        return int.parse(stock);
      }
      print('❌ STOCK PARSING: Type non supporté: ${stock.runtimeType}');
    } catch (e) {
      print('❌ STOCK PARSING: Erreur lors du parsing du stock: $e');
    }

    print('⚠️ STOCK PARSING: Retour de 0 par défaut');
    return 0;
  }

  static DateTime _parseDateTime(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();

    try {
      // Si c'est un Timestamp Firestore
      if (timestamp.runtimeType.toString().contains('Timestamp')) {
        return timestamp.toDate();
      }
      // Si c'est déjà un DateTime
      if (timestamp is DateTime) {
        return timestamp;
      }
      // Si c'est une String ISO
      if (timestamp is String) {
        return DateTime.parse(timestamp);
      }
      // Si c'est un int (milliseconds depuis epoch)
      if (timestamp is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    } catch (e) {
      print('Erreur lors du parsing de la date: $e');
    }

    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'stock': stock,
      'isAvailable': isAvailable,
      'rating': rating,
      'reviewCount': reviewCount,
      'isFeatured': isFeatured,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    int? stock,
    bool? isAvailable,
    double? rating,
    int? reviewCount,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, price: $price, category: $category}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
