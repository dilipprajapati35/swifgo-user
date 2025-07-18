import 'package:flutter/material.dart';
import 'package:flutter_arch/common/app_assets.dart';
import 'package:flutter_arch/common/snack_bar.dart';
import 'package:flutter_arch/screens/homepage/view/seat_selection.screen.dart';
import 'package:flutter_arch/screens/payment/view/kycNotCompleted.dart';
import 'package:flutter_arch/screens/payment/view/paymentSuccess.dart';
import 'package:flutter_arch/services/dio_http.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';


class PaymentScreen2 extends StatefulWidget {
  final List<SeatInfo> selectedSeats;
  final String scheduledTripId;
  final String pickupStopId;
  final String dropOffStopId;
  final bool isRoundTrip;
  final String? returnScheduledTripId;
  final String? returnPickupStopId;
  final String? returnDropOffStopId;
  final List<String>? returnSelectedSeatIds;
  final String price;

  const PaymentScreen2({
    super.key,
    required this.selectedSeats,
    required this.scheduledTripId,
    required this.pickupStopId,
    required this.dropOffStopId,
    this.isRoundTrip = false,
    this.returnScheduledTripId,
    this.returnPickupStopId,
    this.returnDropOffStopId,
    this.returnSelectedSeatIds,
    required this.price,
  });
  @override
  State<PaymentScreen2> createState() => _PaymentScreen2State();  
}

class _PaymentScreen2State extends State<PaymentScreen2> {
  PaymentOption _selectedOption = PaymentOption.swiftGo;
  bool _isProcessing = false;

  Future<void> _makeBooking() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final dioHttp = DioHttp();

      // Get selected seat IDs
      List<String> seatIds =
          widget.selectedSeats.map((seat) => seat.id).toList();

      // Determine payment method
      String paymentMethod;
      switch (_selectedOption) {
        case PaymentOption.cash:
          paymentMethod = "cash";
          break;
        default:
          paymentMethod = "cash";
      }

      print({
        "scheduledTripId": widget.scheduledTripId,
        "pickupStopId": widget.pickupStopId,
        "dropOffStopId": widget.dropOffStopId,
        "selectedSeatIds": seatIds,
        "isRoundTrip": widget.isRoundTrip,
        "returnScheduledTripId": widget.returnScheduledTripId,
        "returnPickupStopId": widget.returnPickupStopId,
        "returnDropOffStopId": widget.returnDropOffStopId,
        "returnSelectedSeatIds": widget.returnSelectedSeatIds,
      });

      await dioHttp.makeBooking(
        context,
        widget.scheduledTripId,
        widget.pickupStopId,
        widget.dropOffStopId,
        seatIds,
        paymentMethod,
        isRoundTrip: widget.isRoundTrip,
        returnScheduledTripId: widget.returnScheduledTripId,
        returnPickupStopId: widget.returnPickupStopId,
        returnDropOffStopId: widget.returnDropOffStopId,
        returnSelectedSeatIds: widget.isRoundTrip ? (widget.returnSelectedSeatIds ?? []) : null,
      );

      setState(() {
        _isProcessing = false;
      });

      // Navigate to success screen
      Navigator.pushReplacement( 
        context,
        MaterialPageRoute(builder: (context) => Paymentsuccess(
          price: widget.price,
        )),
      );
    } on DioException catch (e) {
      setState(() {
        _isProcessing = false;
      });
      print('DioException: ${e.message}');

      if (e.response!.data['error'] == 'KYC_REQUIRED') {
        print('KYC_REQUIRED');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Kycnotcompleted()),
        );
      } else {
        // Show snackbar for all other errors
        String errorMessage = 'Booking failed. Please try again.';
        if (e.response?.data != null && 
            e.response!.data is Map<String, dynamic> &&
            e.response!.data['message'] != null) {
          errorMessage = e.response!.data['message'];
        }
        print('Error: $errorMessage');
        MySnackBar.showSnackBar(context, errorMessage);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(),
            child: Image.asset('assets/images/snazzy-image (2) 1.png'),
          ),
          // SwiftGo logo positioned at top right
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Image.asset(
              AppAssets.logoSmall,
              height: 24,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: PaymentModeSheet(isRoundTrip: widget.isRoundTrip),
          ),
        ],
      ),
    );
  }
}

enum PaymentOption { swiftGo, phonePe, card, cash, promo }

class PaymentModeSheet extends StatefulWidget {
  final bool isRoundTrip;
  
  const PaymentModeSheet({
    super.key,
    this.isRoundTrip = false,
  });

  @override
  State<PaymentModeSheet> createState() => _PaymentModeSheetState();
}

class _PaymentModeSheetState extends State<PaymentModeSheet> {
  PaymentOption _selectedOption = PaymentOption.swiftGo;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(height: 24),

                  _buildSectionTitle('PERSONAL BALANCE'),
                  _buildOptionGroup(
                    children: [
                      _buildPaymentOption(
                        icon: Image.asset(
                          'assets/images/empty-wallet.png',
                          height: 24,
                          width: 24,
                        ),
                        iconColor: const Color(0xFF4A4DE8),
                        title: 'SwiftGo Balance',
                        trailing: Text(
                          '₹0.00',
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        value: PaymentOption.swiftGo,
                      ),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      _buildPaymentOption(
                        // Using a placeholder icon for PhonePe
                        icon: Image.asset(
                          'assets/images/Payment Icons.png',
                          height: 24,
                          width: 34,
                        ),
                        iconColor: const Color(0xFF6739B7),
                        title: 'PhonePe',
                        trailing: Text(
                          '₹150.00',
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        value: PaymentOption.phonePe,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- Debit & Credit Card Section ---
                  _buildSectionTitle('DEBIT & CREDIT CARD'),
                  _buildOptionGroup(
                    children: [
                      _buildPaymentOption(
                        // Using a placeholder icon for Mastercard
                        icon: Image.asset('assets/images/Mastercard.png'),
                        iconColor: Colors.redAccent,
                        title: '**** 0156',
                        value: PaymentOption.card,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '+ Add new card',
                    style: TextStyle(
                      color: Color(0xFF4A4DE8),
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Other Payment Methods Section ---
                  _buildSectionTitle('OTHER PAYMENT METHODS'),
                  _buildOptionGroup(
                    children: [
                      _buildPaymentOption(
                        icon: Image.asset('assets/images/moneys.png'),
                        iconColor: Colors.green,
                        title: 'Cash',
                        value: PaymentOption.cash,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- Promo Code Section ---
                  _buildSectionTitle('Promo code'),
                  _buildOptionGroup(
                    children: [
                      _buildPaymentOption(
                        title: 'RIDE@20%',
                        value: PaymentOption.promo,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  _buildConfirmButton(),
                  const SizedBox(height: 20), // For bottom safe area
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfirmButton() {
    // Get parent state to access the makeBooking method
    final parentState = context.findAncestorStateOfType<_PaymentScreen2State>();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Call the parent's _makeBooking method
          if (parentState != null) {
            parentState._makeBooking();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xff3E57B4),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Confirm',
          style: GoogleFonts.nunito(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.nunito(
          color: Color(0xff132235),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  // Helper widget to create the white, rounded-corner container for options
  Widget _buildOptionGroup({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Mode',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                text: 'Amount to be paid ',
                style: GoogleFonts.nunito(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '₹200',
                    style: GoogleFonts.nunito(
                      color: Color(0xFF3E57B4),
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.isRoundTrip) ...[
              const SizedBox(height: 4),
              Text(
                'Round Trip',
                style: GoogleFonts.nunito(
                  color: Color(0xFF3E57B4),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.black54),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    String title = '',
    Widget? icon,
    Color? iconColor,
    Widget? trailing,
    required PaymentOption value,
  }) {
    final bool isSelected = _selectedOption == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedOption = value;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (icon != null) icon,
            if (icon != null) const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (trailing != null) trailing,
            const SizedBox(width: 16),
            _buildCustomRadioButton(isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomRadioButton(bool isSelected) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xFF4A4DE8) : Colors.transparent,
        border: Border.all(
          color: isSelected ? const Color(0xFF4A4DE8) : Color(0xff94A3B3),
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, color: Colors.white, size: 16)
          : null,
    );
  }
}
