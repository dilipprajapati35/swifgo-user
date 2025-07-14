// lib/services/api_error_handler.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arch/widget/snack_bar.dart';

class ApiErrorHandler {
  // Handle Dio-specific errors
  static void handleDioError(BuildContext context, DioException err) {
    if (err.response != null) {
      final statusCode = err.response!.statusCode;
      final data = err.response!.data ?? {};
      final message = data['message'] ?? 'Unknown error';

      switch (statusCode) {
        case 400:
          MySnackBar.showSnackBar(context, 'Bad Request: $message');
          break;
        case 401:
          MySnackBar.showSnackBar(context, 'Unauthorized: $message');
          break;
        case 403:
          MySnackBar.showSnackBar(context, 'Forbidden: $message');
          break;
        case 404:
          MySnackBar.showSnackBar(context, 'Not Found: $message');
          break;
        case 405:
          MySnackBar.showSnackBar(context, 'Method Not Allowed: $message');
          break;
        case 408:
          MySnackBar.showSnackBar(context, 'Request Timeout: $message');
          break;
        case 409:
          MySnackBar.showSnackBar(context, 'Conflict: $message');
          break;
        case 429:
          MySnackBar.showSnackBar(context, 'Too Many Requests: $message');
          break;
        case 500:
          MySnackBar.showSnackBar(context, 'Server Error: $message');
          break;
        case 502:
          MySnackBar.showSnackBar(context, 'Bad Gateway: $message');
          break;
        case 503:
          MySnackBar.showSnackBar(context, 'Service Unavailable: $message');
          break;
        case 504:
          MySnackBar.showSnackBar(context, 'Gateway Timeout: $message');
          break;
        default:
          MySnackBar.showSnackBar(context, 'Error ($statusCode): $message');
          break;
      }
    } else {
      // Network or connectivity issue
      final errorMessage = _getDioExceptionMessage(err);
      MySnackBar.showSnackBar(context, errorMessage);
    }
    throw Exception('Dio Error: $err');
  }

  // Handle unexpected errors (non-Dio)
  static void handleUnexpectedError(BuildContext context, dynamic err) {
    MySnackBar.showSnackBar(context, 'Unexpected Error: $err');
    throw Exception('Unexpected Error: $err');
  }

  // Map DioException types to user-friendly messages
  static String _getDioExceptionMessage(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection Timeout: Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Send Timeout: Failed to send request.';
      case DioExceptionType.receiveTimeout:
        return 'Receive Timeout: Server took too long to respond.';
      case DioExceptionType.badCertificate:
        return 'Bad Certificate: Security issue with the server.';
      case DioExceptionType.badResponse:
        return 'Bad Response: Invalid response from server.';
      case DioExceptionType.cancel:
        return 'Request Cancelled: Operation was cancelled.';
      case DioExceptionType.connectionError:
        return 'Connection Error: Unable to connect to the server.';
      case DioExceptionType.unknown:
      default:
        return 'Network Error: ${err.message ?? 'Unknown error'}';
    }
  }
}
