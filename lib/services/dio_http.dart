import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arch/constants/api_endpoints.dart';
import 'package:flutter_arch/interceptor/dio_interceptor.dart';
import 'package:flutter_arch/screens/homepage/model/routeModel.dart';
import 'package:flutter_arch/screens/homepage/model/subscriptionPlanModel.dart';
import 'package:flutter_arch/screens/homepage/model/tripModel.dart';
import 'package:flutter_arch/screens/ride/model/rideModel.dart';
import 'package:flutter_arch/services/api_error_handler.dart';
import 'package:flutter_arch/storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_arch/screens/profile/model/user_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DioHttp {
  final Dio _dio;
  final String _baseUrl;
  final MySecureStorage _secureStorage;

  DioHttp()
      : _dio = Dio()..interceptors.add(DioInterceptor()),
        _baseUrl = dotenv.env['BASE_URL'] ?? 'http://34.93.60.221:3001',
        _secureStorage = MySecureStorage();

  Future<Response> _postRequest({
    required BuildContext context,
    required ApiEndpoint endpoint,
    required dynamic data,
    bool wrapData = true,
    Function(String)? onSuccess,
  }) async {
    final url = '$_baseUrl${endpoint.fullPath}';
    try {
      final response = await _dio.post(
        url,
        data: data is FormData
            ? data
            : jsonEncode(wrapData ? {'data': data} : data),
      );

      if (onSuccess != null && response.data['data'] is String) {
        onSuccess(response.data['data']);
      }
      return response;
    } on DioException catch (err) {
      ApiErrorHandler.handleDioError(context, err);
      rethrow;
    } catch (err) {
      ApiErrorHandler.handleUnexpectedError(context, err);
      rethrow;
    }
  }

  Future<Response> _getRequest({
    required BuildContext context,
    required ApiEndpoint endpoint,
    Map<String, dynamic>? queryParameters,
    String? customPath, // Add this parameter
  }) async {
    final url = customPath != null
        ? '$_baseUrl$customPath'
        : '$_baseUrl${endpoint.fullPath}';
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (err) {
      ApiErrorHandler.handleDioError(context, err);
      rethrow;
    } catch (err) {
      ApiErrorHandler.handleUnexpectedError(context, err);
      rethrow;
    }
  }

  Future<Response> _putRequest({
    required BuildContext context,
    required ApiEndpoint endpoint,
    required dynamic data,
    String? resourceId,
    bool isFormData = false, // Add this parameter
  }) async {
    final path = resourceId != null
        ? '${endpoint.fullPath}/$resourceId'
        : endpoint.fullPath;
    final url = '$_baseUrl$path';
    try {
      final response = await _dio.put(
        url,
        data: isFormData ? data : jsonEncode(data),
      );
      return response;
    } on DioException catch (err) {
      ApiErrorHandler.handleDioError(context, err);
      rethrow;
    } catch (err) {
      ApiErrorHandler.handleUnexpectedError(context, err);
      rethrow;
    }
  }

  Future<Response> _deleteRequest({
    required BuildContext context,
    required ApiEndpoint endpoint,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? resourceId,
  }) async {
    final path = resourceId != null
        ? '${endpoint.fullPath}/$resourceId'
        : endpoint.fullPath;
    final url = '$_baseUrl$path';
    try {
      final response = await _dio.delete(
        url,
        data: data != null ? jsonEncode(data) : null,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (err) {
      ApiErrorHandler.handleDioError(context, err);
      rethrow;
    } catch (err) {
      ApiErrorHandler.handleUnexpectedError(context, err);
      rethrow;
    }
  }

  Future<Response> kycinitiate(
      BuildContext context, String aadhaarNumber) async {
    return await _postRequest(
      context: context,
      endpoint: ApiEndpoint.kycinitiate,
      data: {"aadhaarNumber": aadhaarNumber},
      wrapData: false,
    );
  }

  Future<Response> kycverifyotp(BuildContext context, String aadhaarNumber,
      String otp, String transactionId) async {
    return await _postRequest(
      context: context,
      endpoint: ApiEndpoint.kycverifyotp,
      data: {
        "aadhaarNumber": aadhaarNumber,
        "otp": otp,
        "transactionId": transactionId
      },
      wrapData: false,
    );
  }

  Future<Response> phoneRequestOtp(
      BuildContext context, String phoneNumber) async {
    return await _postRequest(
      context: context,
      endpoint: ApiEndpoint.phonerequestotp,
      data: {"phoneNumber": phoneNumber},
      wrapData: false,
    );
  }

  Future<Response> fcmToken(BuildContext context) async {
    final fcmToken = await _secureStorage.readFcmToken();
    return await _postRequest(
      context: context,
      endpoint: ApiEndpoint.fcmToken,
      data: {"fcmToken": fcmToken},
      wrapData: false,
    );
  }

  Future<Response> phoneVerifyOtp(
      BuildContext context, String phoneNumber, String otp) async {
    return await _postRequest(
      context: context,
      endpoint: ApiEndpoint.phoneverifyotp,
      data: {"phoneNumber": phoneNumber, "otp": otp},
      wrapData: false,
    );
  }

  Future<Response> completeregistration(
      BuildContext context,
      String userId,
      String fullName,
      String email,
      String gender,
      String password,
      String residentialLocation,
      String workLocation,
      String preferredTiming) async {
    return await _postRequest(
      context: context,
      endpoint: ApiEndpoint.completeregistration,
      data: {
        "userId": userId,
        "fullName": fullName,
        "email": email,
        "gender": gender,
        "password": password,
        "residentialLocation": residentialLocation,
        "workLocation": workLocation,
        "preferredTiming": preferredTiming
      },
      wrapData: false,
    );
  }

  Future<List<RouteModel>> routes(BuildContext context) async {
    final response = await _getRequest(
      context: context,
      endpoint: ApiEndpoint.routes,
    );

    List<dynamic> routesJson = [];
    if (response.data is List) {
      routesJson = response.data as List;
    } else if (response.data is Map && response.data['data'] is List) {
      routesJson = response.data['data'] as List;
    }

    return routesJson
        .map((routeJson) => RouteModel.fromJson(routeJson))
        .toList();
  }

  Future<Map<String, List<TripModel>>> searchTrips(
    BuildContext context,
    double originLatitude,
    double originLongitude,
    double destinationLatitude,
    double destinationLongitude,
    String date,
    String timePeriod, {
    String tripType = "oneway",
    double? returnOriginLatitude,
    double? returnOriginLongitude,
    double? returnDestinationLatitude,
    double? returnDestinationLongitude,
    String? returnDate,
    String? returnTimePeriod,
  }) async {
    Map<String, dynamic> payload;
    if (tripType == "roundtrip") {
      final Map<String, dynamic> onward = {
        "origin": {"latitude": originLatitude, "longitude": originLongitude},
        "destination": {
          "latitude": destinationLatitude,
          "longitude": destinationLongitude
        },
      };
      if (date.isNotEmpty) onward["date"] = date;
      if (timePeriod.isNotEmpty) onward["timePeriod"] = timePeriod;
      final Map<String, dynamic> ret = {
        "origin": {
          "latitude": returnOriginLatitude ?? destinationLatitude,
          "longitude": returnOriginLongitude ?? destinationLongitude
        },
        "destination": {
          "latitude": returnDestinationLatitude ?? originLatitude,
          "longitude": returnDestinationLongitude ?? originLongitude
        },
      };
      if ((returnDate ?? '').isNotEmpty) ret["date"] = returnDate;
      if ((returnTimePeriod ?? '').isNotEmpty)
        ret["timePeriod"] = returnTimePeriod;
      payload = {
        "tripType": "roundtrip",
        "onward": onward,
        "return": ret,
      };
    } else {
      final Map<String, dynamic> onward = {
        "origin": {"latitude": originLatitude, "longitude": originLongitude},
        "destination": {
          "latitude": destinationLatitude,
          "longitude": destinationLongitude
        },
      };
      if (date.isNotEmpty) onward["date"] = date;
      if (timePeriod.isNotEmpty) onward["timePeriod"] = timePeriod;
      payload = {
        "tripType": "oneway",
        "onward": onward,
      };
    }
    print('Search Trips Payload: $payload');
    final response = await _postRequest(
      context: context,
      endpoint: ApiEndpoint.tripSearch,
      data: payload,
      wrapData: false,
    );
    final data = response.data is Map ? response.data : {};
    print('Searched Trips Response: $data');
    final onwardTrips = (data['onwardTrips'] as List? ?? [])
        .map((tripJson) => TripModel.fromJson(tripJson as Map<String, dynamic>))
        .toList();
    final returnTrips = (data['returnTrips'] as List? ?? [])
        .map((tripJson) => TripModel.fromJson(tripJson as Map<String, dynamic>))
        .toList();
    return {
      'onwardTrips': onwardTrips,
      'returnTrips': returnTrips,
    };
  }

  Future<Response> getSeatLayout(BuildContext context, String tripId) async {
    // Construct the full path with the tripId (not routeId)
    final String seatLayoutPath =
        '${ApiEndpoint.trips.fullPath}/$tripId/seat-layout';

    return await _getRequest(
      context: context,
      endpoint: ApiEndpoint.trips,
      customPath: seatLayoutPath, // Pass the custom path
    );
  }

  Future<Response> makeBooking(
    BuildContext context,
    String scheduledTripId,
    String pickupStopId,
    String dropOffStopId,
    List<String> selectedSeatIds,
    String paymentMethod, {
    bool isRoundTrip = false,
    String? returnScheduledTripId,
    String? returnPickupStopId,
    String? returnDropOffStopId,
    List<String>? returnSelectedSeatIds,
  }) async {
    Map<String, dynamic> bookingData = {
      "tripType": isRoundTrip ? "roundtrip" : "oneway",
      "onwardScheduledTripId": scheduledTripId,
      "onwardPickupStopId": pickupStopId,
      "onwardDropOffStopId": dropOffStopId,
      "onwardSelectedSeatIds": selectedSeatIds,
      "paymentMethod": paymentMethod
    };

    if (isRoundTrip && returnScheduledTripId != null) {
      bookingData.addAll({
        "returnScheduledTripId": returnScheduledTripId,
        "returnPickupStopId": returnPickupStopId,
        "returnDropOffStopId": returnDropOffStopId,
        "returnSelectedSeatIds": returnSelectedSeatIds ?? [],
      });
    }

    return await _postRequest(
      context: context,
      endpoint: ApiEndpoint.bookings,
      data: bookingData,
      wrapData: false,
    );
  }

  Future<List<SubscriptionPlanModel>> getSubscriptionPlans(
      BuildContext context) async {
    final response = await _getRequest(
      context: context,
      endpoint: ApiEndpoint.subscriptionPlans,
    );

    List<dynamic> plansJson = [];
    if (response.data is List) {
      plansJson = response.data as List;
    } else if (response.data is Map && response.data['data'] is List) {
      plansJson = response.data['data'] as List;
    }

    return plansJson
        .map((planJson) => SubscriptionPlanModel.fromJson(planJson))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getAllStops(BuildContext context) async {
    final response = await _getRequest(
      context: context,
      endpoint: ApiEndpoint.routes,
      customPath: '/routes/all-stops',
    );
    if (response.data is List) {
      return List<Map<String, dynamic>>.from(response.data);
    } else if (response.data is Map && response.data['data'] is List) {
      return List<Map<String, dynamic>>.from(response.data['data']);
    }
    return [];
  }

  Future<Response> subscribeToPlan(
    BuildContext context,
    String planId, {
    required String pickupStopId,
    required String dropOffStopId,
    required String commuteType,
    String? returnPickupStopId,
    String? returnDropoffStopId,
  }) async {
    final url = '$_baseUrl/user-subscriptions/subscribe';
    try {
      final data = {
        "planId": planId,
        "pickupStopId": pickupStopId,
        "dropOffStopId": dropOffStopId,
        "commuteType": commuteType,
      };
      if (commuteType == 'roundtrip' &&
          returnPickupStopId != null &&
          returnDropoffStopId != null) {
        data["returnPickupStopId"] = returnPickupStopId;
        data["returnDropoffStopId"] = returnDropoffStopId;
      }
      final response = await _dio.post(
        url,
        data: data,
      );
      return response;
    } on DioException catch (err) {
      ApiErrorHandler.handleDioError(context, err);
      rethrow;
    } catch (err) {
      ApiErrorHandler.handleUnexpectedError(context, err);
      rethrow;
    }
  }

  Future<Response> subscribeToPlanWithCoordinates(
    BuildContext context,
    String planId, {
    required String commuteType,
    required LatLng pickupLocation,
    required LatLng dropOffLocation,
    required String subscriptionStartDate,
    LatLng? returnPickupLocation,
    LatLng? returnDropoffLocation,
  }) async {
    final url = '$_baseUrl/user-subscriptions/subscribe';
    try {
      final data = {
        "planId": planId,
        "commuteType": commuteType,
        "pickupLocation": {
          "latitude": pickupLocation.latitude,
          "longitude": pickupLocation.longitude,
        },
        "dropOffLocation": {
          "latitude": dropOffLocation.latitude,
          "longitude": dropOffLocation.longitude,
        },
        "subscriptionStartDate": subscriptionStartDate,
      };
      if (commuteType == 'roundtrip' &&
          returnPickupLocation != null &&
          returnDropoffLocation != null) {
        data["returnPickupLocation"] = {
          "latitude": returnPickupLocation.latitude,
          "longitude": returnPickupLocation.longitude,
        };
        data["returnDropoffLocation"] = {
          "latitude": returnDropoffLocation.latitude,
          "longitude": returnDropoffLocation.longitude,
        };
      }
      final response = await _dio.post(
        url,
        data: data,
      );
      return response;
    } on DioException catch (err) {
      ApiErrorHandler.handleDioError(context, err);
      rethrow;
    } catch (err) {
      ApiErrorHandler.handleUnexpectedError(context, err);
      rethrow;
    }
  }

  Future<List<RideModel>> getMyRides(BuildContext context, String type) async {
    final response = await _getRequest(
      context: context,
      endpoint: ApiEndpoint.myRides,
      queryParameters: {'type': type},
    );

    List<dynamic> ridesJson = [];
    if (response.data is List) {
      ridesJson = response.data as List;
    } else if (response.data is Map && response.data['data'] is List) {
      ridesJson = response.data['data'] as List;
    }

    return ridesJson.map((rideJson) => RideModel.fromJson(rideJson)).toList();
  }

  // --- UPDATED --- This method now correctly parses the detailed booking response.
  Future<RideModel> getBookingDetails(
      BuildContext context, String bookingId) async {
    final response = await _getRequest(
      context: context,
      endpoint: ApiEndpoint
          .myRides, // This endpoint value doesn't matter since we use customPath
      customPath: '/bookings/$bookingId/details',
    );

    // The backend returns a single JSON object. Ensure it's a map.
    if (response.data is Map<String, dynamic>) {
      // The response from `/details` is structured differently from the list view.
      // We need to map it manually to our RideModel.
      final json = response.data as Map<String, dynamic>;

      // The backend provides a `paymentBreakdown` object. We need to extract the total fare.
      final paymentBreakdown =
          json['paymentBreakdown'] as Map<String, dynamic>? ?? {};
      final fare = paymentBreakdown['total']?.toString() ?? '₹0';

      // The backend provides a `rideDetail` object for date and time.
      final rideDetail = json['rideDetail'] as Map<String, dynamic>? ?? {};
      final dateTimeParts =
          (rideDetail['dateTime']?.toString() ?? 'N/A, N/A').split(', ');
      final date = dateTimeParts.length > 0 ? dateTimeParts[0] : 'N/A';
      final time = dateTimeParts.length > 1 ? dateTimeParts[1] : 'N/A';

      // Manually construct the RideModel using the correct fields from the detailed response.
      return RideModel(
        bookingId: json['bookingId'] ?? '',
        crn: json['crn'] ?? '',
        vehicleDescription: rideDetail['carCategory'] ?? 'N/A',
        date: date,
        time: time,
        fare: fare,
        paymentMethodDisplay: json['paymentMethodDisplay'] ?? 'N/A',
        pickupLocation: json['pickupLocation'] ?? '',
        destinationLocation: json['destinationLocation'] ?? '',
        status: json['status'] ?? '',
        statusDisplay: json['statusDisplay'] ?? '',
        canTrack:
            json['canTrack'] ?? false, // Crucial part: parse the canTrack flag.
      );
    } else {
      // If the response is not what we expect, throw an error.
      throw Exception(
          'Failed to parse booking details. Unexpected response format.');
    }
  }

  Future<UserModel> getUserInfo(BuildContext context) async {
    final response = await _getRequest(
      context: context,
      endpoint: ApiEndpoint.myRides,
      customPath: '/users/me',
    );
    return UserModel.fromJson(response.data);
  }

  Future<Response> cancelBooking(
    BuildContext context,
    String bookingId,
    String predefinedReason,
  ) async {
    final url = '$_baseUrl/bookings/$bookingId/cancel';
    try {
      final data = {
        "predefinedReason": predefinedReason,
      };
      final response = await _dio.patch(
        url,
        data: data,
      );
      return response;
    } on DioException catch (err) {
      ApiErrorHandler.handleDioError(context, err);
      rethrow;
    } catch (err) {
      ApiErrorHandler.handleUnexpectedError(context, err);
      rethrow;
    }
  }
}
