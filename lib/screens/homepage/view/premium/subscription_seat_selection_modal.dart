import 'package:flutter/material.dart';
import 'package:flutter_arch/screens/homepage/model/tripModel.dart';
import 'package:flutter_arch/screens/homepage/view/seat_selection.screen.dart';
import 'package:flutter_arch/screens/homepage/view/premium/subscription_confirm_ride_screen.dart';

class SubscriptionSeatSelectionModal {
  static void show(BuildContext context, {
    required TripModel onwardTrip,
    TripModel? returnTrip,
    bool isRoundTrip = false,
    required String planId,
    required String commuteType,
  }) {
    BookSeatModal seatModal = BookSeatModal(
      onBookNow: (onwardSeats) {
        if (onwardSeats.isEmpty) {
          // Show error
          return;
        }
        if (isRoundTrip && returnTrip != null) {
          // Show return seat selection
          BookSeatModal returnSeatModal = BookSeatModal(
            onBookNow: (returnSeats) {
              if (returnSeats.isEmpty) {
                // Show error
                return;
              }
              // Proceed to confirm ride screen with both selections
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => SubscriptionConfirmRideScreen(
                    onwardTrip: onwardTrip,
                    onwardSeats: onwardSeats,
                    returnTrip: returnTrip,
                    returnSeats: returnSeats,
                    planId: planId,
                    commuteType: commuteType,
                  ),
                ),
              );
            },
          );
          returnSeatModal.show(
            context,
            routeId: returnTrip.scheduledTripId,
            pickupId: returnTrip.pickupStopId,
            dropoffId: returnTrip.destinationStopId,
            pickupAddress: returnTrip.pickupLocationName,
            destinationAddress: returnTrip.destinationLocationName,
            price: "₹${returnTrip.price}",
            isRoundTrip: true,
          );
        } else {
          // Proceed to confirm ride screen with onward selection only
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => SubscriptionConfirmRideScreen(
                onwardTrip: onwardTrip,
                onwardSeats: onwardSeats,
                planId: planId,
                commuteType: commuteType,
              ),
            ),
          );
        }
      },
    );
    seatModal.show(
      context,
      routeId: onwardTrip.scheduledTripId,
      pickupId: onwardTrip.pickupStopId,
      dropoffId: onwardTrip.destinationStopId,
      pickupAddress: onwardTrip.pickupLocationName,
      destinationAddress: onwardTrip.destinationLocationName,
      price: "₹${onwardTrip.price}",
      isRoundTrip: isRoundTrip,
    );
  }
} 