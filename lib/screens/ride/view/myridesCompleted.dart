import 'package:flutter/material.dart';
import 'package:flutter_arch/screens/ride/model/rideModel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter_arch/services/dio_http.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Myridescompleted extends StatefulWidget {
  const Myridescompleted({super.key});

  @override
  State<Myridescompleted> createState() => _MyridescompletedState();
}

class _MyridescompletedState extends State<Myridescompleted> {
  late Future<List<RideModel>> _futureRides;

  @override
  void initState() {
    super.initState();
    _futureRides = DioHttp().getMyRides(context, 'completed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          'Completed Rides',
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
            return Center(child: Text('No completed rides found'));
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
                      // _buildMapSection(ride),
                      _buildCrnRow(ride),
                      Divider(height: 1),
                      _buildLocationSection(ride),
                      Divider(height: 1),
                      _buildRideDetailSection(ride),
                      _buildReceiptLink(),
                      _buildRateButton(),
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
              color: Color(0xff08875D),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Completed',
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
          _buildDetailRow('Car Type:', 'Hatchback'),
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

  Widget _buildReceiptLink() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () {},
          child: Text(
            'View Receipt',
            style: GoogleFonts.nunito(
              color: Color(0xff3E57B4),
              fontSize: 13,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRateButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xffB25E09),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            '★ Rate your ride',
            style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
