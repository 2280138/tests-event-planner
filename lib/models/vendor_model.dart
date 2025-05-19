import 'package:cloud_firestore/cloud_firestore.dart';

class VendorModel {
  final String id;
  final String userId;
  final String businessName;
  final String contactPhone;
  final String category;
  final double price;
  final int quantity;
  final String description;
  final String city;
  final String address;
  final String? email;
  final String? contactName;
  final String? venueName;
  final String? foodType;
  final String? decorType;
  final String? venueType;
  final DateTime timestamp;
  final String imageUrl;

  VendorModel({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.contactPhone,
    required this.category,
    required this.price,
    required this.quantity,
    required this.description,
    required this.city,
    required this.address,
    this.email,
    this.contactName,
    this.venueName,
    this.foodType,
    this.decorType,
    this.venueType,
    required this.timestamp,
    required this.imageUrl,
  });

  /// ✅ Updated to accept Firestore doc ID separately
  factory VendorModel.fromMap(Map<String, dynamic> data, String docId) {
    return VendorModel(
      id: docId, // Use Firestore document ID
      userId: data['user_id'] ?? '',
      businessName: data['business_name'] ?? '',
      contactPhone: data['contact_phone'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      quantity: (data['quantity'] ?? 0).toInt(),
      description: data['description'] ?? '',
      city: data['city'] ?? '',
      address: data['address'] ?? '',
      email: data['email'],
      contactName: data['contact_name'],
      venueName: data['venue_name'],
      foodType: data['food_type'],
      decorType: data['decor_type'],
      venueType: data['venue_type'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      imageUrl: data['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'business_name': businessName,
      'contact_phone': contactPhone,
      'category': category,
      'price': price,
      'quantity': quantity,
      'description': description,
      'city': city,
      'address': address,
      'email': email,
      'contact_name': contactName,
      'venue_name': venueName,
      'food_type': foodType,
      'decor_type': decorType,
      'venue_type': venueType,
      'timestamp': timestamp,
      'image_url': imageUrl,
    };
  }

  VendorModel copyWith({
    String? id,
    String? userId,
    String? businessName,
    String? contactPhone,
    String? category,
    double? price,
    int? quantity,
    String? description,
    String? city,
    String? address,
    String? email,
    String? contactName,
    String? venueName,
    String? foodType,
    String? decorType,
    String? venueType,
    DateTime? timestamp,
    String? imageUrl,
  }) {
    return VendorModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      contactPhone: contactPhone ?? this.contactPhone,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      city: city ?? this.city,
      address: address ?? this.address,
      email: email ?? this.email,
      contactName: contactName ?? this.contactName,
      venueName: venueName ?? this.venueName,
      foodType: foodType ?? this.foodType,
      decorType: decorType ?? this.decorType,
      venueType: venueType ?? this.venueType,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
