import 'package:flutter/material.dart';
import 'package:flutter_arch/common/style/app_style.dart';
import 'package:flutter_arch/theme/colorTheme.dart';

class SwiftPassScreen extends StatelessWidget {
  const SwiftPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.greyShade7,
      appBar: AppBar(
        title: Text(
          'Swift Pass',
          style: AppStyle.title.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Swift Pass',
                style: AppStyle.title.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.card_membership,
                      size: 48,
                      color: AppColor.buttonColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Swift Pass Coming Soon',
                      style: AppStyle.title.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Get exclusive benefits and discounts with Swift Pass membership.',
                      style: AppStyle.body.copyWith(
                        color: AppColor.greyShade3,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 