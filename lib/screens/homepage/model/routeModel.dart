class RouteModel {
  final String id;
  final String name;
  final String originAreaName;
  final String destinationAreaName;
  final String description;
  final bool isActive;
  final List<StopModel> stops;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? price; 

  RouteModel({
    required this.id,
    required this.name,
    required this.originAreaName,
    required this.destinationAreaName,
    required this.description,
    required this.isActive,
    required this.stops,
    required this.createdAt,
    required this.updatedAt,
    this.price, 
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'],
      name: json['name'],
      originAreaName: json['originAreaName'],
      destinationAreaName: json['destinationAreaName'],
      description: json['description'],
      isActive: json['isActive'],
      stops: (json['stops'] as List)
          .map((stop) => StopModel.fromJson(stop))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      price: json['price'] != null ? double.parse(json['price'].toString()) : null,
    );
  }
}

class StopModel {
  final String id;
  final String routeId;
  final String name;
  final String? addressDetails;
  final double latitude;
  final double longitude;
  final String type; 
  final int sequence;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  StopModel({
    required this.id,
    required this.routeId,
    required this.name,
    this.addressDetails,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.sequence,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StopModel.fromJson(Map<String, dynamic> json) {
    return StopModel(
      id: json['id'],
      routeId: json['routeId'],
      name: json['name'],
      addressDetails: json['addressDetails'],
      latitude: double.parse(json['latitude']),
      longitude: double.parse(json['longitude']),
      type: json['type'],
      sequence: json['sequence'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}