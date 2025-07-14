class ValidationUtils {
  static String? validateDuration(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter duration';
    }
    final duration = int.tryParse(value);
    if (duration == null) {
      return 'Please enter a valid number';
    }
    if (duration < 1) {
      return 'Duration must be at least 1 minute!';
    }
    return null;
  }

  static String? validatePassingPercentage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter passing percentage';
    }

    final percentage = double.tryParse(value);
    if (percentage == null) {
      return 'Please enter a valid number';
    }

    if (percentage < 0) {
      return 'Passing percentage cannot be negative!';
    }

    if (percentage > 100) {
      return 'Passing percentage must be ≤ 100!';
    }

    return null;
  }

  static String? validateQuestions(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter number of questions';
    }

    final questions = int.tryParse(value);
    if (questions == null) {
      return 'Please enter a valid number';
    }

    if (questions < 1) {
      return 'Number of questions must be at least 1!';
    }

    return null;
  }

  static String? validateNegativeMarks({
    required String? totalMarks,
    required String? numberOfQuestions,
    required String? negativeMarks,
  }) {
    if (negativeMarks == null || negativeMarks.isEmpty) {
      return 'Please enter negative marks';
    }
    double? negativemk = double.tryParse(negativeMarks);
    if (negativemk == null) {
      return "Please enter a valid number";
    }

    if (negativemk <= 0) {
      return "Negative marks must be a positive value";
    }

    if (totalMarks == null ||
        totalMarks.isEmpty ||
        numberOfQuestions == null ||
        numberOfQuestions.isEmpty) {
      return 'Please enter total marks and number of questions first!';
    }

    final total = double.tryParse(totalMarks);
    final questions = int.tryParse(numberOfQuestions);
    final negative = double.tryParse(negativeMarks);

    if (total == null || questions == null || negative == null) {
      return 'Please enter valid numbers';
    }

    final marksPerQuestion = total / questions;

    if (negative > marksPerQuestion) {
      return 'Negative marks cannot exceed ${marksPerQuestion.toStringAsFixed(2)} per question!';
    }

    return null;
  }

  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  static String? validateNumericField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    return null;
  }

  // YouTube URL validation for AI quiz generation
  static String? validateYoutubeUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a YouTube URL';
    }

    // Regular expression to validate YouTube URLs
    final RegExp youtubeRegex = RegExp(
      r'^(https?:\/\/)?(www\.)?(youtube\.com|youtu\.be)\/.+$',
      caseSensitive: false,
    );

    if (!youtubeRegex.hasMatch(value)) {
      return 'Please enter a valid YouTube URL';
    }

    return null;
  }

  // File validation for AI quiz generation
  static String? validateFileType(
      String? filePath, List<String> allowedMimeTypes) {
    if (filePath == null || filePath.isEmpty) {
      return 'Please select a file';
    }

    final fileExtension = filePath.split('.').last.toLowerCase();
    final mimeType = _getMimeTypeFromExtension(fileExtension);

    if (mimeType == null || !allowedMimeTypes.contains(mimeType)) {
      return 'Invalid file type. Please select a valid file.';
    }

    return null;
  }

  // Helper method to get mime type from file extension
  static String? _getMimeTypeFromExtension(String extension) {
    final mimeTypeMap = {
      'pdf': 'application/pdf',
      'mp3': 'AUDIO',
      'wav': 'AUDIO',
      'm4a': 'AUDIO',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'svg': 'image/svg+xml',
      'webp': 'image/webp',
      'ppt':
          'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'pptx':
          'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'doc':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    };

    return mimeTypeMap[extension];
  }
}
