import 'package:flutter/material.dart';
import 'package:flutter_arch/screens/homepage/model/subscriptionPlanModel.dart';
import 'package:flutter_arch/screens/homepage/view/premium/getPremium.dart';
import 'package:flutter_arch/services/dio_http.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_arch/screens/homepage/view/premium/subscription_location_picker.dart';
import 'package:flutter_arch/screens/homepage/view/premium/subscription_slot_selection.dart';
import 'package:flutter_arch/common/enums/trip_type.dart';
import 'package:flutter_arch/screens/homepage/view/premium/subscription_trip_selection_screen.dart';

class OneWay extends StatefulWidget {
  const OneWay({super.key});

  @override
  State<OneWay> createState() => _OneWayState();
}

class _OneWayState extends State<OneWay> {
  List<SubscriptionPlanModel> _plans = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedPlanId;
  bool _isSubscribing = false;

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionPlans();
  }

  Future<void> _fetchSubscriptionPlans() async {
    try {
      final dioHttp = DioHttp();
      final plans = await dioHttp.getSubscriptionPlans(context);
      final activePlans = plans.where((plan) => plan.isActive).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      setState(() {
        _plans = activePlans;
        _isLoading = false;
        if (_plans.isNotEmpty) {
          _selectedPlanId = _plans.first.id;
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load subscription plans';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSubscribe(String commuteType) async {
    if (_selectedPlanId == null) return;
    setState(() => _isSubscribing = true);
    try {
      // 1. Navigate to location picker
      final locationResult = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => SubscriptionLocationPickerPage(tripType: TripType.oneWay),
        ),
      );
      if (locationResult == null || locationResult['pickupLatLng'] == null || locationResult['destinationLatLng'] == null || locationResult['subscriptionStartDate'] == null) {
        setState(() => _isSubscribing = false);
        return;
      }
      final pickupLatLng = locationResult['pickupLatLng'];
      final destinationLatLng = locationResult['destinationLatLng'];
      final subscriptionStartDate = locationResult['subscriptionStartDate'];
      // 2. Navigate to SubscriptionTripSelectionScreen
      setState(() => _isSubscribing = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => SubscriptionTripSelectionScreen(
            pickupLatLng: pickupLatLng,
            destinationLatLng: destinationLatLng,
            selectedDate: subscriptionStartDate.split('T')[0],
            selectedTimePeriod: DateTime.parse(subscriptionStartDate).hour < 12 ? 'AM' : 'PM',
            isRoundTrip: false,
            planId: _selectedPlanId!,
          ),
        ),
      );
    } catch (e) {
      setState(() => _isSubscribing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subscription failed. Please try again.'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _featureCard(IconData icon, String line1, String line2, {Color? iconColor}) {
    return Card(
      color: const Color(0xff2C2C2E),
      child: Container(
        height: 110,
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          gradient: LinearGradient(
            colors: [Color.fromRGBO(18, 18, 18, 1), Color.fromRGBO(68, 68, 68, 0)],
          ),
          boxShadow: [BoxShadow(blurRadius: 0)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor ?? Colors.blueAccent.shade700),
            const SizedBox(height: 6),
            Text(line1, style: GoogleFonts.nunito(color: Colors.white)),
            Text(line2, style: GoogleFonts.nunito(color: Colors.blueAccent.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Card(
      color: const Color(0xff2C2C2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          gradient: LinearGradient(
            colors: [Color.fromRGBO(18, 18, 18, 1), Color.fromRGBO(68, 68, 68, 0)],
          ),
          boxShadow: [BoxShadow(blurRadius: 0)],
        ),
        child: Row(
          children: [
            Icon(Icons.currency_rupee, color: Colors.blueAccent.shade700),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Free rescheduling to any day, time or get a full refund on cancellation',
                style: GoogleFonts.nunito(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _featureCard(Icons.verified, 'Bigger', 'Saving'),
                _featureCard(Icons.calendar_today, 'Pre-book days of', 'your choice'),
              ],
            ),
            const SizedBox(height: 10),
            _infoCard(),
            const SizedBox(height: 30),
            Text('50% OFF', style: GoogleFonts.nunito(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Get this exclusive limited offer!', style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
            const SizedBox(height: 35),
            if (_isLoading)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(2, (index) => Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Container(
                      height: 110,
                      width: 170,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2),
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.blueAccent, strokeWidth: 2),
                      ),
                    ),
                  )),
                ),
              )
            else if (_error != null || _plans.isEmpty)
              Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(_error ?? 'No subscription plans available', style: GoogleFonts.nunito(color: Colors.white), textAlign: TextAlign.center),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _plans.take(2).map((plan) {
                    final isHighlighted = plan.trialDays > 0;
                    final isSelected = plan.id == _selectedPlanId;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPlanId = plan.id),
                        child: _buildSubscriptionCard(plan, isHighlighted, isSelected),
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: (_selectedPlanId != null && !_isSubscribing)
                  ? () async {
                      await showRideSelectionModal(context, (selected) async {
                        await _handleSubscribe(selected == 'Morning ride' ? 'morning' : 'evening');
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: _isSubscribing
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('TRY 7 DAYS AND SUBSCRIBE', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(SubscriptionPlanModel plan, bool isHighlighted, bool isSelected) {
    String title = plan.name;
    if (title.contains('(')) {
      title = title.split('(')[0].trim();
    }
    String price = '₹${plan.price}';
    String rides = '${plan.ridesIncluded} Rides';
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 110,
            width: 170,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? Colors.blueAccent
                    : (isHighlighted ? Colors.blue.shade700 : Colors.grey),
                width: isSelected ? 3 : 2,
              ),
              color: isSelected ? Colors.blueAccent.withOpacity(0.1) : Colors.black,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rides,
                    style: GoogleFonts.nunito(
                      color: isHighlighted ? Colors.blueAccent : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    price,
                    style: GoogleFonts.nunito(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          if (isHighlighted) ...[
            Positioned(
              top: -12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text(
                    '${plan.trialDays}-day free trial',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
} 