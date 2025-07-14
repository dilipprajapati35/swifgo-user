import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_arch/theme/colorTheme.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

void showDocumentDialog(BuildContext context, String url) {
  final bool isPdf = url.toLowerCase().endsWith('.pdf');
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // Document viewer based on file type
            isPdf 
                ? SfPdfViewer.network(
                    url,
                    canShowScrollHead: true,
                    canShowScrollStatus: true,
                    enableDoubleTapZooming: true,
                    pageLayoutMode: PdfPageLayoutMode.single,
                    onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to load PDF: ${details.error}')),
                      );
                    },
                  )
                : PhotoView(
                    imageProvider: NetworkImage(url),
                    minScale: PhotoViewComputedScale.contained * 0.8,
                    maxScale: PhotoViewComputedScale.covered * 3.0,
                    initialScale: PhotoViewComputedScale.contained * 0.8,
                    backgroundDecoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                    ),
                    loadingBuilder: (context, event) => Center(
                      child: CircularProgressIndicator(
                        color: AppColor.primaryColor,
                        value: event == null || event.expectedTotalBytes == null
                            ? 0
                            : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                      ),
                    ),
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, color: Colors.white, size: 40),
                          SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
            
            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                radius: 20,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}