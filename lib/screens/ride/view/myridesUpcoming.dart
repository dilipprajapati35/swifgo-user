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
  final RideModel? ride;
  const Myridesupcoming({super.key, this.ride});

  @override
  State<Myridesupcoming> createState() => _MyridesupcomingState();
}

class _MyridesupcomingState extends State<Myridesupcoming> {
  late Future<List<RideModel>> _futureRides;

  @override
  void initState() {
    super.initState();
    // If a specific ride is passed, we don't need to fetch all rides
    if (widget.ride != null) {
      _futureRides = Future.value([widget.ride!]);
    } else {
      _futureRides = DioHttp().getMyRides(context, 'upcoming');
    }
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
      body: FutureBuilder<List<RideModel>>(
        future: _futureRides,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load rides'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No upcoming rides found'));
          }
          final rides = snapshot.data!;
          return ListView.builder(
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final ride = rides[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMapSection(ride),
                      _buildCrnRow(ride),
                      Divider(height: 1),
                      _buildLocationSection(ride),
                      Divider(height: 1),
                      _buildRideDetailSection(ride),
                      Divider(height: 1),
                      _buildPaymentSection(ride),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMapSection(RideModel ride) {
    // Using a fixed location (New Delhi) as RideModel does not have coordinates
    final LatLng initialPosition = LatLng(19.0760, 72.8777); // Mumbai

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      child: SizedBox(
        height: 140,
        width: double.infinity,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialPosition,
            zoom: 12,
          ),
          markers: {
            Marker(
              markerId: MarkerId('pickup'),
              position: initialPosition,
              infoWindow: InfoWindow(title: 'Pickup Location'),
            ),
          },
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          liteModeEnabled: true, // For a static-like map
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Color(0xff3E57B4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Rich in 15 min',
              style: GoogleFonts.nunito(color: Colors.white, fontSize: 13),
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
                  style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600),
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
                  style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600),
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
          Text('RIDE DETAIL', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xff5A5A5A))),
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
          SizedBox(width: 120, child: Text(label, style: GoogleFonts.nunito(fontSize: 13, color: Color(0xff5A5A5A)))),
          Expanded(child: Text(value, style: GoogleFonts.nunito(fontSize: 13, color: Color(0xff132235)))),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(RideModel ride) {
    // Parse the fare to get numeric value
    String fareText = ride.fare.replaceAll('₹', '');
    double fareAmount = double.tryParse(fareText) ?? 0.0;
    
    // Calculate other amounts based on fare
    double promoAmount = fareAmount * 0.1; // 10% promo
    double taxAmount = fareAmount * 0.03; // 3% tax
    double totalAmount = fareAmount - promoAmount + taxAmount;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PAYMENT', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xff5A5A5A))),
          SizedBox(height: 8),
          _buildPaymentRow('Ride Fair:', '₹${fareAmount.toStringAsFixed(0)}'),
          _buildPaymentRow('Promo:', '-₹${promoAmount.toStringAsFixed(1)}', valueColor: Color(0xffE02D3C)),
          _buildPaymentRow('Tax:', '₹${taxAmount.toStringAsFixed(1)}'),
          Row(
            children: [
              SizedBox(width: 120, child: Text('Total:', style: GoogleFonts.nunito(fontSize: 13, color: Color(0xff5A5A5A)))),
              Expanded(
                child: Text('₹${totalAmount.toStringAsFixed(1)}', style: GoogleFonts.nunito(fontSize: 16, color: Color(0xff3E57B4), fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              SizedBox(width: 120, child: Text('Payment Via:', style: GoogleFonts.nunito(fontSize: 13, color: Color(0xff5A5A5A)))),
              Icon(Icons.account_balance_wallet_rounded, size: 18, color: Color(0xff3E57B4)),
              SizedBox(width: 4),
              Text(ride.paymentMethodDisplay, style: GoogleFonts.nunito(fontSize: 13, color: Color(0xff132235))),
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
          SizedBox(width: 120, child: Text(label, style: GoogleFonts.nunito(fontSize: 13, color: Color(0xff5A5A5A)))),
          Expanded(child: Text(value, style: GoogleFonts.nunito(fontSize: 13, color: valueColor ?? Color(0xff132235)))),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () async {
                final token = await MySecureStorage().readToken();
                if (token != null && widget.ride?.bookingId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrackingScreen(
                        bookingId: widget.ride!.bookingId,
                        userToken: token,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Unable to start tracking: missing token or booking ID.')),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xff3E57B4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Track Ride', style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xff3E57B4))),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Open cancel booking screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CancelBookingScreen(
                      bookingId: widget.ride?.bookingId ?? '',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffE02D3C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Cancel Booking', style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
