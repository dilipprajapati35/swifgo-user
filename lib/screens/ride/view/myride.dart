import 'package:flutter/material.dart';
import 'package:flutter_arch/screens/ride/view/cancelled.dart';
import 'package:flutter_arch/screens/ride/view/completed.dart';
import 'package:flutter_arch/screens/ride/view/upcoming.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_arch/screens/ride/provider/rideProvider.dart';

class Myride extends StatelessWidget {
  const Myride({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RideProvider>(
      create: (_) => RideProvider(),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TabBarView(
              children: [
                Upcoming(),
                Completed(),
                Cancelled(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text('My Ride', style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 20)),
      actions: [
        IconButton(onPressed: () {}, icon: Image.asset('assets/images/Group 1707479418.png')),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: _buildTabBar(),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: Color(0xff3E57B4),
          borderRadius: BorderRadius.circular(30),
        ),
        labelColor: Colors.white,
        labelPadding: EdgeInsets.all(10),
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: [
          Text('Upcoming'),
          Text('Completed'),
          Text('Cancelled'),
        ],
      ),
    );
  }
}