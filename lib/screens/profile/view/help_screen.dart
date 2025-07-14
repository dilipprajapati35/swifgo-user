import 'package:flutter/material.dart';
import 'package:flutter_arch/common/style/app_style.dart';
import 'package:flutter_arch/theme/colorTheme.dart';
import 'package:flutter_arch/common/app_assets.dart';
import 'package:flutter_arch/screens/profile/view/help_category_screen.dart';
import 'package:flutter_arch/screens/profile/view/safety_security_screen.dart';
import 'package:flutter_arch/screens/profile/view/services_screen.dart';
import 'package:flutter_arch/screens/profile/view/account_app_screen.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'icon': Icons.shield,
        'title': 'Safety & Security',
        'category': 'safety',
      },
      {
        'icon': Icons.directions_car,
        'title': 'Ride & Billing',
        'category': 'ride_billing',
      },
      {
        'icon': Icons.miscellaneous_services,
        'title': 'Services',
        'category': 'services',
      },
      {
        'icon': Icons.account_box,
        'title': 'Account & App',
        'category': 'account_app',
      },
    ];

    return Scaffold(
      backgroundColor: AppColor.greyShade7,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Help',
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
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Container(
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
                      leading: Icon(cat['icon'] as IconData, color: Color(0xFF2D5FFF), size: 28),
                      title: Text(
                        cat['title'] as String,
                        style: AppStyle.body.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColor.black,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFBDBDBD), size: 18),
                      onTap: () {
                        if (cat['category'] == 'safety') {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => SafetySecurityScreen()));
                        } else if (cat['category'] == 'services') {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ServicesScreen()));
                        } else if (cat['category'] == 'account_app') {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AccountAppScreen()));
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HelpCategoryScreen(
                                title: cat['title'] as String,
                                category: cat['category'] as String,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {},
                  child: Text(
                    'Refer now',
                    style: AppStyle.body.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 