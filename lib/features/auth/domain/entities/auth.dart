/// Auth responses. Plain Dart: parsing lives in
/// `features/auth/data/dtos/auth_dto.dart`.
class Otp {
  final bool success;
  final String message;

  const Otp({required this.success, required this.message});
}

class ResetPassword {
  final bool success;
  final String message;

  const ResetPassword({required this.success, required this.message});
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
}
