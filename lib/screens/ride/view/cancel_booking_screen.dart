import 'package:flutter/material.dart';
import 'package:flutter_arch/screens/homepage/view/homepage.screen.dart';
import 'package:flutter_arch/screens/main_navigation/main_navigation.dart';
import 'package:flutter_arch/services/dio_http.dart';
import 'package:google_fonts/google_fonts.dart';

class CancelBookingScreen extends StatefulWidget {
  final String bookingId;
  final VoidCallback? onSuccess;
  const CancelBookingScreen({super.key, required this.bookingId, this.onSuccess});

  @override
  State<CancelBookingScreen> createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends State<CancelBookingScreen> {
  int? _selectedReasonIndex = 0;
  final TextEditingController _otherController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _reasons = [
    'Waiting for long time',
    'Unable to contact driver',
    'Other',
  ];

  String get _selectedReason {
    if (_selectedReasonIndex == 2) {
      return _otherController.text.trim().isNotEmpty
          ? _otherController.text.trim()
          : 'other';
    }
    if (_selectedReasonIndex == 0) return 'waiting_too_long';
    if (_selectedReasonIndex == 1) return 'unable_to_contact_driver';
    return 'other';
  }

  void _submit() async {
    if (_selectedReasonIndex == 2 && _otherController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a reason.')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await DioHttp().cancelBooking(context, widget.bookingId, _selectedReason);
      setState(() => _isSubmitting = false);
      _showSuccessModal();
      if (widget.onSuccess != null) widget.onSuccess!();
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel booking.')),
      );
    }
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(ctx).popUntil((route) => route.isFirst),
                  child: Icon(Icons.close, size: 28, color: Colors.grey[600]),
                ),
              ),
              SizedBox(height: 8),
              Text('😓', style: TextStyle(fontSize: 64)),
              SizedBox(height: 16),
              Text(
                "We're so sad about your cancellation",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 12),
              Text(
                'We will continue to improve our service & satisfy you on the next trip.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => MainNavigation()),
                    (route) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff3E57B4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Back Home', style: GoogleFonts.nunito(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Cancel Taxi', style: GoogleFonts.nunito(color: Colors.black, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Center(
              child: Text(
                'Please select the reason of cancellation.',
                style: GoogleFonts.nunito(fontSize: 15, color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 24),
            ...List.generate(_reasons.length, (i) {
              if (i < 2) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => setState(() => _selectedReasonIndex = i),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedReasonIndex == i ? Color(0xff3E57B4) : Colors.grey[300]!,
                          width: 1.5,
                        ),
                        color: _selectedReasonIndex == i ? Color(0xffF2F6FF) : Colors.white,
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _selectedReasonIndex == i,
                            onChanged: (_) => setState(() => _selectedReasonIndex = i),
                            activeColor: Color(0xff3E57B4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          ),
                          Text(_reasons[i], style: GoogleFonts.nunito(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: _otherController,
                    onTap: () => setState(() => _selectedReasonIndex = i),
                    decoration: InputDecoration(
                      hintText: 'Other',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Color(0xff3E57B4)),
                      ),
                    ),
                    minLines: 2,
                    maxLines: 3,
                  ),
                );
              }
            }),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff3E57B4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Submit', style: GoogleFonts.nunito(fontSize: 17, color: Colors.white)),
              ),
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
} 