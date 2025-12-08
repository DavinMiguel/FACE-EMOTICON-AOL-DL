import 'package:flutter/material.dart';
import 'upload_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE91E63), 
              Color(0xFF9C27B0),  
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                Hero(
                  tag: 'logo',
                  child: Icon(
                    Icons.psychology_outlined,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Personality Scanner',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Upload your photo and discover your personality traits instantly',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                Spacer(),
                _buildInfoCards(),
                SizedBox(height: 40),
                _buildStartButton(context),
                SizedBox(height: 20),
                Text(
                  '100% Private • No Data Stored • Instant Results',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCards() {
    return Column(
      children: [
        _buildCard(
          icon: Icons.upload,
          title: 'Upload Photo',
          subtitle: 'Select a clear face photo',
          color: Colors.white,
        ),
        SizedBox(height: 15),
        _buildCard(
          icon: Icons.psychology,
          title: 'AI Analysis',
          subtitle: 'Advanced neural network analysis',
          color: Colors.white,
        ),
        SizedBox(height: 15),
        _buildCard(
          icon: Icons.insights,
          title: 'Get Insights',
          subtitle: 'Detailed personality breakdown',
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UploadScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFFE91E63),  // Magenta
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'START ANALYSIS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward_rounded, size: 24),
          ],
        ),
      ),
    );
  }
}