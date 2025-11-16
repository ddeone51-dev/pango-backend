class Review {
  final String id;
  final String bookingId;
  final String listingId;
  final ReviewAuthor author;
  final String revieweeId;
  final String reviewType;
  final ReviewRatings ratings;
  final ReviewComment? comment;
  final ReviewResponse? response;
  final List<String> photos;
  final String status;
  final HelpfulInfo helpful;
  final DateTime createdAt;
  final DateTime updatedAt;

  Review({
    required this.id,
    required this.bookingId,
    required this.listingId,
    required this.author,
    required this.revieweeId,
    required this.reviewType,
    required this.ratings,
    this.comment,
    this.response,
    required this.photos,
    required this.status,
    required this.helpful,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? json['id'],
      bookingId: json['bookingId'] is String 
          ? json['bookingId'] 
          : json['bookingId']?['_id'] ?? '',
      listingId: json['listingId'] is String 
          ? json['listingId'] 
          : json['listingId']?['_id'] ?? '',
      author: json['authorId'] is String
          ? ReviewAuthor(
              id: json['authorId'],
              firstName: '',
              lastName: '',
              profilePicture: null,
            )
          : ReviewAuthor.fromJson(json['authorId']),
      revieweeId: json['revieweeId'] is String 
          ? json['revieweeId'] 
          : json['revieweeId']?['_id'] ?? '',
      reviewType: json['reviewType'] ?? 'guest_to_host',
      ratings: ReviewRatings.fromJson(json['ratings']),
      comment: json['comment'] != null 
          ? ReviewComment.fromJson(json['comment']) 
          : null,
      response: json['response'] != null 
          ? ReviewResponse.fromJson(json['response']) 
          : null,
      photos: json['photos'] != null 
          ? List<String>.from(json['photos']) 
          : [],
      status: json['status'] ?? 'published',
      helpful: json['helpful'] != null 
          ? HelpfulInfo.fromJson(json['helpful']) 
          : HelpfulInfo(count: 0, users: []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'ratings': ratings.toJson(),
      'comment': comment?.toJson(),
      'photos': photos,
    };
  }
}

class ReviewAuthor {
  final String id;
  final String firstName;
  final String lastName;
  final String? profilePicture;

  ReviewAuthor({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
  });

  factory ReviewAuthor.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] ?? {};
    return ReviewAuthor(
      id: json['_id'] ?? json['id'],
      firstName: profile['firstName'] ?? '',
      lastName: profile['lastName'] ?? '',
      profilePicture: profile['profilePicture'],
    );
  }

  String get fullName => '$firstName $lastName';
}

class ReviewRatings {
  final double overall;
  final double? cleanliness;
  final double? accuracy;
  final double? communication;
  final double? location;
  final double? checkIn;
  final double? value;

  ReviewRatings({
    required this.overall,
    this.cleanliness,
    this.accuracy,
    this.communication,
    this.location,
    this.checkIn,
    this.value,
  });

  factory ReviewRatings.fromJson(Map<String, dynamic> json) {
    return ReviewRatings(
      overall: (json['overall'] ?? 0).toDouble(),
      cleanliness: json['cleanliness']?.toDouble(),
      accuracy: json['accuracy']?.toDouble(),
      communication: json['communication']?.toDouble(),
      location: json['location']?.toDouble(),
      checkIn: json['checkIn']?.toDouble(),
      value: json['value']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'overall': overall,
    };
    
    if (cleanliness != null) map['cleanliness'] = cleanliness;
    if (accuracy != null) map['accuracy'] = accuracy;
    if (communication != null) map['communication'] = communication;
    if (location != null) map['location'] = location;
    if (checkIn != null) map['checkIn'] = checkIn;
    if (value != null) map['value'] = value;
    
    return map;
  }

  double get averageDetailed {
    final ratings = [
      cleanliness,
      accuracy,
      communication,
      location,
      checkIn,
      value,
    ].where((r) => r != null).toList();
    
    if (ratings.isEmpty) return overall;
    
    final sum = ratings.fold<double>(0, (sum, rating) => sum + rating!);
    return sum / ratings.length;
  }
}

class ReviewComment {
  final String? en;
  final String? sw;

  ReviewComment({
    this.en,
    this.sw,
  });

  factory ReviewComment.fromJson(Map<String, dynamic> json) {
    return ReviewComment(
      en: json['en'],
      sw: json['sw'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
      'sw': sw,
    };
  }

  String getLocalized(String languageCode) {
    if (languageCode == 'sw' && sw != null && sw!.isNotEmpty) {
      return sw!;
    }
    return en ?? sw ?? '';
  }
}

class ReviewResponse {
  final String text;
  final DateTime respondedAt;

  ReviewResponse({
    required this.text,
    required this.respondedAt,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      text: json['text'] ?? '',
      respondedAt: DateTime.parse(json['respondedAt']),
    );
  }
}

class HelpfulInfo {
  final int count;
  final List<String> users;

  HelpfulInfo({
    required this.count,
    required this.users,
  });

  factory HelpfulInfo.fromJson(Map<String, dynamic> json) {
    return HelpfulInfo(
      count: json['count'] ?? 0,
      users: json['users'] != null 
          ? List<String>.from(json['users']) 
          : [],
    );
  }
}

// Separate model for creating a review
class CreateReviewData {
  final String bookingId;
  final ReviewRatings ratings;
  final ReviewComment comment;
  final List<String> photos;

  CreateReviewData({
    required this.bookingId,
    required this.ratings,
    required this.comment,
    this.photos = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'ratings': ratings.toJson(),
      'comment': comment.toJson(),
      'photos': photos,
    };
  }
}






