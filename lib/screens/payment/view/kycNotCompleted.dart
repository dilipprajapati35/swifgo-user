import 'package:flutter/material.dart';
import 'package:flutter_arch/screens/Auth/view/completeyourkyc_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

class Kycnotcompleted extends StatelessWidget {
  const Kycnotcompleted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Stack(
          children: [
            Container(
              height: 355,
              width: 361,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/warning 1.png'),
                    SizedBox(height: 15),
                    Text(
                      'KYC not completed',
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff2A2A2A),
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Your account verification is pending.\nTo access all features, please complete your KYC.',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        color: Color(0xff898989),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 36),
                    ElevatedButton(
                      onPressed: () {
                        Complete_Kyc_Screen().launch(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff3E57B4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        fixedSize: Size(340, 54),
                      ),
                      child: Text(
                        'Complete KYC Now',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Icon(Icons.close,color: Colors.black,),
              )
              )
          ],
        ),
      ),
    );
  }
}
