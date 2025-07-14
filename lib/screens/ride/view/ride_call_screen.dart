import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RideCallScreen extends StatelessWidget {
  const RideCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 40),
          CircleAvatar(
            radius: 56,
            backgroundColor: Colors.grey.shade200,
            child: Icon(Icons.person, color: Colors.blue, size: 64),
          ),
          SizedBox(height: 24),
          Text('Sergio Ramasis', style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          Text('Calling...', style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey)),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xffF2F2F2),
                  radius: 28,
                  child: Icon(Icons.camera_alt, color: Colors.grey, size: 28),
                ),
                CircleAvatar(
                  backgroundColor: Color(0xffF2F2F2),
                  radius: 28,
                  child: Icon(Icons.mic, color: Colors.grey, size: 28),
                ),
                CircleAvatar(
                  backgroundColor: Color(0xff3E57B4),
                  radius: 32,
                  child: Icon(Icons.call, color: Colors.white, size: 32),
                ),
                CircleAvatar(
                  backgroundColor: Color(0xffF2F2F2),
                  radius: 28,
                  child: Icon(Icons.insert_drive_file, color: Colors.grey, size: 28),
                ),
                CircleAvatar(
                  backgroundColor: Color(0xffF2F2F2),
                  radius: 28,
                  child: Icon(Icons.more_horiz, color: Colors.grey, size: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 