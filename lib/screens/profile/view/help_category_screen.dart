import 'package:flutter/material.dart';
import 'package:flutter_arch/common/style/app_style.dart';
import 'package:flutter_arch/theme/colorTheme.dart';
import 'package:flutter_arch/common/app_assets.dart';
import 'package:flutter_arch/screens/profile/view/help_question_screen.dart';

class HelpCategoryScreen extends StatelessWidget {
  final String title;
  final String category;
  const HelpCategoryScreen({super.key, required this.title, required this.category});

  @override
  Widget build(BuildContext context) {
    // Example questions for Ride & Billing
    final questions = <String, List<Map<String, String>>>{
      'ride_billing': [
        {'q': 'How I can check the fare for a ride?', 'a': 'You may enter the pickup/drop location and check estimated total fare for your ride. Note - The pricing for a GoChauffeur ride is susceptible to vary depending on the time of booking, location and the availability of our Drivers.'},
        {'q': 'How can I check the fare breakup for the ride?', 'a': 'Fare breakup details...'},
        {'q': 'How do I apply coupon code for a ride?', 'a': 'Coupon code details...'},
        {'q': 'Where can I find my Driver details?', 'a': 'Driver details info...'},
        {'q': 'How can I contact my Driver?', 'a': 'Contact driver info...'},
        {'q': 'How do ETA\'s work?', 'a': 'ETA info...'},
        {'q': 'How do I use PIN to start my ride?', 'a': 'PIN info...'},
        {'q': 'How can I tip my Driver?', 'a': 'Tip info...'},
        {'q': 'How to receive invoice in my email?', 'a': 'Invoice info...'},
        {'q': 'I want to understand the charges in the invoice', 'a': 'Invoice charges info...'},
      ],
      'safety': [
        {'q': 'How do I report a safety issue?', 'a': 'Safety issue info...'},
        {'q': 'What safety features are available?', 'a': 'Safety features info...'},
      ],
      'services': [
        {'q': 'What services are available?', 'a': 'Services info...'},
      ],
      'account_app': [
        {'q': 'How do I reset my password?', 'a': 'Reset password info...'},
      ],
    };
    final qList = questions[category] ?? [];

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
                    title,
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
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: qList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF2F2F2)),
                  itemBuilder: (context, index) {
                    final q = qList[index];
                    return ListTile(
                      title: Text(
                        q['q']!,
                        style: AppStyle.body.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColor.black,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFBDBDBD), size: 18),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HelpQuestionScreen(
                              question: q['q']!,
                              answer: q['a']!,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 