class SalonSummary {
  final int id;
  final String name;
  final double rating;
  final String? address;
  final String? mainImage;
  final double? startingPrice;
  final double distance;
  final bool isOpen;
  final List<String> categories;

  SalonSummary({
    required this.id,
    required this.name,
    required this.rating,
    this.address,
    this.mainImage,
    this.startingPrice,
    required this.distance,
    required this.isOpen,
    this.categories = const [],
  });

  factory SalonSummary.fromJson(Map<String, dynamic> json) {
    return SalonSummary(
      id: json['id'],
      name: json['name'],
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      address: json['address'],
      mainImage: json['main_image'],
      startingPrice: json['starting_price'] != null ? double.tryParse(json['starting_price'].toString()) : null,
      distance: double.tryParse(json['distance']?.toString() ?? '0') ?? 0.0,
      isOpen: json['is_open'] ?? false,
      categories: List<String>.from(json['categories'] ?? []),
    );
  }
}

class SalonDetail extends SalonSummary {
  final String? description;
  final String? phone;
  final List<String> images;
  final List<SalonService> services;
  final List<StaffMember> staff;
  final double latitude;
  final double longitude;

  SalonDetail({
    required super.id,
    required super.name,
    required super.rating,
    super.address,
    super.mainImage,
    super.startingPrice,
    required super.distance,
    required super.isOpen,
    this.description,
    this.phone,
    required this.images,
    required this.services,
    required this.staff,
    required this.latitude,
    required this.longitude,
  });

  factory SalonDetail.fromJson(Map<String, dynamic> json) {
    return SalonDetail(
      id: json['id'],
      name: json['name'],
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      address: json['address'],
      mainImage: json['main_image'], // Note: getSalonById currently doesn't return main_image separately, but it's in images
      startingPrice: null, // min price logic can be calculated client side or added to detail endpoint
      distance: 0.0, // detail doesn't include distance unless we pass coords
      isOpen: true, // placeholder
      description: json['description'],
      phone: json['phone'],
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      images: List<String>.from(json['images'] ?? []),
      services: (json['services'] as List? ?? []).map((e) => SalonService.fromJson(e)).toList(),
      staff: (json['staff'] as List? ?? []).map((e) => StaffMember.fromJson(e)).toList(),
    );
  }
}

class SalonService {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int durationMinutes;
  final String? category;

  SalonService({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.durationMinutes,
    this.category,
  });

  factory SalonService.fromJson(Map<String, dynamic> json) {
    return SalonService(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      durationMinutes: json['duration_minutes'] ?? 30,
      category: json['category'],
    );
  }
}

class StaffMember {
  final int id;
  final String name;
  final String? profileImage;

  StaffMember({required this.id, required this.name, this.profileImage});

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'],
      name: json['name'],
      profileImage: json['profile_image'],
    );
  }
}
