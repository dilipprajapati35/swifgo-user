import 'package:flutter/material.dart';
import 'package:flutter_arch/screens/payment/view/thankyou.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final List<int> tipAmounts = [1, 2, 5, 10, 20];
  int selectedTip = 2; // Default selected tip
  final TextEditingController feedbackController = TextEditingController();

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top bar with close icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24), // Spacer for alignment
                  Container(
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Icon(Icons.close, color: Colors.grey.shade600),
                ],
              ),

              const SizedBox(height: 20),

              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return const Icon(
                    Icons.star,
                    color: Color(0xFF3E57B4),
                    size: 30,
                  );
                }),
              ),

              const SizedBox(height: 16),

              // Excellent
              Text(
                'Excellent',
                style: GoogleFonts.nunito(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2A2A2A),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'You rated Sergio Ramasis 4 star',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFB8B8B8),
                ),
              ),

              const SizedBox(height: 16),

              // Feedback TextField
              TextField(
                controller: feedbackController,
                maxLines: 4,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFB8B8B8)),
                  ),
                  hintText: 'Write your text',
                  hintStyle: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFB8B8B8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFB8B8B8)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tip Title
              Text(
                'Give some tips to Sergio Ramasis',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF5A5A5A),
                ),
              ),

              const SizedBox(height: 12),

              // Tip Amount Row
              Row(
                children: tipAmounts.map((amount) {
                  final bool isSelected = amount == selectedTip;
                  return Flexible(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTip = amount;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? const Color(0xFF3E57B4).withOpacity(0.1)
                              : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF3E57B4)
                                : Colors.grey.shade400,
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            '₹$amount',
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF3E57B4)
                                  : const Color(0xFF5A5A5A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 10),

              const Text(
                'Enter other amount',
                style: TextStyle(color: Color(0xFF3E57B4), fontSize: 12),
              ),

              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E57B4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Thankyou().launch(context);
                  },
                  child: Text(
                    "Submit",
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
