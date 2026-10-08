class Otp {
  final bool success;
  final String message;

  const Otp({required this.success, required this.message});

  factory Otp.fromjson(Map<String, dynamic> json) => Otp(
    success: json["success"] ?? false,
    message: json["message"] ?? "Unable to send OTP. Please try again",
  );
}

class ResetPassword {
  final bool success;
  final String message;

  const ResetPassword({required this.success, required this.message});

  factory ResetPassword.fromjson(Map<String, dynamic> json) => ResetPassword(
    success: json["success"] ?? false,
    message: json["message"] ?? "Unable to send OTP. Please try again",
  );
}

class Register {
  final String id;
  final String userName;
  final String phoneNumber;
  final String? email;
  final String role;
  final bool isVerified;
  final bool isActive;
  final double defaultUpfrontFeePercentage;
  final double defaultInterestPercentage;
  final double defaultTotalMonths;
  final double defaultTotalWeeks;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Register({
    required this.id,
    required this.userName,
    required this.phoneNumber,
    this.email,
    required this.role,
    required this.isVerified,
    required this.isActive,
    required this.defaultUpfrontFeePercentage,
    required this.defaultInterestPercentage,
    required this.defaultTotalMonths,
    required this.defaultTotalWeeks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Register.fromJson(Map<String, dynamic> json) => Register(
    id: json["id"] as String? ?? "",
    userName: json["user_name"] as String,
    phoneNumber: json["phone_number"] as String,
    role: json["role"],
    isVerified: json["is_verified"] as bool,
    isActive: json["is_active"] as bool,
    defaultUpfrontFeePercentage: (json["default_upfront_fee_percentage"] as num)
        .toDouble(),
    defaultInterestPercentage: (json["default_interest_percentage"] as num)
        .toDouble(),
    defaultTotalMonths: (json["default_total_months"] as num).toDouble(),
    defaultTotalWeeks: (json["default_total_weeks"] as num).toDouble(),
    createdAt: DateTime.parse(json["created_at"] as String),
    updatedAt: DateTime.parse(json["updated_at"]),
  );
}
