class Otp {
  final bool success;
  final String message;

  const Otp({required this.success, required this.message});

  factory Otp.fromjson(Map<String, dynamic> json) => Otp(
    success: json["success"] ?? false,
    message: json["message"] ?? "Unable to send OTP. Please try again",
  );
}
