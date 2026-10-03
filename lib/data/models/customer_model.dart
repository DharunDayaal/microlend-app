class Customer {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String preferredPaymentDay;

  const Customer({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.preferredPaymentDay,
    this.email,
  });

  factory Customer.fromJson(Map<String, dynamic> j) {
    return Customer(
      id: j['id'] as String? ?? '',
      name: j['customer_name'] as String? ?? '',
      phoneNumber: j['phone_number'] as String? ?? '',
      preferredPaymentDay: j['preferred_payment_day'] as String? ?? '',
      email: j['email'] as String?,
    );
  }
}
