import 'package:flutter/material.dart';
import 'package:flutter_arch/common/app_assets.dart';
import 'package:flutter_arch/common/style/app_style.dart';
import 'package:flutter_arch/screens/homepage/view/homepage.screen.dart';
import 'package:flutter_arch/screens/ride/view/myride.dart';
import 'package:flutter_arch/screens/swift_pass/view/swift_pass_screen.dart';
import 'package:flutter_arch/screens/profile/view/profile_screen.dart';
import 'package:flutter_arch/theme/colorTheme.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomePage(),
    const Myride(),
    const SwiftPassScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -2),
              blurRadius: 8,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, 'Home', Icons.home_outlined, Icons.home),
                _buildNavItem(1, 'My Ride', Icons.receipt_outlined, Icons.receipt),
                _buildNavItem(2, 'Swift Pass', Icons.card_membership_outlined, Icons.card_membership),
                _buildNavItem(3, 'Profile', Icons.person_outline, Icons.person),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon, IconData activeIcon) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? AppColor.buttonColor : AppColor.greyShade3,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppStyle.caption1w400.copyWith(
              color: isSelected ? AppColor.buttonColor : AppColor.greyShade3,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
} 