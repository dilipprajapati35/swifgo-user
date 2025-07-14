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
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
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
    );
  }
}
