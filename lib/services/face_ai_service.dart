import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../data/models/risk_level.dart';

class FaceAIResult {
  final bool eyesOpen;
  final double headAngle;
  final bool lookingForward;
  final bool tired;
  final RiskLevel risk;

  FaceAIResult({
    required this.eyesOpen,
    required this.headAngle,
    required this.lookingForward,
    required this.tired,
    required this.risk,
  });
}

class FaceAIService {
  static Future<FaceAIResult> analyze(String imagePath) async {
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
      ),
    );

    final inputImage = InputImage.fromFile(File(imagePath));
    final faces = await faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      return FaceAIResult(
        eyesOpen: false,
        headAngle: 0,
        lookingForward: false,
        tired: true,
        risk: RiskLevel.high,
      );
    }

    final face = faces.first;

    final leftEye = face.leftEyeOpenProbability ?? 0;
    final rightEye = face.rightEyeOpenProbability ?? 0;

    final eyesOpen = leftEye > 0.5 && rightEye > 0.5;

    final headAngle = face.headEulerAngleY ?? 0;
    final lookingForward = headAngle.abs() < 15;

    // 🔥 детекция усталости
    final tired = !eyesOpen || leftEye < 0.4 || rightEye < 0.4;

    RiskLevel risk;

    if (eyesOpen && lookingForward && !tired) {
      risk = RiskLevel.low;
    } else if (eyesOpen && !tired) {
      risk = RiskLevel.medium;
    } else {
      risk = RiskLevel.high;
    }

    await faceDetector.close();

    return FaceAIResult(
      eyesOpen: eyesOpen,
      headAngle: headAngle,
      lookingForward: lookingForward,
      tired: tired,
      risk: risk,
    );
  }
}