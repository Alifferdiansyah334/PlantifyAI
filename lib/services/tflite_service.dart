import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteService {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isModelLoaded = false;
  List<int> _inputShape = [1, 224, 224, 3]; // Default, will update from model
  TensorType _inputType = TensorType.float32;

  bool get isModelLoaded => _isModelLoaded;

  Future<void> loadModel(String cropName) async {
    try {
      _interpreter?.close(); // Close existing if any
      
      final modelPath = 'assets/models/${cropName.toLowerCase()}_model.tflite';
      final labelsPath = 'assets/models/${cropName.toLowerCase()}_labels.txt';

      print('DEBUG: Loading model from $modelPath...');
      
      // Load Interpreter
      final options = InterpreterOptions();
      
      _interpreter = await Interpreter.fromAsset(modelPath, options: options);

      // Get Input Shape & Type automatically
      if (_interpreter != null) {
        final inputTensor = _interpreter!.getInputTensor(0);
        _inputShape = inputTensor.shape;
        _inputType = inputTensor.type;
        
        if (_inputShape.isNotEmpty && _inputShape[0] == -1) {
          _inputShape[0] = 1;
        }
        
        print('Model Loaded successfully. Input Shape: $_inputShape, Type: $_inputType');
      }

      // Load Labels
      final labelData = await rootBundle.loadString(labelsPath);
      _labels = labelData
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      _isModelLoaded = true;
    } catch (e) {
      print('CRITICAL ERROR loading model: $e');
      _isModelLoaded = false;
    }
  }

  Future<Map<String, dynamic>?> classifyImage(String imagePath) async {
    print('DEBUG: Starting classification for: $imagePath');
    if (!_isModelLoaded || _interpreter == null) {
      print('DEBUG: Aborting - Model or Interpreter is NULL');
      return null;
    }

    try {
      final inputTensor = _interpreter!.getInputTensor(0);
      final outputTensor = _interpreter!.getOutputTensor(0);
      
      final int height = inputTensor.shape[1];
      final int width = inputTensor.shape[2];
      final inputType = inputTensor.type;
      final inputShape = inputTensor.shape;

      // Read file // --> Load gambar dari URI
      final file = File(imagePath);
      if (!file.existsSync()) {
        print('DEBUG ERROR: File does not exist at path');
        return null;
      }
      final bytes = await file.readAsBytes();
      print('DEBUG: Image bytes read: ${bytes.length}');

      // Decode image // --> Baca format gambar
      img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        print('DEBUG ERROR: Failed to decode image. Format might be unsupported.');
        return null;
      }
      print('DEBUG: Image decoded. Size: ${image.width}x${image.height}');

      // Pre-processing // --> Untuk orientasi sama dimensi gambar 
      image = img.bakeOrientation(image);
      int minSide = image.width < image.height ? image.width : image.height;
      img.Image cropped = img.copyCrop(image, 
        x: (image.width - minSide) ~/ 2, 
        y: (image.height - minSide) ~/ 2, 
        width: minSide, height: minSide);
      img.Image resized = img.copyResize(cropped, width: width, height: height);

      // Prepare Input Buffer // --> Untuk dimensi shape supaya bisa diterima model
      dynamic inputBuffer;
      if (inputType == TensorType.uint8) {
        var lp = Uint8List(width * height * 3);
        int i = 0;
        for (var y = 0; y < height; y++) {
          for (var x = 0; x < width; x++) {
            var pixel = resized.getPixel(x, y);
            lp[i++] = pixel.r.toInt();
            lp[i++] = pixel.g.toInt();
            lp[i++] = pixel.b.toInt();
          }
        }
        inputBuffer = lp.reshape(inputShape);
      } else {
        var lp = Float32List(width * height * 3);
        int i = 0;
        for (var y = 0; y < height; y++) {
          for (var x = 0; x < width; x++) {
            var pixel = resized.getPixel(x, y);
            // Normalization: (pixel / 127.5) - 1.0
            lp[i++] = (pixel.r.toDouble() / 127.5) - 1.0;
            lp[i++] = (pixel.g.toDouble() / 127.5) - 1.0;
            lp[i++] = (pixel.b.toDouble() / 127.5) - 1.0;
          }
        }
        inputBuffer = lp.reshape(inputShape);
      }

      // Prepare Output Buffer
      var outputShape = outputTensor.shape;
      var outputBuffer = List<double>.filled(outputShape.reduce((a, b) => a * b), 0).reshape(outputShape);
      if (outputTensor.type == TensorType.uint8) {
        outputBuffer = Uint8List(outputShape.reduce((a, b) => a * b)).reshape(outputShape);
      }

      print('DEBUG: Running Interpreter...');
      _interpreter!.run(inputBuffer, outputBuffer);
      
      // Process Results
      List<double> scores = [];
      if (outputTensor.type == TensorType.uint8) {
        final List<int> rawScores = outputBuffer[0];
        scores = rawScores.map((s) => s.toDouble() / 255.0).toList();
      } else {
        final List<dynamic> rawScores = outputBuffer[0];
        scores = rawScores.cast<double>();
      }

      print('DEBUG: Scores result: $scores');

      double maxScore = -1.0;
      int maxIndex = -1;
      for (int i = 0; i < scores.length; i++) {
        if (scores[i] > maxScore) {
          maxScore = scores[i];
          maxIndex = i;
        }
      }

      if (maxIndex != -1 && maxIndex < _labels.length) {
        return {
          'label': _labels[maxIndex],
          'confidence': maxScore,
        };
      }
    } catch (e, stack) {
      print('DEBUG CRITICAL ERROR: $e');
      print(stack);
    }
    return null;
  }

  // Float32: Normalized to [-1, 1]

  // Uint8: [0, 255]
  
  void dispose() {
    _interpreter?.close();
  }
}
