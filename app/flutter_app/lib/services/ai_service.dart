import 'dart:io';
import 'package:flutter/material.dart';  // IMPORT INI
import '../models/personality_result.dart';

class AiService {
  Future<PersonalityResult> analyzeImage(File imageFile) async {
    await Future.delayed(Duration(seconds: 2));
    
    return PersonalityResult(
      personalityType: 'The Analyst',
      summary: 'You possess a logical and analytical mind.',
      color: Colors.blue,  // PASTIKAN 'Colors' dengan C BESAR
      traits: [
        PersonalityTrait(
          name: 'Analytical Thinking',
          score: 85,
          description: 'Excellent problem-solving skills',
        ),
        PersonalityTrait(
          name: 'Emotional Intelligence',
          score: 72,
          description: 'Good understanding of emotions',
        ),
        PersonalityTrait(
          name: 'Social Skills',
          score: 45,
          description: 'More reserved in social settings',
        ),
      ],
      strengths: [      // TAMBAHKAN
        'Problem-solving',
        'Attention to detail',
        'Reliability',
      ],
      weaknesses: [     // TAMBAHKAN
        'Can overthink',
        'Sometimes too reserved',
      ],
      careerSuggestions: [  // TAMBAHKAN
        'Data Analyst',
        'Software Developer',
        'Researcher',
      ],
      careerExplanation: 'Your analytical skills are suited for technical roles.',  // TAMBAHKAN
    );
  }
}