import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_arch/screens/ride/view/cancel_booking_screen.dart';
import 'package:flutter_arch/screens/ride/view/ride_call_screen.dart';
import 'package:flutter_arch/screens/ride/view/ride_chat_screen.dart';

class NavigateRideScreen extends StatelessWidget {
  final String bookingId;
  const NavigateRideScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Map section
            SizedBox(
              height: 260,
              width: double.infinity,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(17.385044, 78.486671),
                      zoom: 13,
                    ),
                    polylines: {
                      Polyline(
                        polylineId: PolylineId('route'),
                        color: Color(0xff3E57B4),
                        width: 4,
                        points: [
                          LatLng(17.385044, 78.486671),
                          LatLng(17.400000, 78.480000),
                          LatLng(17.410000, 78.490000),
                        ],
                      ),
                    },
                    markers: {
                      Marker(
                        markerId: MarkerId('pickup'),
                        position: LatLng(17.385044, 78.486671),
                        infoWindow: InfoWindow(title: 'Pickup'),
                      ),
                      Marker(
                        markerId: MarkerId('dropoff'),
                        position: LatLng(17.410000, 78.490000),
                        infoWindow: InfoWindow(title: 'Dropoff'),
                      ),
                    },
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.menu, color: Color(0xff3E57B4)),
                        onPressed: () {},
                      ),
                    ),
                  ),
                  Positioned(
                    left: 32,
                    top: 60,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xff3E57B4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '13.59 km',
                        style: GoogleFonts.nunito(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Sheet section
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Your driver is coming in 3:35',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff132235),
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sergio Ramasis', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16)),
                                Row(
                                  children: [
                                    Text('800m ', style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey)),
                                    Text('5mins away', style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.amber, size: 16),
                                    Text('4.9 (531 reviews)', style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12),
                          Image.network(
                            'https://imgd.aeplcdn.com/664x374/n/cw/ec/140233/creta-exterior-right-front-three-quarter-2.jpeg',
                            width: 60,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Text('Payment method', style: GoogleFonts.nunito(fontSize: 15, color: Colors.grey)),
                          Spacer(),
                          Text('₹500.00', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff132235))),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xffF5F6FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(Icons.credit_card, color: Colors.white, size: 24),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('**** **** **** 8970', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600)),
                                  Text('Expires: 12/26', style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RideCallScreen(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Color(0xff3E57B4)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Icon(Icons.phone, color: Color(0xff3E57B4)),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RideChatScreen(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Color(0xff3E57B4)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Icon(Icons.message, color: Color(0xff3E57B4)),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CancelBookingScreen(
                                      bookingId: bookingId,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff3E57B4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text('Cancel Ride', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 