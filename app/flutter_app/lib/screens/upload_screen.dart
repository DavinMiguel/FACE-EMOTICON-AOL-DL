import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'results_screen.dart';
import 'package:personality_scanner/services/ai_service.dart';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  PlatformFile? _pickedFile;
  bool _isAnalyzing = false;

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _pickedFile = result.files.first;
        });
      }
    } catch (e) {
      print("pick error: $e");
    }
  }

  // ===========================================================
  //               FIXED API CALL WITH SAFETY CHECK
  // ===========================================================
  Future<void> _analyzeImage() async {
    if (_pickedFile == null) return;

    setState(() => _isAnalyzing = true);

    try {
      print("Sending image to API...");
      final apiResult = await AIService.analyzeImageBytes(_pickedFile!);
      print("API Response: $apiResult");

      bool noFace =
          apiResult["status"] == "error" || apiResult["emotion"] == null;

      // Jika API mengirim format aneh / tidak sesuai
      if (apiResult is! Map) {
        _showErrorDialog("Invalid response from server.");
        setState(() => _isAnalyzing = false);
        return;
      }

      setState(() => _isAnalyzing = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            imageBytes: _pickedFile!.bytes!,
            fileName: _pickedFile!.name,
            faceNotDetected: noFace,
            result: apiResult,
          ),
        ),
      );
    } catch (e) {
      print("API ERROR: $e");

      setState(() => _isAnalyzing = false);

      _showErrorDialog("Failed to connect to server.\nCheck Flask IP or WiFi.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          )
        ],
      ),
    );
  }

  // ===========================================================
  // UI
  // ===========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Photo"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.upload, size: 80, color: Color(0xFFE91E63)),
                SizedBox(height: 20),
                Text(
                  "Upload Your Photo",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildPreview(),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE91E63),
                  ),
                  child: Text("CHOOSE PHOTO"),
                ),
                if (_pickedFile != null) ...[
                  SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: _isAnalyzing ? null : _analyzeImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE91E63),
                      minimumSize: Size(250, 50),
                    ),
                    child: _isAnalyzing
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "ANALYZE PERSONALITY",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(0xFFE91E63).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: _pickedFile?.bytes == null
          ? Center(child: Text("No Image Selected"))
          : ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.memory(
                _pickedFile!.bytes!,
                fit: BoxFit.cover,
              ),
            ),
    );
  }
}
