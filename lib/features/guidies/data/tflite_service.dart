// lib/features/guidies/data/tflite_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  Interpreter? _interpreter;
  Map<String, int>? _vocabulary;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load vocabulary from your vocab.json
      final vocabJson = await rootBundle.loadString('assets/ai/vocab.json');
      _vocabulary = Map<String, int>.from(json.decode(vocabJson));

      // Load TFLite model (you'll need to add this to assets)
      _interpreter = await Interpreter.fromAsset(
        'assets/ai/med_guide_intent_classifier.tflite',
      );

      _isInitialized = true;
      print('✓ TFLite service initialized');
    } catch (e) {
      print('✗ TFLite initialization failed: $e');
      throw Exception('Failed to initialize TFLite: $e');
    }
  }

  Future<String> classifyIntent(String text) async {
    if (!_isInitialized || _interpreter == null) {
      throw Exception('TFLite not initialized');
    }

    try {
      // Preprocess text
      final tokens = _tokenize(text);
      final input = _convertToInput(tokens);

      // Run inference
      final output = List.filled(
        5,
        0.0,
      ).reshape([1, 5]); // Adjust based on your model
      _interpreter!.run(input, output);

      // Get predicted intent
      final intentIndex = output[0].indexOf(
        output[0].reduce((a, b) => a > b ? a : b),
      );

      // Map index to intent (adjust based on your model)
      const intents = [
        'location',
        'registration',
        'services',
        'activities',
        'academic',
      ];
      return intents[intentIndex];
    } catch (e) {
      print('Error classifying intent: $e');
      return 'general'; // Default fallback
    }
  }

  double calculateSimilarity(String text1, String text2) {
    if (_vocabulary == null) return 0.0;

    final tokens1 = _tokenize(text1);
    final tokens2 = _tokenize(text2);

    final vector1 = _textToVector(tokens1);
    final vector2 = _textToVector(tokens2);

    return _cosineSimilarity(vector1, vector2);
  }

  List<int> _tokenize(String text) {
    // Simple tokenization - you might want to use a proper Arabic tokenizer
    final words = text.toLowerCase().split(RegExp(r'\s+'));
    return words.map((word) => _vocabulary?[word] ?? 1).toList(); // 1 is [UNK]
  }

  List<List<double>> _convertToInput(List<int> tokens) {
    // Convert to model input format (adjust based on your model)
    const maxLength = 50; // Adjust based on your model
    final padded = List<int>.filled(maxLength, 0);
    for (int i = 0; i < tokens.length && i < maxLength; i++) {
      padded[i] = tokens[i];
    }
    return [padded.map((e) => e.toDouble()).toList()];
  }

  List<double> _textToVector(List<int> tokens) {
    // Simple bag-of-words vectorization
    const vectorSize = 100; // Adjust based on your vocabulary size
    final vector = List<double>.filled(vectorSize, 0.0);

    for (final token in tokens) {
      if (token < vectorSize) {
        vector[token] += 1.0;
      }
    }

    return vector;
  }

  double _cosineSimilarity(List<double> a, List<double> b) {
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0.0 || normB == 0.0) return 0.0;

    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  double sqrt(double x) => x > 0 ? math.sqrt(x) : 0.0;
  double pow(double x, double y) => math.pow(x, y).toDouble();

  void dispose() {
    _interpreter?.close();
    _isInitialized = false;
  }
}
