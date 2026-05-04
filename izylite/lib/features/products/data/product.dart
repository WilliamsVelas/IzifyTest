class ProductUnit {
  final String id;
  final String barcode;

  ProductUnit({required this.id, required this.barcode});

  factory ProductUnit.fromJson(Map<String, dynamic> json) {
    return ProductUnit(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      barcode: json['barcode']?.toString() ?? '',
    );
  }
}

class Product {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String? description;
  final List<ProductUnit> units;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.description,
    required this.units,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final List<dynamic> unitsRaw = json['availableUnits'] ?? [];

    return Product(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Sin nombre',
      price: (json['price'] as num? ?? 0).toDouble(),
      description: json['description'],
      stock: (json['stock'] as num? ?? 0).toInt(),
      units: unitsRaw.map((u) => ProductUnit.fromJson(u)).toList(),
    );
  }
}