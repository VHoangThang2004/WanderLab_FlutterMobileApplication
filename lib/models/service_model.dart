class ServiceModel {
  final int? id;
  final int destinationId;
  final String name;
  final String description;
  final double price;
  final String category;

  ServiceModel({
    this.id,
    required this.destinationId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'],
      destinationId: map['destinationId'],
      name: map['name'],
      description: map['description'],
      price: (map['price'] as num).toDouble(),
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'destinationId': destinationId,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
    };
  }
}
