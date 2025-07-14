import 'package:flutter/material.dart';
import 'package:flutter_arch/common/button/commonbutton.dart';
import 'package:google_fonts/google_fonts.dart';

class Thankyou extends StatelessWidget {
  const Thankyou({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.only(top: 15, bottom: 15, left: 5, right: 5),
          margin: EdgeInsets.all(40),
          height: 310,
          width: 310,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [Icon(Icons.close)],
              ),
              Image.asset('assets/images/thankyou.png'),
              SizedBox(height: 10),
              Text(
                "Thank you",
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2A2A2A),
                ),
              ),
              Text(
                textAlign: TextAlign.center,
                "Thank you for your valuable feedback and tip",
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF898989),
                ),
              ),
              Spacer(),
              CommonButton(context, 'Back Home'),
            ],
          ),
        ),
      ),
    );
  }
}
