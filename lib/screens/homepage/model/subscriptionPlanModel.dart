class SubscriptionPlanModel {
  final String id;
  final String name;
  final String description;
  final String price;
  final String currency;
  final int durationValue;
  final String durationUnit;
  final int ridesIncluded;
  final int trialDays;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.durationValue,
    required this.durationUnit,
    required this.ridesIncluded,
    required this.trialDays,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      currency: json['currency'],
      durationValue: json['durationValue'],
      durationUnit: json['durationUnit'],
      ridesIncluded: json['ridesIncluded'],
      trialDays: json['trialDays'],
      isActive: json['isActive'],
      sortOrder: json['sortOrder'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
} 