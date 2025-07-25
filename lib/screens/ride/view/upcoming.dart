import 'package:flutter/material.dart';
import 'package:flutter_arch/screens/ride/model/rideModel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_arch/services/dio_http.dart';
import 'package:flutter_arch/screens/ride/view/myridesUpcoming.dart';
import 'package:provider/provider.dart';
import 'package:flutter_arch/screens/ride/provider/rideProvider.dart';

class Upcoming extends StatefulWidget {
  const Upcoming({super.key});

  @override
  State<Upcoming> createState() => _UpcomingState();
}

class _UpcomingState extends State<Upcoming> {
  @override
  void initState() {
    super.initState();
    // Fetch rides on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RideProvider>(context, listen: false).fetchRides(context, 'upcoming');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RideProvider>(
      builder: (context, rideProvider, child) {
        final isLoading = rideProvider.isLoading('upcoming');
        final error = rideProvider.getError('upcoming');
        final rides = rideProvider.getUpcomingRides();
        if (isLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (error != null) {
          return Center(child: Text(error));
        } else if (rides.isEmpty) {
          return Center(child: Text('No upcoming rides found'));
        }
        return SingleChildScrollView(
          child: Column(
            children: rides.map((ride) => _buildRideCard(ride)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildRideCard(RideModel ride) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Myridesupcoming(ride: ride),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildRideCardContent(ride),
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildRideCardContent(RideModel ride) {
    // Show all stops: first is pickup, last is destination, others are waypoints
    final stops = (ride as dynamic).stops ?? [];
    return Column(
      children: [
        _buildTopRow(ride),
        SizedBox(height: 6),
        _buildDatePaymentRow(ride),
        SizedBox(height: 8),
        _buildTypeDurationRow(),
        SizedBox(height: 12),
        Divider(thickness: 1),
        ...List.generate(stops.length, (index) {
          final stop = stops[index];
          String label;
          Color color;
          if (index == 0) {
            label = 'Pickup';
            color = Color(0xff08875D);
          } else if (index == stops.length - 1) {
            label = 'Destination';
            color = Colors.red;
          } else {
            label = 'Stop ${index}';
            color = Colors.blueGrey;
          }
          return ListTile(
            leading: Container(
              height: 18,
              width: 18,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            title: Text(label, style: GoogleFonts.nunito(color: color, fontSize: 12)),
            subtitle: Text(
              stop['name'] ?? '',
              style: GoogleFonts.nunito(fontSize: 17),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }),
        Divider(),
        _buildArrivedRow(),
      ],
    );
  }

  Widget _buildTopRow(RideModel ride) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Manual', style: GoogleFonts.nunito(fontSize: 13, color: Color(0xfff364B63))),
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey,
          ),
        ),
        Text('Sedan', style: GoogleFonts.nunito(fontSize: 13, color: Color(0xff364B63))),
        SizedBox(width: 170),
        Icon(Icons.currency_rupee, size: 17),
        Text(
          ride.fare.replaceAll('₹', ''),
          style: GoogleFonts.roboto(fontSize: 17, color: Color(0xff132235)),
        ),
      ],
    );
  }

  Widget _buildDatePaymentRow(RideModel ride) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${ride.date}, ${ride.time}', style: GoogleFonts.nunito()),
        Row(
          children: [
            Image.asset(
              ride.paymentMethodDisplay.toLowerCase() == 'cash'
                  ? 'assets/images/moneys.png'
                  : 'assets/images/Card Flags.png',
              fit: BoxFit.values[1],
            ),
            SizedBox(width: 3),
            Text(
              ride.paymentMethodDisplay,
              style: GoogleFonts.nunito(fontSize: 13, color: Color(0xff132235)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeDurationRow() {
    return Row(
      children: [
        Container(
          height: 19,
          width: 121,
          decoration: BoxDecoration(
            color: Color(0xff3E57B4),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              'One Way | 4 Hours',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPickupTile(RideModel ride) {
    return ListTile(
      leading: Container(
        height: 18,
        width: 18,
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xffDAEDE7), width: 5),
          color: Color(0xff08875D),
          shape: BoxShape.circle,
        ),
      ),
      title: Text('Pickup', style: GoogleFonts.nunito(color: Color(0xff08875D), fontSize: 12)),
      subtitle: Text(
        overflow: TextOverflow.ellipsis,
        ride.pickupLocation,
        style: GoogleFonts.nunito(fontSize: 17),
      ),
    );
  }

  Widget _buildDestinationTile(RideModel ride) {
    return ListTile(
      leading: Container(
        height: 18,
        width: 18,
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xffF2E4E4), width: 5),
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),
      title: Text('Destination', style: GoogleFonts.nunito(color: Colors.red, fontSize: 12)),
      subtitle: Text(
        overflow: TextOverflow.ellipsis,
        ride.destinationLocation,
        style: GoogleFonts.nunito(fontSize: 17),
      ),
    );
  }

  Widget _buildArrivedRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 16),
          child: Icon(Icons.person, color: Color(0xff3E57B4)),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 16.0),
          child: Text('Driver Arrived in ', style: GoogleFonts.nunito(color: Color(0xff132235))),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 16),
          child: Text('15 min ', style: GoogleFonts.nunito(color: Color(0xff3E57B4))),
        ),
      ],
    );
  }
}
