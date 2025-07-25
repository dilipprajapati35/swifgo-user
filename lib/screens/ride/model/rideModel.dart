class RideModel {
  final String bookingId;
  final String crn;
  final String vehicleDescription;
  final String date;
  final String time;
  final String fare;
  final String paymentMethodDisplay;
  final String pickupLocation;
  final String destinationLocation;
  final String status;
  final String statusDisplay;
  final bool canTrack; // New field to determine if live tracking is available
  final List<Map<String, dynamic>> stops; // New field for stops

  RideModel({
    required this.bookingId,
    required this.crn,
    required this.vehicleDescription,
    required this.date,
    required this.time,
    required this.fare,
    required this.paymentMethodDisplay,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.status,
    required this.statusDisplay,
    this.canTrack = false, // Default to false
    this.stops = const [], // Default to empty list
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> stopsList = [];
    if (json['stops'] != null && json['stops'] is List) {
      stopsList = List<Map<String, dynamic>>.from(
        (json['stops'] as List).map((e) => Map<String, dynamic>.from(e)),
      );
    }
    return RideModel(
      bookingId: json['bookingId'] ?? '',
      crn: json['crn'] ?? '',
      vehicleDescription: json['vehicleDescription'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      fare: json['fare'] ?? '',
      paymentMethodDisplay: json['paymentMethodDisplay'] ?? '',
      pickupLocation: json['pickupLocation'] ?? '',
      destinationLocation: json['destinationLocation'] ?? '',
      status: json['status'] ?? '',
      statusDisplay: json['statusDisplay'] ?? '',
      canTrack: json['canTrack'] ?? false, // Parse canTrack from API
      stops: stopsList,
    );
  }
}
