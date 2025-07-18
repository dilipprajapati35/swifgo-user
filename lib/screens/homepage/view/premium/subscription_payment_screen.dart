import 'package:flutter/material.dart';
import 'package:flutter_arch/screens/homepage/model/tripModel.dart';
import 'package:flutter_arch/screens/homepage/view/seat_selection.screen.dart';
import 'package:flutter_arch/services/dio_http.dart';

class SubscriptionPaymentScreen extends StatefulWidget {
  final TripModel onwardTrip;
  final List<SeatInfo> onwardSeats;
  final TripModel? returnTrip;
  final List<SeatInfo>? returnSeats;
  final String planId;
  final String commuteType;

  const SubscriptionPaymentScreen({
    super.key,
    required this.onwardTrip,
    required this.onwardSeats,
    this.returnTrip,
    this.returnSeats,
    required this.planId,
    required this.commuteType,
  });

  @override
  State<SubscriptionPaymentScreen> createState() => _SubscriptionPaymentScreenState();
}

class _SubscriptionPaymentScreenState extends State<SubscriptionPaymentScreen> {
  bool _isLoading = false;
  String? _resultMessage;

  Future<void> _handlePayment() async {
    setState(() { _isLoading = true; _resultMessage = null; });
    try {
      final dioHttp = DioHttp();
      // 1. Book the ride first
      await dioHttp.makeBooking(
        context,
        widget.onwardTrip.scheduledTripId,
        widget.onwardTrip.pickupStopId,
        widget.onwardTrip.destinationStopId,
        widget.onwardSeats.map((s) => s.id).toList(),
        "cash", // or your payment method
        isRoundTrip: widget.returnTrip != null,
        returnScheduledTripId: widget.returnTrip?.scheduledTripId,
        returnPickupStopId: widget.returnTrip?.pickupStopId,
        returnDropOffStopId: widget.returnTrip?.destinationStopId,
        returnSelectedSeatIds: widget.returnSeats?.map((s) => s.id).toList(),
      );
      // 2. Subscribe to plan if booking is successful
      await dioHttp.subscribeToPlan(
        context,
        widget.planId,
        pickupStopId: widget.onwardTrip.pickupStopId,
        dropOffStopId: widget.onwardTrip.destinationStopId,
        commuteType: widget.commuteType,
        returnPickupStopId: widget.returnTrip?.pickupStopId,
        returnDropoffStopId: widget.returnTrip?.destinationStopId,
      );
      setState(() { _isLoading = false; _resultMessage = 'Booking and subscription successful!'; });
      // Optionally, pop to root or show a success screen
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    } catch (e) {
      setState(() { _isLoading = false; _resultMessage = 'Booking or subscription failed. Please try again.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.returnTrip != null ? (widget.onwardTrip.price + widget.returnTrip!.price) : widget.onwardTrip.price;
    return Scaffold(
      appBar: AppBar(title: Text('Subscription Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Onward Trip: ${widget.onwardTrip.routeName}'),
            Text('Seats: ${widget.onwardSeats.map((s) => s.label).join(", ")}'),
            if (widget.returnTrip != null && widget.returnSeats != null) ...[
              SizedBox(height: 16),
              Text('Return Trip: ${widget.returnTrip!.routeName}'),
              Text('Seats: ${widget.returnSeats!.map((s) => s.label).join(", ")}'),
            ],
            Spacer(),
            if (_isLoading)
              Center(child: CircularProgressIndicator()),
            if (_resultMessage != null)
              Center(child: Text(_resultMessage!, style: TextStyle(color: _resultMessage!.contains('success') ? Colors.green : Colors.red))),
            if (!_isLoading && _resultMessage == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handlePayment,
                  child: Text('Pay ₹$totalPrice'),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 