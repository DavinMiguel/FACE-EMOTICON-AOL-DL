import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:personality_scanner/widgets/trait_meter.dart';
import 'package:personality_scanner/models/personality_result.dart';

class ResultsScreen extends StatefulWidget {
  final Uint8List? imageBytes;
  final String? fileName;
  final bool faceNotDetected;
  final Map<String, dynamic>? result;

  const ResultsScreen({
    Key? key,
    required this.imageBytes,
    required this.fileName,
    this.faceNotDetected = false,
    this.result,
  }) : super(key: key);

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;

  late String emotion;
  late double confidence;
  late List<PersonalityTrait> traits;

  @override
  void initState() {
    super.initState();

    // Ambil data dari backend
    emotion = widget.result?["emotion"] ?? "Unknown";
    confidence = widget.result?["confidence"] ?? 0.0;

    // Generate traits dinamis berdasarkan emotion
    traits = _generateTraits(emotion, confidence);

    // Delay loading animation
    Future.delayed(Duration(seconds: 2), () {
      setState(() => _loading = false);
    });
  }

  // GENERATE PERSONALITY TRAITS DINAMIS (BERDASARKAN EMOTION)

  List<PersonalityTrait> _generateTraits(String emotion, double conf) {
    int base = (conf * 100).round();

    Map<String, List<int>> patterns = {
      "Happy": [90, 85, 80, 75, 70],
      "Neutral": [75, 70, 65, 60, 55],
      "Sad": [40, 45, 50, 35, 30],
      "Angry": [60, 55, 40, 45, 50],
      "Fear": [50, 45, 40, 55, 60],
      "Surprise": [70, 75, 65, 80, 60],
      "Disgust": [45, 40, 50, 35, 30],
    };

    List<int> selected = patterns[emotion] ?? [60, 60, 60, 60, 60];

    List<String> labels = [
      "Emotional Intelligence",
      "Social Skills",
      "Creativity",
      "Leadership",
      "Analytical Thinking"
    ];

    return List.generate(5, (i) {
      return PersonalityTrait(
        name: labels[i],
        score: selected[i],
        description: "${labels[i]} score based on detected emotion.",
      );
    });
  }

  // MAIN BUILD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Personality Report'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _loading
          ? _buildLoading()
          : widget.faceNotDetected
              ? _buildNoFaceDetected()
              : _buildNormalResult(),
    );
  }

  // LOADING VIEW

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFFE91E63)),
          SizedBox(height: 20),
          Text(
            'Analyzing your personality...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // NO FACE DETECTED

  Widget _buildNoFaceDetected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sentiment_dissatisfied,
              size: 140, color: Colors.redAccent),
          SizedBox(height: 20),
          Text(
            "We couldn't detect a face.\nTry again with a clearer photo.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
            ),
            child: Text("TRY AGAIN",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalResult() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Image
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0xFFE91E63),
                width: 4,
              ),
            ),
            child: ClipOval(
              child: Image.memory(widget.imageBytes!,
                  width: 180, height: 180, fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: 25),

          // Main Card
          Container(
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(Icons.psychology, size: 50, color: Colors.white),
                SizedBox(height: 15),
                Text(
                  emotion.toUpperCase(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "Confidence: ${(confidence * 100).toStringAsFixed(1)}%",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 30),

          Text(
            'PERSONALITY TRAITS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE91E63),
            ),
          ),
          SizedBox(height: 20),

          // Dynamic traits
          ...traits.map((t) => TraitMeter(
                trait: t,
                margin: EdgeInsets.only(bottom: 18),
              )),
        ],
      ),
    );
  }
}
