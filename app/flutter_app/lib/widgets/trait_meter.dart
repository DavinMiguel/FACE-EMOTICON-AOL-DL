import 'package:flutter/material.dart';
import '../models/personality_result.dart';

class TraitMeter extends StatelessWidget {
  final PersonalityTrait trait;
  final EdgeInsetsGeometry margin;  // TAMBAHKAN INI

  const TraitMeter({
    Key? key,
    required this.trait,
    this.margin = EdgeInsets.zero,  // TAMBAHKAN INI dengan default value
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,  // GUNAKAN di sini
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                trait.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${trait.score}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(trait.score),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          LinearProgressIndicator(
            value: trait.score / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(_getScoreColor(trait.score)),
          ),
          SizedBox(height: 10),
          Text(
            trait.description,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}