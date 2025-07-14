import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arch/screens/homepage/view/seat_selection.screen.dart';
import 'package:flutter_arch/screens/payment/view/paymentScreen2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';


class Paymentscreen1 extends StatefulWidget {
  final List<SeatInfo> selectedSeats;
  final String scheduledTripId;
  final String pickupStopId;
  final String dropOffStopId;
  final String pickupAddress;
  final String destinationAddress;
  final String price;
  final bool isRoundTrip;
  final String? returnPickupAddress;
  final String? returnDestinationAddress;
  final String? returnScheduledTripId;
  final String? returnPickupStopId;
  final String? returnDropOffStopId;
  final List<SeatInfo>? returnSelectedSeats;

  const Paymentscreen1({
    super.key,
    required this.selectedSeats,
    required this.scheduledTripId,
    required this.pickupStopId,
    required this.dropOffStopId,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.price,
    this.isRoundTrip = false,
    this.returnPickupAddress,
    this.returnDestinationAddress,
    this.returnScheduledTripId,
    this.returnPickupStopId,
    this.returnDropOffStopId,
    this.returnSelectedSeats,
  });
  @override
  State<Paymentscreen1> createState() => _Paymentscreen1State();
}

class _Paymentscreen1State extends State<Paymentscreen1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 289,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(),
                  child: Image.asset(
                    'assets/images/snazzy-image (2) 1.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 53,
                  left: 16,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back),
                    ),
                  ),
                ),
                Positioned(
                  top: 53,
                  right: 16,
                  child: Container(
                    width: 96,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(0xff3E57B4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'One Way',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.only(left: 15),
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Image.asset('assets/images/Frame 47770.png'),
                  ),
                  DottedDashedLine(
                    height: 16,
                    width: 2,
                    axis: Axis.vertical,
                    dashColor: Colors.grey,
                    dashSpace: 10,
                  ),
                ],
              ),
              title: Text(
                'Pickup',
                style: GoogleFonts.nunito(
                  color: Color(0xff08875D),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                widget.pickupAddress, // Use the passed pickup address
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  color: Color(0xff132235),
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Divider(thickness: 0.4, height: 0),
            ListTile(
              dense: true,
              // enableFeedback: true,
              contentPadding: EdgeInsets.only(left: 16, top: 0, bottom: 5),

              leading: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  DottedDashedLine(
                    height: 16,
                    width: 2,
                    axis: Axis.vertical,
                    dashColor: Colors.grey,
                    dashSpace: 10,
                  ),
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Image.asset('assets/images/Frame 47770 (1).png'),
                  ),
                ],
              ),
              title: Text(
                'Destination',
                style: GoogleFonts.nunito(
                  color: Color(0xffE02D3C),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                widget.destinationAddress, // Use the passed destination address
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  color: Color(0xff132235),
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            // Show return trip information if it's a round trip
            if (widget.isRoundTrip && widget.returnPickupAddress != null && widget.returnDestinationAddress != null) ...[
              Divider(thickness: 0.4, height: 0),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.only(left: 15),
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Image.asset('assets/images/Frame 47770.png'),
                    ),
                    DottedDashedLine(
                      height: 16,
                      width: 2,
                      axis: Axis.vertical,
                      dashColor: Colors.grey,
                      dashSpace: 10,
                    ),
                  ],
                ),
                title: Text(
                  'Return Pickup',
                  style: GoogleFonts.nunito(
                    color: Color(0xff08875D),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  widget.returnPickupAddress!,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    color: Color(0xff132235),
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Divider(thickness: 0.4, height: 0),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.only(left: 16, top: 0, bottom: 5),
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    DottedDashedLine(
                      height: 16,
                      width: 2,
                      axis: Axis.vertical,
                      dashColor: Colors.grey,
                      dashSpace: 10,
                    ),
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Image.asset('assets/images/Frame 47770 (1).png'),
                    ),
                  ],
                ),
                title: Text(
                  'Return Destination',
                  style: GoogleFonts.nunito(
                    color: Color(0xffE02D3C),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  widget.returnDestinationAddress!,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    color: Color(0xff132235),
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
            Divider(thickness: 8, color: Color(0xffF8FAFC)),
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16,
                top: 16,
                bottom: 0,
              ),
              child: Container(
                // height: 161,
                // width: 393,
                // decoration: BoxDecoration(color: Colors.amber),
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 16),
                        Text(
                          'VEHICLE TYPE',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      alignment: Alignment.center,
                      // height: 105,
                      width: 361,
                      decoration: BoxDecoration(
                        // color: Colors.blue,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(0xffE9F0F7)),
                      ),
                      child: Column(
                        children: [
                          // Replace the Transmission Type row with this implementation:

                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Image.asset('assets/images/Group.png',
                                    scale: 2),
                                SizedBox(width: 8),
                                // Left side content with label
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Transmission Type',
                                    style: GoogleFonts.nunito(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff132235),
                                    ),
                                  ),
                                ),
                                // Right side content with value
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Manual',
                                        style: GoogleFonts.nunito(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xff132235),
                                        ),
                                      ),
                                      // Replace IconButton with Icon to save space
                                      Icon(Icons.arrow_forward_ios, size: 20),
                                      SizedBox(
                                          width:
                                              4), // Small padding on right side
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            indent: 15,
                            endIndent: 15,
                            height: 0,
                            color: Color(0xffE9F0F7),
                            thickness: 0.4,
                          ),
                          // Replace the Car Type row with this implementation:

                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Image.asset('assets/images/Group.png',
                                    scale: 2),
                                SizedBox(width: 8),
                                // Left side content with label
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Car Type',
                                    style: GoogleFonts.nunito(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff132235),
                                    ),
                                  ),
                                ),
                                // Right side content with value
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Hatchback',
                                        style: GoogleFonts.nunito(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xff132235),
                                        ),
                                      ),
                                      // Replace IconButton with Icon to save space
                                      Icon(Icons.arrow_forward_ios, size: 20),
                                      SizedBox(
                                          width:
                                              4), // Small padding on right side
                                    ],
                                  ),
                                ),
                              ],
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
            Divider(thickness: 8, color: Color(0xffF8FAFC)),
            Padding(
              padding: const EdgeInsets.only(
                  left: 8.0, right: 8, top: 8, bottom: 32),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 18),
                      Text(
                        'FARE',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff132235),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 60,
                        width: 113,
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xffE9F0F7)),
                          // color: Colors.pink,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'HatchBack',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff607080),
                              ),
                            ),
                            Text(
                              '₹501',
                              style: GoogleFonts.nunito(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff132235),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 60,
                        width: 113,
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xffE9F0F7)),
                          // color: Colors.pink,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sedan',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff607080),
                              ),
                            ),
                            Text(
                              'Soon...',
                              style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff132235),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 60,
                        width: 113,
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xffE9F0F7)),
                          // color: Colors.pink,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'XUV',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff607080),
                              ),
                            ),
                            Text(
                              'Soon...',
                              style: GoogleFonts.nunito(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff132235),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              // indent: 15,
              // endIndent: 15,
              // height: 0,
              color: Color(0xffE9F0F7),
              thickness: 0.5,
            ),
            SizedBox(
              height: 5,
            ),
            Column(
              children: [
                Row(
                  // Change from spaceEvenly to spaceBetween to utilize space better
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // First item - Payment
                    Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Row(
                        children: [
                          Icon(Icons.payment,
                              color: Color(0xff2F6FED), size: 20),
                          SizedBox(width: 4), // Reduced spacing
                          Text(
                            'Payment',
                            style: GoogleFonts.nunito(
                              fontSize: 14, // Slightly smaller text
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider
                    DottedDashedLine(
                      height: 15,
                      width: 0,
                      axis: Axis.vertical,
                      dashSpace: 0,
                      dashColor: Color(0xffE9F0F7),
                    ),

                    // Second item - Coupon (replace IconButton with Icon)
                    Row(
                      children: [
                        Icon(Icons.confirmation_num_outlined,
                            color: Color(0xff2F6FED), size: 20),
                        SizedBox(width: 4), // Reduced spacing
                        Text(
                          'Coupon',
                          style: GoogleFonts.nunito(
                            fontSize: 14, // Slightly smaller text
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // Divider
                    DottedDashedLine(
                      height: 15,
                      width: 0,
                      axis: Axis.vertical,
                      dashSpace: 0,
                      dashColor: Color(0xffE9F0F7),
                    ),

                    // Third item - Personal
                    Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Row(
                        children: [
                          Icon(Icons.person,
                              color: Color(0xffB25E09), size: 20),
                          SizedBox(width: 4), // Reduced spacing
                          Text(
                            'Personal',
                            style: GoogleFonts.nunito(
                              fontSize: 14, // Slightly smaller text
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10)
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen2(
                      selectedSeats: widget.selectedSeats,
                      scheduledTripId: widget.scheduledTripId,
                      pickupStopId: widget.pickupStopId,
                      dropOffStopId: widget.dropOffStopId,
                      isRoundTrip: widget.isRoundTrip,
                      returnScheduledTripId: widget.returnScheduledTripId,
                      returnPickupStopId: widget.returnPickupStopId,
                      returnDropOffStopId: widget.returnDropOffStopId,
                      returnSelectedSeatIds: widget.returnSelectedSeats?.map((seat) => seat.id).toList(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                  fixedSize: Size(393, 48),
                  backgroundColor: Color(0xff3E57B4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  )),
              child: Text(
                'Request Ride',
                style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xffffffff)),
              ),
            ).paddingAll(16),
          ],
        ),
      ),

      // floatingActionButton: FloatingActionButton(onPressed: (){},backgroundColor: Colors.amber,),
    );
  }
}
