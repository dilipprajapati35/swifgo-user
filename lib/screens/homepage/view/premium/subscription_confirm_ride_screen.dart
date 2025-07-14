import 'package:flutter/material.dart';
import 'package:flutter_arch/screens/homepage/model/tripModel.dart';
import 'package:flutter_arch/screens/homepage/view/seat_selection.screen.dart';
import 'package:flutter_arch/screens/payment/view/paymentScreen2.dart';
import 'package:flutter_arch/screens/homepage/view/premium/subscription_payment_screen.dart';
import 'package:flutter_arch/services/dio_http.dart';

class SubscriptionConfirmRideScreen extends StatelessWidget {
  final TripModel onwardTrip;
  final List<SeatInfo> onwardSeats;
  final TripModel? returnTrip;
  final List<SeatInfo>? returnSeats;
  final String planId;
  final String commuteType;

  const SubscriptionConfirmRideScreen({
    super.key,
    required this.onwardTrip,
    required this.onwardSeats,
    this.returnTrip,
    this.returnSeats,
    required this.planId,
    required this.commuteType,
  });

  void _onPayNow(BuildContext context) async {
    // Navigate to the new subscription payment screen, passing all info
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => SubscriptionPaymentScreen(
          onwardTrip: onwardTrip,
          onwardSeats: onwardSeats,
          returnTrip: returnTrip,
          returnSeats: returnSeats,
          planId: planId,
          commuteType: commuteType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = returnTrip != null ? (onwardTrip.price + returnTrip!.price) : onwardTrip.price;
    return Scaffold(
      appBar: AppBar(title: Text('Confirm Ride')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Onward Trip: ${onwardTrip.routeName}'),
            Text('Seats: ${onwardSeats.map((s) => s.label).join(", ")}'),
            if (returnTrip != null && returnSeats != null) ...[
              SizedBox(height: 16),
              Text('Return Trip: ${returnTrip!.routeName}'),
              Text('Seats: ${returnSeats!.map((s) => s.label).join(", ")}'),
            ],
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _onPayNow(context),
                child: Text('Pay ₹$totalPrice'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 