import 'package:flutter/material.dart';
import 'package:flutter_arch/common/style/app_style.dart';
import 'package:flutter_arch/screens/ride/view/myride.dart';
import 'package:flutter_arch/theme/colorTheme.dart';
import 'package:flutter_arch/screens/Auth/view/intro_screen.dart';
import 'package:flutter_arch/storage/flutter_secure_storage.dart';
import 'package:flutter_arch/common/app_assets.dart';
import 'package:flutter_arch/services/dio_http.dart';
import 'package:flutter_arch/screens/profile/model/user_model.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:flutter_arch/screens/profile/view/help_screen.dart';
import 'package:flutter_arch/screens/profile/view/ratings_screen.dart';
import 'package:flutter_arch/screens/profile/view/safety_screen.dart';
import 'package:flutter_arch/screens/profile/view/terms_conditions_screen.dart';
import 'package:flutter_arch/screens/profile/view/about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      final userInfo = await DioHttp().getUserInfo(context);
      setState(() {
        user = userInfo;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.greyShade7,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                 
                  Text(
                    'Settings',
                    style: AppStyle.title.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Image.asset(
                    AppAssets.logoSmall,
                    height: 28,
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(0, 2),
                                  blurRadius: 8,
                                  color: Colors.black.withOpacity(0.06),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor: AppColor.buttonColor.withOpacity(0.1),
                                  backgroundImage: user?.profilePhotoUrl != null
                                      ? NetworkImage(user!.profilePhotoUrl!)
                                      : AssetImage('assets/images/avatar.png') as ImageProvider,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user?.fullName ?? '-',
                                        style: AppStyle.title.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        user?.email ?? user?.mobileNumber ?? '-',
                                        style: AppStyle.body.copyWith(
                                          color: AppColor.greyShade3,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Menu Items
                          _buildMenuItem(
                            context,
                            icon: Icons.star,
                            iconColor: Color(0xFF2D5FFF),
                            title: 'Ratings',
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => RatingsScreen()));
                            },
                          ),
                          _buildMenuItem(
                            context,
                            icon: Icons.directions_car,
                            iconColor: Color(0xFF2D5FFF),
                            title: 'My Rides',
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Myride()));
                            },
                          ),
                          _buildMenuItem(
                            context,
                            icon: Icons.shield,
                            iconColor: Color(0xFF2D5FFF),
                            title: 'Safety',
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SafetyScreen()));
                            },
                          ),
                          const SizedBox(height: 8),
                          _buildMenuItem(
                            context,
                            icon: Icons.help_outline,
                            iconColor: Color(0xFF2D5FFF),
                            title: 'Help',
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => HelpScreen()));
                            },
                          ),
                          _buildMenuItem(
                            context,
                            icon: Icons.description_outlined,
                            iconColor: Color(0xFF2D5FFF),
                            title: 'Terms & Conditions',
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => TermsConditionsScreen()));
                            },
                          ),
                          _buildMenuItem(
                            context,
                            icon: Icons.info_outline,
                            iconColor: Color(0xFF2D5FFF),
                            title: 'About',
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AboutScreen()));
                            },
                          ),
                          const SizedBox(height: 20),
                          // Sign out button
                          GestureDetector(
                            onTap: () async {
                              await MySecureStorage().deleteToken();
                              IntroScreen().launch(context, isNewTask: true);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Color(0xFFF44336).withOpacity(0.15)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout, color: Color(0xFFF44336)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Sign out',
                                    style: AppStyle.body.copyWith(
                                      color: Color(0xFFF44336),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required Color iconColor, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 8,
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
        title: Text(
          title,
          style: AppStyle.body.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColor.black,  
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppColor.greyShade3,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
} 