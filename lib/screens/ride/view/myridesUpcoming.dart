import 'dart:async'; // --- NEW ---
import 'package:flutter/material.dart';
import 'package:flutter_arch/screens/ride/model/rideModel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter_arch/services/dio_http.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_arch/screens/ride/view/cancel_booking_screen.dart';
import 'package:flutter_arch/screens/ride/view/navigate_ride_screen.dart';
import 'package:flutter_arch/storage/flutter_secure_storage.dart';
import 'package:flutter_arch/views/tracking_screen.dart';

class Myridesupcoming extends StatefulWidget {
  final RideModel ride; // --- UPDATED --- Made non-nullable
  const Myridesupcoming({super.key, required this.ride}); // --- UPDATED ---

  @override
  State<Myridesupcoming> createState() => _MyridesupcomingState();
}

class _MyridesupcomingState extends State<Myridesupcoming> {
  // --- NEW --- State variable to hold the ride details that can be updated.
  late RideModel _rideDetail;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    // --- NEW --- Initialize our state variable with the data passed to the widget.
    _rideDetail = widget.ride;

    // --- NEW --- Start polling for updates only if tracking is not yet available.
    if (_rideDetail.canTrack == false) {
      _startPollingForUpdates();
    }
  }

  // --- NEW --- Clean up the timer when the screen is closed to prevent memory leaks.
  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  // --- NEW --- Function to start a periodic timer that refreshes ride details.
  void _startPollingForUpdates() {
    // Poll the backend every 10 seconds.
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      print("Polling for ride status update...");
      try {
        // We assume your DioHttp service has a method to get a single booking's details.
        // If it's named differently, please adjust. This should return a RideModel.
        final updatedRide =
            await DioHttp().getBookingDetails(context, _rideDetail.bookingId);

        // If the 'canTrack' status has changed, update the UI.
        if (updatedRide.canTrack != _rideDetail.canTrack) {
          setState(() {
            _rideDetail = updatedRide;
          });
          // Once tracking is available, we can stop polling.
          if (updatedRide.canTrack) {
            timer.cancel();
            print("Tracking is now available. Polling stopped.");
          }
        }
      } catch (e) {
        print("Failed to poll for ride details: $e");
        // We don't show a snackbar here to avoid bothering the user on every failed poll.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 53,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          'Upcoming Rides',
          style: GoogleFonts.nunito(
            fontSize: 20,
            color: Color(0xff132235),
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
      ),
      // --- UPDATED --- Removed FutureBuilder as we now manage state directly.
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCrnRow(_rideDetail),
                Divider(height: 1),
                _buildLocationSection(_rideDetail),
                Divider(height: 1),
                _buildRideDetailSection(_rideDetail),
                Divider(height: 1),
                _buildPaymentSection(_rideDetail),
                _buildActionButtons(), // This will now use the updated _rideDetail
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCrnRow(RideModel ride) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'CRN ${ride.crn}',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xff132235),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(RideModel ride) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.circle, color: Color(0xff08875D), size: 14),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  ride.pickupLocation,
                  style: GoogleFonts.nunito(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.circle, color: Color(0xffE02D3C), size: 14),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  ride.destinationLocation,
                  style: GoogleFonts.nunito(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRideDetailSection(RideModel ride) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RIDE DETAIL',
              style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff5A5A5A))),
          SizedBox(height: 8),
          _buildDetailRow('Ride Type:', 'One Way'),
          _buildDetailRow('Transmission Type:', 'Manual'),
          _buildDetailRow('Car Type:', ride.vehicleDescription),
          _buildDetailRow('No of hours:', '2 Hrs'),
          _buildDetailRow('Date & Time:', '${ride.date} ${ride.time}'),
          _buildDetailRow('Booked For:', 'Self(Personal)'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          SizedBox(
              width: 120,
              child: Text(label,
                  style:
                      GoogleFonts.nunito(fontSize: 13, color: Color(0xff5A5A5A)))),
          Expanded(
              child: Text(value,
                  style: GoogleFonts.nunito(
                      fontSize: 13, color: Color(0xff132235)))),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(RideModel ride) {
    String fareText = ride.fare.replaceAll('₹', '');
    double fareAmount = double.tryParse(fareText) ?? 0.0;
    double promoAmount = fareAmount * 0.1;
    double taxAmount = fareAmount * 0.03;
    double totalAmount = fareAmount - promoAmount + taxAmount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PAYMENT',
              style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff5A5A5A))),
          SizedBox(height: 8),
          _buildPaymentRow('Ride Fair:', '₹${fareAmount.toStringAsFixed(0)}'),
          _buildPaymentRow('Promo:', '-₹${promoAmount.toStringAsFixed(1)}',
              valueColor: Color(0xffE02D3C)),
          _buildPaymentRow('Tax:', '₹${taxAmount.toStringAsFixed(1)}'),
          Row(
            children: [
              SizedBox(
                  width: 120,
                  child: Text('Total:',
                      style: GoogleFonts.nunito(
                          fontSize: 13, color: Color(0xff5A5A5A)))),
              Expanded(
                child: Text('₹${totalAmount.toStringAsFixed(1)}',
                    style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Color(0xff3E57B4),
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                  width: 120,
                  child: Text('Payment Via:',
                      style: GoogleFonts.nunito(
                          fontSize: 13, color: Color(0xff5A5A5A)))),
              Icon(Icons.account_balance_wallet_rounded,
                  size: 18, color: Color(0xff3E57B4)),
              SizedBox(width: 4),
              Text(ride.paymentMethodDisplay,
                  style: GoogleFonts.nunito(
                      fontSize: 13, color: Color(0xff132235))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          SizedBox(
              width: 120,
              child: Text(label,
                  style:
                      GoogleFonts.nunito(fontSize: 13, color: Color(0xff5A5A5A)))),
          Expanded(
              child: Text(value,
                  style: GoogleFonts.nunito(
                      fontSize: 13, color: valueColor ?? Color(0xff132235)))),
        ],
      ),
    );
  }

  // --- UPDATED --- This entire widget is now cleaner and more robust.
  Widget _buildActionButtons() {
    final bool isTrackable = _rideDetail.canTrack;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              // --- UPDATED --- Simplified logic
              onPressed: isTrackable
                  ? () async {
                      // The data is already fresh, no need to re-fetch here.
                      final token = await MySecureStorage().readToken();
                      if (token != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrackingScreen(
                              bookingId: _rideDetail.bookingId,
                              userToken: token,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not authenticate. Please log in again.')),
                        );
                      }
                    }
                  : null, // Button is disabled if not trackable
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isTrackable ? Color(0xff3E57B4) : Colors.grey.shade400,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                // --- UPDATED --- Simplified logic
                isTrackable ? 'Track Live' : 'Tracking Unavailable',
                style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isTrackable
                        ? Color(0xff3E57B4)
                        : Colors.grey.shade500),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CancelBookingScreen(
                      bookingId: _rideDetail.bookingId,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffE02D3C),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Cancel Booking',
                  style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
