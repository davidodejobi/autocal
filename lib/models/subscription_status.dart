// Subscription status model for Pro features
class SubscriptionStatus {
  final bool isPro;
  final DateTime? expiryDate;
  final String? productId;
  final bool isActive;

  const SubscriptionStatus({
    required this.isPro,
    this.expiryDate,
    this.productId,
    required this.isActive,
  });

  SubscriptionStatus copyWith({
    bool? isPro,
    DateTime? expiryDate,
    String? productId,
    bool? isActive,
  }) {
    return SubscriptionStatus(
      isPro: isPro ?? this.isPro,
      expiryDate: expiryDate ?? this.expiryDate,
      productId: productId ?? this.productId,
      isActive: isActive ?? this.isActive,
    );
  }
}