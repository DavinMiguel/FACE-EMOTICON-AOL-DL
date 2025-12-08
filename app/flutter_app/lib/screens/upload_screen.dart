import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'results_screen.dart';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  PlatformFile? _pickedFile;
  bool _isAnalyzing = false;

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _pickedFile = result.files.first;
        });
      }
    } catch (e) {
      print("Error picking file: $e");
    }
  }

  Future<void> _analyzeImage() async {
    if (_pickedFile == null) return;
    
    setState(() { _isAnalyzing = true; });
    
    await Future.delayed(Duration(seconds: 2));
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          imageBytes: _pickedFile!.bytes,
          fileName: _pickedFile!.name,
        ),
      ),
    );
    
    setState(() { _isAnalyzing = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Photo'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.upload,
                size: 80,
                color: Color(0xFFE91E63),  // Magenta
              ),
              SizedBox(height: 20),
              Text(
                'Upload Your Photo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Select a clear face photo for personality analysis',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),

              // Image Preview
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFFE91E63).withOpacity(0.3),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[50],
                ),
                child: _pickedFile?.bytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.memory(
                          _pickedFile!.bytes!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_camera,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 20),
                            Text(
                              'No photo selected',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              SizedBox(height: 30),

              // Upload Button
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.cloud_upload),
                label: Text(
                  'CHOOSE PHOTO FROM COMPUTER',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE91E63),  // Magenta
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 15),

              if (_pickedFile != null) ...[
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFE91E63).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Color(0xFFE91E63).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Color(0xFFE91E63),
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Selected: ${_pickedFile!.name}',
                        style: TextStyle(
                          color: Color(0xFFE91E63),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),

                // Analyze Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isAnalyzing ? null : _analyzeImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE91E63),  // Magenta
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: _isAnalyzing
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'ANALYZING WITH AI...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.psychology, size: 24),
                              SizedBox(width: 10),
                              Text(
                                'ANALYZE PERSONALITY',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],

              SizedBox(height: 40),
              _buildTips(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTips() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFFCE4EC),  // Light magenta background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE91E63).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Color(0xFFE91E63)),
              SizedBox(width: 10),
              Text(
                'Tips for Best Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE91E63),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildTipItem('✅ Use a front-facing photo'),
          _buildTipItem('✅ Ensure good natural lighting'),
          _buildTipItem('✅ Maintain neutral expression'),
          _buildTipItem('✅ Face should cover most of frame'),
          _buildTipItem('✅ Remove glasses if possible'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }
}
