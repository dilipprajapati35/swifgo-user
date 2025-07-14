import 'package:flutter/material.dart';
import 'package:flutter_arch/screens/ride/model/rideModel.dart';
import 'package:flutter_arch/services/dio_http.dart';

class RideProvider extends ChangeNotifier {
  Map<String, List<RideModel>>  _rides = {
    'upcoming': [],
    'completed': [],
    'cancelled': [],
  };
  Map<String, bool> _loading = {
    'upcoming': false,
    'completed': false,
    'cancelled': false,
  };
  Map<String, String?> _error = {
    'upcoming': null,
    'completed': null,
    'cancelled': null,
  };

  List<RideModel> getUpcomingRides() => _rides['upcoming']!;
  List<RideModel> getCompletedRides() => _rides['completed']!;
  List<RideModel> getCancelledRides() => _rides['cancelled']!;

  bool isLoading(String status) => _loading[status] ?? false;
  String? getError(String status) => _error[status];

  Future<void> fetchRides(BuildContext context, String status) async {
    _loading[status] = true;
    _error[status] = null;
    notifyListeners();
    try {
      final rides = await DioHttp().getMyRides(context, status);
      _rides[status] = rides;
    } catch (e) {
      _error[status] = 'Failed to load rides';
      _rides[status] = [];
    }
    _loading[status] = false;
    notifyListeners();
  }
} 