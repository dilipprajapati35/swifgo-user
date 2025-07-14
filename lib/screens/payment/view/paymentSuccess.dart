import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arch/screens/payment/view/Excellent.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

class Paymentsuccess extends StatelessWidget {
  const Paymentsuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: Center(
        child: Container(
          height: 547,
          width: 361,
          
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white
            ),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 45,),
                  Image.asset('assets/images/Group 6477.png'),
                  SizedBox(height: 23),
                  Text(
                    'Payment Success',
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 7,),
                  Text(
                    'Your money has been successfully sent to \nSergio Ramasis',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff898989),
                    ),
                  ),
                  SizedBox(height: 24,),
                  Text(
                    'Amount',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff5A5A5A),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text(
                    '₹500',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 34,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff2A2A2A),
                    ),
                  ),
                  SizedBox(height: 10,),
                  DottedDashedLine(height: 0,width: double.infinity, axis: Axis.horizontal,dashColor: Color(0xffb8b8b8)),
                  SizedBox(height: 20,),
                  Text(
                    'How is your trip?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff5A5A5A),
                    ),
                  ),
                  SizedBox(height: 8,),
                  Text(
                    'Youe feedback will help us to improve your \ndriving experience better',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xffA0A0A0),
                    ),
                  ),
                  SizedBox(height: 30,),
                  ElevatedButton(
                    onPressed: (){
                      FeedbackScreen().launch(context);
                    }, 
                    
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(334, 54),
                      backgroundColor: Color(0xff3E57B4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                        
                      )
                    ),
                    child: Text(
                    'Give feedback',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xffffffff),
                    ),
                  ),),
                  SizedBox(height: 14,),
                ],
                            ),
              ),
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Icon(Icons.close,color: Colors.black,),
              )
              )
            ]
          ),
        ),
      ),
    );
  }
}
