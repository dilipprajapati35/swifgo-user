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
  final List<Map<String, dynamic>> stops;

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
    required this.stops,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }
    List<Map<String, dynamic>> stops = (json['stops'] as List?)?.map((e) {
      final stop = Map<String, dynamic>.from(e);
      if (stop.containsKey('sequence')) {
        stop['sequence'] = parseInt(stop['sequence']);
      }
      return stop;
    }).toList() ?? [];
    return TripModel(
      scheduledTripId: json['scheduledTripId'] ?? '',
      routeName: json['routeName'] ?? '',
      pickupStopId: json['pickupStopId'] ?? '',
      destinationStopId: json['destinationStopId'] ?? '',
      pickupLocationName: json['pickupLocationName'] ?? '',
      destinationLocationName: json['destinationLocationName'] ?? '',
      departureDateTime: DateTime.parse(json['departureDateTime']),
      estimatedArrivalDateTime: DateTime.parse(json['estimatedArrivalDateTime']),
      price: parseInt(json['price']),
      currency: json['currency'] ?? 'INR',
      availableSeats: parseInt(json['availableSeats']),
      vehicleInfo: VehicleInfo.fromJson(json['vehicleInfo'] ?? {}),
      durationText: json['durationText'] ?? '',
      stops: stops,
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