class Listing {
  final String id;
  final String hostId;
  final Map<String, dynamic>? host;  // Full host object data
  final LocalizedText title;
  final LocalizedText description;
  final String propertyType;
  final Location location;
  final Pricing pricing;
  final Capacity capacity;
  final List<String> amenities;
  final List<ListingImage> images;
  final Rating rating;
  final String status;
  final int views;
  final bool featured;
  
  Listing({
    required this.id,
    required this.hostId,
    this.host,
    required this.title,
    required this.description,
    required this.propertyType,
    required this.location,
    required this.pricing,
    required this.capacity,
    required this.amenities,
    required this.images,
    required this.rating,
    required this.status,
    required this.views,
    required this.featured,
  });
  
  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['_id'] ?? json['id'],
      hostId: json['hostId'] is String ? json['hostId'] : (json['hostId']?['_id'] ?? ''),
      host: json['hostId'] is Map<String, dynamic> ? Map<String, dynamic>.from(json['hostId']) : null,
      title: LocalizedText.fromJson(json['title']),
      description: LocalizedText.fromJson(json['description']),
      propertyType: json['propertyType'],
      location: Location.fromJson(json['location']),
      pricing: Pricing.fromJson(json['pricing']),
      capacity: Capacity.fromJson(json['capacity']),
      amenities: List<String>.from(json['amenities'] ?? []),
      images: (json['images'] as List)
          .map((img) => ListingImage.fromJson(img))
          .toList(),
      rating: Rating.fromJson(json['rating']),
      status: json['status'],
      views: json['views'] ?? 0,
      featured: json['featured'] ?? false,
    );
  }
  
  String get mainImage => images.isNotEmpty ? images.first.url : '';
}

class LocalizedText {
  final String en;
  final String sw;
  
  LocalizedText({required this.en, required this.sw});
  
  factory LocalizedText.fromJson(Map<String, dynamic> json) {
    return LocalizedText(
      en: json['en'] ?? '',
      sw: json['sw'] ?? '',
    );
  }
  
  String get(String locale) => locale == 'sw' ? sw : en;
}

class Location {
  final String address;
  final String region;
  final String city;
  final double latitude;
  final double longitude;
  
  Location({
    required this.address,
    required this.region,
    required this.city,
    required this.latitude,
    required this.longitude,
  });
  
  factory Location.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates']['coordinates'] as List;
    return Location(
      address: json['address'],
      region: json['region'],
      city: json['city'],
      longitude: coords[0].toDouble(),
      latitude: coords[1].toDouble(),
    );
  }
}

class Pricing {
  final double basePrice;
  final String currency;
  final double cleaningFee;
  final double serviceFee;
  
  Pricing({
    required this.basePrice,
    required this.currency,
    required this.cleaningFee,
    required this.serviceFee,
  });
  
  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'TZS',
      cleaningFee: (json['cleaningFee'] ?? 0).toDouble(),
      serviceFee: (json['serviceFee'] ?? 0).toDouble(),
    );
  }
}

class Capacity {
  final int guests;
  final int bedrooms;
  final int beds;
  final int bathrooms;
  
  Capacity({
    required this.guests,
    required this.bedrooms,
    required this.beds,
    required this.bathrooms,
  });
  
  factory Capacity.fromJson(Map<String, dynamic> json) {
    return Capacity(
      guests: json['guests'] ?? 0,
      bedrooms: json['bedrooms'] ?? 0,
      beds: json['beds'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
    );
  }
}

class ListingImage {
  final String url;
  final String? caption;
  final int order;
  
  ListingImage({
    required this.url,
    this.caption,
    required this.order,
  });
  
  factory ListingImage.fromJson(Map<String, dynamic> json) {
    return ListingImage(
      url: json['url'],
      caption: json['caption'],
      order: json['order'] ?? 0,
    );
  }
}

class Rating {
  final double average;
  final int count;
  final RatingBreakdown breakdown;
  
  Rating({
    required this.average, 
    required this.count,
    required this.breakdown,
  });
  
  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      average: (json['average'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
      breakdown: json['breakdown'] != null 
          ? RatingBreakdown.fromJson(json['breakdown'])
          : RatingBreakdown(
              cleanliness: 0,
              accuracy: 0,
              communication: 0,
              location: 0,
              checkIn: 0,
              value: 0,
            ),
    );
  }
}

class RatingBreakdown {
  final double cleanliness;
  final double accuracy;
  final double communication;
  final double location;
  final double checkIn;
  final double value;
  
  RatingBreakdown({
    required this.cleanliness,
    required this.accuracy,
    required this.communication,
    required this.location,
    required this.checkIn,
    required this.value,
  });
  
  factory RatingBreakdown.fromJson(Map<String, dynamic> json) {
    return RatingBreakdown(
      cleanliness: (json['cleanliness'] ?? 0).toDouble(),
      accuracy: (json['accuracy'] ?? 0).toDouble(),
      communication: (json['communication'] ?? 0).toDouble(),
      location: (json['location'] ?? 0).toDouble(),
      checkIn: (json['checkIn'] ?? 0).toDouble(),
      value: (json['value'] ?? 0).toDouble(),
    );
  }
}





