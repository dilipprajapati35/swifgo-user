import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'one_way_tab.dart';
import 'round_trip_tab.dart';
import 'package:flutter_arch/screens/homepage/view/premium/subscription_trip_selection_screen.dart';


class Getpremium extends StatelessWidget {
  const Getpremium({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            "assets/images/carr.png",
          ),
          // fit: BoxFit.cover,
          fit: BoxFit.fill,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.6),
            BlendMode.darken,
          ),
        ),
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Get Premium',
              style: GoogleFonts.nunito(fontSize: 20, color: Colors.white),
            ),
            centerTitle: true,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
                  Text(
                    'Back',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
            leadingWidth: 70,
            bottom: TabBar(
              labelPadding: const EdgeInsets.only(bottom: 9),
              indicatorWeight: 3.0,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              dividerColor: Colors.transparent,
              indicatorColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Text('One way', style: GoogleFonts.nunito(fontSize: 16)),
                Text('Round Trip', style: GoogleFonts.nunito(fontSize: 16)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              OneWay(),
              RoundTripTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class DottedLine extends StatelessWidget {
  final double height;
  final Color color;
  final double dashWidth;
  final double dashSpace;

  const DottedLine({
    super.key,
    this.height = 1.5,
    this.color = const Color(0xff8E8E93),
    this.dashWidth = 4.0,
    this.dashSpace = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _DottedLinePainter(
        color: color,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  _DottedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
Future<void> showRideSelectionModal(
    BuildContext context, Function(String) onSelected) async {
  String selected = 'Morning ride';
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 75), // Space for close button
                  padding: const EdgeInsets.fromLTRB(24, 25, 24, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.0),
                      topRight: Radius.circular(24.0),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Choose Ride',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Morning ride',
                            groupValue: selected,
                            onChanged: (val) => setState(() => selected = val!),
                          ),
                          Text('Morning ride'),
                          SizedBox(width: 24),
                          Radio<String>(
                            value: 'Evening ride',
                            groupValue: selected,
                            onChanged: (val) => setState(() => selected = val!),
                          ),
                          Text('Evening ride'),
                        ],
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            onSelected(selected);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff3E57B4),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Proceed', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold),),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  child: InkWell(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Color(0xff132235), // match your theme
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 5,
                                offset: const Offset(0, 2))
                          ]),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// --- New: Ride List Screen (used for both One Way and Round Trip) ---
class RideListScreen extends StatelessWidget {
  final String passType; // 'One way' or 'Round trip'
  final String? selectedTime; // 'Morning ride' or 'Evening ride' for One way
  const RideListScreen({super.key, required this.passType, this.selectedTime});

  @override
  Widget build(BuildContext context) {
    // Dummy data for rides
    final rides = [
      {'address': 'C95F+J2M, Manikonda Jagir, Hyderabad...', 'status': true},
      {'address': 'C95F+J2M, Manikonda Jagir, Hyderabad...', 'status': false},
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xff3E57B4)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          passType == 'One way' ? 'One way pass' : 'Round trip pass',
          style:
              TextStyle(color: Color(0xff3E57B4), fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Text('Swift',
                    style: TextStyle(
                        color: Color(0xff3E57B4), fontWeight: FontWeight.bold)),
                Icon(Icons.location_on, color: Color(0xff3E57B4)),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xffF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (passType == 'Round trip') ...[
              Text('Morning Ride',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...rides.map((ride) => _RideCard(ride: ride)).toList(),
              SizedBox(height: 16),
              Text('Evening Ride',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...rides.map((ride) => _RideCard(ride: ride)).toList(),
            ] else if (passType == 'One way' && selectedTime != null) ...[
              Text(selectedTime!,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...rides.map((ride) => _RideCard(ride: ride)).toList(),
            ],
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff3E57B4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Confirm Location',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _RideCard extends StatelessWidget {
  final Map ride;
  const _RideCard({required this.ride});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(Icons.circle,
            color: ride['status'] ? Colors.green : Colors.red, size: 16),
        title: Text(ride['address'], overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
