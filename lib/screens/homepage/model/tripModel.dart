class TripModel {
  final String scheduledTripId;
  final String routeName;
  final String pickupStopId;
  final String destinationStopId;
  final String pickupLocationName;
  final String destinationLocationName;
  final DateTime departureDateTime;
  final DateTime estimatedArrivalDateTime;
  final int price;
  final String currency;
  final int availableSeats;
  final VehicleInfo vehicleInfo;
  final String durationText;

  TripModel({
    required this.scheduledTripId,
    required this.routeName,
    required this.pickupStopId,
    required this.destinationStopId,
    required this.pickupLocationName,
    required this.destinationLocationName,
    required this.departureDateTime,
    required this.estimatedArrivalDateTime,
    required this.price,
    required this.currency,
    required this.availableSeats,
    required this.vehicleInfo,
    required this.durationText,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      scheduledTripId: json['scheduledTripId'] ?? '',
      routeName: json['routeName'] ?? '',
      pickupStopId: json['pickupStopId'] ?? '',
      destinationStopId: json['destinationStopId'] ?? '',
      pickupLocationName: json['pickupLocationName'] ?? '',
      destinationLocationName: json['destinationLocationName'] ?? '',
      departureDateTime: DateTime.parse(json['departureDateTime']),
      estimatedArrivalDateTime: DateTime.parse(json['estimatedArrivalDateTime']),
      price: json['price'] ?? 0,
      currency: json['currency'] ?? 'INR',
      availableSeats: json['availableSeats'] ?? 0,
      vehicleInfo: VehicleInfo.fromJson(json['vehicleInfo'] ?? {}),
      durationText: json['durationText'] ?? '',
    );
  }
}

class VehicleInfo {
  final String type;
  final String model;
  final String registration;

  VehicleInfo({
    required this.type,
    required this.model,
    required this.registration,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      type: json['type'] ?? '',
      model: json['model'] ?? '',
      registration: json['registrationNumber'] ?? '',
    );
  }
} 