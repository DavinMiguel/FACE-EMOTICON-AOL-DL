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
}

class PersonalityResult {
  final String personalityType;
  final String summary;
  final Color color;
  final List<PersonalityTrait> traits;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> careerSuggestions;    // TAMBAHKAN
  final String careerExplanation;          // TAMBAHKAN

  PersonalityResult({
    required this.personalityType,
    required this.summary,
    required this.color,
    required this.traits,
    required this.strengths,              // TAMBAHKAN
    required this.weaknesses,             // TAMBAHKAN
    required this.careerSuggestions,      // TAMBAHKAN
    required this.careerExplanation,      // TAMBAHKAN
  });
}

factory PersonalityResult.fromJson(Map<String, dynamic> json) {
  return PersonalityResult(
    personalityType: json['personalityType'],
    summary: json['summary'],
    color: Colors.blue,  // atau mapping string → warna
    traits: (json['traits'] as List)
        .map((e) => PersonalityTrait(
              name: e['name'],
              score: e['score'],
              description: e['description'],
            ))
        .toList(),
    strengths: List<String>.from(json['strengths']),
    weaknesses: List<String>.from(json['weaknesses']),
    careerSuggestions: List<String>.from(json['careerSuggestions']),
    careerExplanation: json['careerExplanation'],
  );
}
