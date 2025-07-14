import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_arch/common/app_assets.dart';
import 'package:flutter_arch/common/app_primary_button.dart';
import 'package:flutter_arch/common/style/app_style.dart';
import 'package:flutter_arch/screens/Auth/view/completeyourkyc_screen.dart';
// import 'package:flutter_arch/screens/Auth/view/completeyourkyc_screen.dart';
import 'package:flutter_arch/theme/colorTheme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'dart:ui' as ui;

class SelfieUploadScreen extends StatefulWidget {
  const SelfieUploadScreen({super.key});

  @override
  State<SelfieUploadScreen> createState() => _SelfieUploadScreenState();
}

class _SelfieUploadScreenState extends State<SelfieUploadScreen> {
  File? _image;
  late final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      setState(() {
        _image = File(file.path);
      });
    }
  }

  void _onContinue() {
    // if (_image == null) {
    //   toast('Please upload a selfie before continuing.');
    //   return;
    // }
    Navigator.push(context, MaterialPageRoute(builder: (context) => Complete_Kyc_Screen()));
  }

  Widget _buildHeader() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.arrow_back, size: 28).onTap(() => Navigator.pop(context)),
          Image.asset(AppAssets.logoSmall, height: 32),
        ],
      ).paddingSymmetric(horizontal: 16);

  Widget _buildTitle() => Text('Take a Selfie', style: AppStyle.title).paddingSymmetric(horizontal: 16);

  Widget _buildSubtitle() => Text(
        'This helps personalize your experience. Make sure your face is clearly visible!',
        style: AppStyle.subheading,
      ).paddingSymmetric(horizontal: 16);

  Widget _buildSelfieArea() {
    final double width = context.width() - 120;
    final double height = context.height() * 0.35;
    return Center(
      child: CustomPaint(
        size: Size(width, height),
        painter: DottedOvalPainter(color: const Color(0xFFE5E5E5), dotRadius: 3, spacing: 10),
        child: _image == null
            ? SizedBox(
                height: height,
                width: width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.videocam_outlined, color: AppColor.buttonColor, size: 32),
                    8.height,
                    Text('Upload Photo', style: AppStyle.body.copyWith(color: AppColor.buttonColor)),
                  ],
                ),
              )
            : ClipOval(
                child: Image.file(_image!, fit: BoxFit.cover, width: width, height: height),
              ),
      ),
    ).onTap(_pickImage);
  }

  Widget _buildPrivacyNote() => Center(
        child: Text(
          'Your photo is only used for profile identification and is kept private',
          style: AppStyle.caption1w400.copyWith(
            color: AppColor.greyShade2,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
            height: 18 / 10,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ).paddingSymmetric(horizontal: 16),
      );

  Widget _buildContinueButton() => AppPrimaryButton(
        text: 'Continue',
        onTap: _onContinue,
      ).paddingSymmetric(horizontal: 16);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.greyShade7,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.height,
            _buildHeader(),
            32.height,
            _buildTitle(),
            8.height,
            _buildSubtitle(),
            69.height,
            _buildSelfieArea(),
            const Spacer(),
            _buildPrivacyNote(),
            14.height,
            _buildContinueButton(),
            13.height,
          ],
        ),
      ),
    );
  }
}

class DottedOvalPainter extends CustomPainter {
  final Color color;
  final double dotRadius;
  final double spacing;

  DottedOvalPainter({
    this.color = Colors.black,
    this.dotRadius = 2.0,
    this.spacing = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final Rect ovalRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Path path = Path()..addOval(ovalRect);
    ui.PathMetrics pathMetrics = path.computeMetrics();
    for (ui.PathMetric pathMetric in pathMetrics) {
      double distance = 0;
      while (distance < pathMetric.length) {
        final ui.Tangent? tangent = pathMetric.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, dotRadius, paint);
        }
        distance += spacing;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DottedOvalPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.dotRadius != dotRadius ||
        oldDelegate.spacing != spacing;
  }
}
