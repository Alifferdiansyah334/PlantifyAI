class DetectionHistory {
  final String id;
  final String cropType;
  final String resultStatus;
  final double confidence;
  final String date;
  final String imageUrl;
  final String diseaseName;

  DetectionHistory({
    required this.id,
    required this.cropType,
    required this.resultStatus, // 'Healthy', 'Diseased', etc.
    required this.confidence,
    required this.date,
    required this.imageUrl,
    required this.diseaseName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cropType': cropType,
      'resultStatus': resultStatus,
      'confidence': confidence,
      'date': date,
      'imageUrl': imageUrl,
      'diseaseName': diseaseName,
    };
  }

  factory DetectionHistory.fromMap(Map<String, dynamic> map) {
    return DetectionHistory(
      id: map['id'],
      cropType: map['cropType'],
      resultStatus: map['resultStatus'],
      confidence: map['confidence'],
      date: map['date'],
      imageUrl: map['imageUrl'],
      diseaseName: map['diseaseName'] ?? 'Unknown',
    );
  }
}
