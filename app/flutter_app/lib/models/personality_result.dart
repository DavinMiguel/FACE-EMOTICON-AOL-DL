import 'package:flutter/material.dart';

class PersonalityTrait {
  final String name;
  final int score;
  final String description;

  PersonalityTrait({
    required this.name,
    required this.score,
    required this.description,
  });

  factory PersonalityTrait.fromJson(Map<String, dynamic> json) {
    return PersonalityTrait(
      name: json['name'],
      score: json['score'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'score': score,
      'description': description,
    };
  }
}

class PersonalityResult {
  final String personalityType;
  final String summary;
  final Color color;
  final List<PersonalityTrait> traits;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> careerSuggestions;
  final String careerExplanation;

  PersonalityResult({
    required this.personalityType,
    required this.summary,
    required this.color,
    required this.traits,
    required this.strengths,
    required this.weaknesses,
    required this.careerSuggestions,
    required this.careerExplanation,
  });

  factory PersonalityResult.fromJson(Map<String, dynamic> json) {
    return PersonalityResult(
      personalityType: json['personalityType'],
      summary: json['summary'],
      color: Colors.blue, // Bisa diganti mapping
      traits: (json['traits'] as List<dynamic>)
          .map((e) => PersonalityTrait.fromJson(e))
          .toList(),
      strengths: List<String>.from(json['strengths']),
      weaknesses: List<String>.from(json['weaknesses']),
      careerSuggestions: List<String>.from(json['careerSuggestions']),
      careerExplanation: json['careerExplanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'personalityType': personalityType,
      'summary': summary,
      'traits': traits.map((t) => t.toJson()).toList(),
      'strengths': strengths,
      'weaknesses': weaknesses,
      'careerSuggestions': careerSuggestions,
      'careerExplanation': careerExplanation,
    };
  }
}
