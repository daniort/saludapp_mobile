class BloodPressureReadingModel {
  const BloodPressureReadingModel({
    required this.id,
    required this.profileId,
    required this.systolic,
    required this.diastolic,
    required this.takenAt,
    this.pulse,
    this.notes,
  });

  final String id;
  final String profileId;
  final int systolic;
  final int diastolic;
  final int? pulse;
  final String? notes;
  final DateTime takenAt;

  factory BloodPressureReadingModel.fromJson(Map<String, dynamic> json) {
    return BloodPressureReadingModel(
      id: json['id'] as String,
      profileId: json['profileId'] as String,
      systolic: (json['systolic'] as num).toInt(),
      diastolic: (json['diastolic'] as num).toInt(),
      pulse: (json['pulse'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      takenAt: DateTime.parse(json['takenAt'] as String),
    );
  }
}
