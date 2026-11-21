import 'package:micro_lending_app/features/auth/domain/entities/auth.dart';

/// JSON -> entity mapping for the auth APIs. Unchanged from the old
/// `fromJson` factories.

abstract final class OtpDto {
  static Otp fromJson(Map<String, dynamic> json) => Otp(
    success: json["success"] ?? false,
    message: json["message"] ?? "Unable to send OTP. Please try again",
  );
}

abstract final class ResetPasswordDto {
  static ResetPassword fromJson(Map<String, dynamic> json) => ResetPassword(
    success: json["success"] ?? false,
    message: json["message"] ?? "Unable to send OTP. Please try again",
  );
}

abstract final class RegisterDto {
  static Register fromJson(Map<String, dynamic> json) => Register(
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
