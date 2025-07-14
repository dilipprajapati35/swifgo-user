import 'package:flutter/material.dart';
import 'package:flutter_arch/common/style/app_style.dart';
import 'package:flutter_arch/theme/colorTheme.dart';
import 'package:flutter_arch/common/app_assets.dart';

class HelpQuestionScreen extends StatefulWidget {
  final String question;
  final String answer;
  const HelpQuestionScreen({super.key, required this.question, required this.answer});

  @override
  State<HelpQuestionScreen> createState() => _HelpQuestionScreenState();
}

class _HelpQuestionScreenState extends State<HelpQuestionScreen> {
  bool? wasUseful; // null = not answered, true = yes, false = no

  @override
  Widget build(BuildContext context) {
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
                    'Back',
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
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.question.toUpperCase(),
                      style: AppStyle.caption1w600.copyWith(
                        color: AppColor.greyShade1,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.answer,
                      style: AppStyle.body.copyWith(
                        color: AppColor.greyShade1,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Was this information useful ?',
                      style: AppStyle.body.copyWith(
                        color: AppColor.greyShade1,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => wasUseful = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: wasUseful == true ? Color(0xFFE8F0FE) : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: wasUseful == true ? Color(0xFF2D5FFF) : Color(0xFFF2F2F2),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.thumb_up, color: wasUseful == true ? Color(0xFF2D5FFF) : AppColor.greyShade3),
                                  const SizedBox(height: 4),
                                  Text('Yes', style: AppStyle.body.copyWith(
                                    color: wasUseful == true ? Color(0xFF2D5FFF) : AppColor.greyShade3,
                                    fontWeight: FontWeight.w600,
                                  )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => wasUseful = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: wasUseful == false ? Color(0xFFFFEBEE) : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: wasUseful == false ? Color(0xFFF44336) : Color(0xFFF2F2F2),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.thumb_down, color: wasUseful == false ? Color(0xFFF44336) : AppColor.greyShade3),
                                  const SizedBox(height: 4),
                                  Text('No', style: AppStyle.body.copyWith(
                                    color: wasUseful == false ? Color(0xFFF44336) : AppColor.greyShade3,
                                    fontWeight: FontWeight.w600,
                                  )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 