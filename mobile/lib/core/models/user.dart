class User {
  final String id;
  final String email;
  final String phoneNumber;
  final String role;
  final Profile profile;
  final Preferences preferences;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String accountStatus;
  final String hostStatus;
  final PayoutSettings? payoutSettings;
  
  User({
    required this.id,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.profile,
    required this.preferences,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.accountStatus,
    required this.hostStatus,
    this.payoutSettings,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
      profile: Profile.fromJson(json['profile']),
      preferences: Preferences.fromJson(json['preferences'] ?? {}),
      isEmailVerified: json['isEmailVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      accountStatus: json['accountStatus'] ?? 'active',
      hostStatus: json['hostStatus'] ?? 'not_requested',
      payoutSettings: json['payoutSettings'] != null
          ? PayoutSettings.fromJson(json['payoutSettings'])
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'profile': profile.toJson(),
      'preferences': preferences.toJson(),
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'accountStatus': accountStatus,
      'hostStatus': hostStatus,
      'payoutSettings': payoutSettings?.toJson(),
    };
  }
  
  String get fullName => '${profile.firstName} ${profile.lastName}';
  bool get hasPayoutSettings => payoutSettings?.isSetupComplete == true;
}

class Profile {
  final String firstName;
  final String lastName;
  final String? profilePicture;
  final String? bio;
  
  Profile({
    required this.firstName,
    required this.lastName,
    this.profilePicture,
    this.bio,
  });
  
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      firstName: json['firstName'],
      lastName: json['lastName'],
      profilePicture: json['profilePicture'],
      bio: json['bio'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'profilePicture': profilePicture,
      'bio': bio,
    };
  }
}

class Preferences {
  final String language;
  final String currency;
  
  Preferences({
    this.language = 'sw',
    this.currency = 'TZS',
  });
  
  factory Preferences.fromJson(Map<String, dynamic> json) {
    return Preferences(
      language: json['language'] ?? 'sw',
      currency: json['currency'] ?? 'TZS',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'currency': currency,
    };
  }
}

class PayoutSettings {
  final String? method;
  final BankAccount? bankAccount;
  final MobileMoney? mobileMoney;
  final String preferredCurrency;
  final bool isSetupComplete;
  final bool verified;
  final DateTime? lastUpdatedAt;
  final bool canUpdate;
  final double daysUntilNextUpdate;
  final DateTime? nextUpdateDate;

  PayoutSettings({
    required this.method,
    this.bankAccount,
    this.mobileMoney,
    this.preferredCurrency = 'TZS',
    this.isSetupComplete = false,
    this.verified = false,
    this.lastUpdatedAt,
    this.canUpdate = true,
    this.daysUntilNextUpdate = 0,
    this.nextUpdateDate,
  });

  factory PayoutSettings.fromJson(Map<String, dynamic> json) {
    return PayoutSettings(
      method: json['method'],
      bankAccount: json['bankAccount'] != null ? BankAccount.fromJson(json['bankAccount']) : null,
      mobileMoney: json['mobileMoney'] != null ? MobileMoney.fromJson(json['mobileMoney']) : null,
      preferredCurrency: json['preferredCurrency'] ?? 'TZS',
      isSetupComplete: json['isSetupComplete'] ?? false,
      verified: json['verified'] ?? false,
      lastUpdatedAt: json['lastUpdatedAt'] != null ? DateTime.parse(json['lastUpdatedAt']) : null,
      canUpdate: json['canUpdate'] ?? true,
      daysUntilNextUpdate: (json['daysUntilNextUpdate'] ?? 0).toDouble(),
      nextUpdateDate: json['nextUpdateDate'] != null ? DateTime.parse(json['nextUpdateDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'bankAccount': bankAccount?.toJson(),
      'mobileMoney': mobileMoney?.toJson(),
      'preferredCurrency': preferredCurrency,
      'isSetupComplete': isSetupComplete,
      'verified': verified,
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
    };
  }
}

class BankAccount {
  final String accountName;
  final String accountNumber;
  final String bankName;
  final String? branchName;
  final String? swiftCode;

  BankAccount({
    required this.accountName,
    required this.accountNumber,
    required this.bankName,
    this.branchName,
    this.swiftCode,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      accountName: json['accountName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      bankName: json['bankName'] ?? '',
      branchName: json['branchName'],
      swiftCode: json['swiftCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountName': accountName,
      'accountNumber': accountNumber,
      'bankName': bankName,
      'branchName': branchName,
      'swiftCode': swiftCode,
    };
  }
}

class MobileMoney {
  final String provider;
  final String phoneNumber;
  final String? accountName;

  MobileMoney({
    required this.provider,
    required this.phoneNumber,
    this.accountName,
  });

  factory MobileMoney.fromJson(Map<String, dynamic> json) {
    return MobileMoney(
      provider: json['provider'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      accountName: json['accountName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'phoneNumber': phoneNumber,
      'accountName': accountName,
    };
  }
}























