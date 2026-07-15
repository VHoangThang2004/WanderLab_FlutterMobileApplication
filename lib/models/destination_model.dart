class Destination {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final String location;
  final double rating;
  final double price;
  final double latitude;
  final double longitude;
  final String category;

  Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.rating,
    required this.price,
    required this.latitude,
    required this.longitude,
    required this.category,
  });

  factory Destination.fromMap(Map<String, dynamic> map) {
    return Destination(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      location: map['location'],
      rating: map['rating'],
      price: map['price'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
      'rating': rating,
      'price': price,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
    };
  }
}
