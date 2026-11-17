enum GlucoseTakenContext {
  fasting('fasting', 'En ayunas', true),
  beforeMeal('before_meal', 'Antes de comer', true),
  afterMeal('after_meal', 'Después de comer', true),
  bedtime('bedtime', 'Antes de dormir', true),
  random('random', 'Aleatoria', false),
  unknown('unknown', 'Sin especificar', false),
  other('other', 'Otro momento', false);

  const GlucoseTakenContext(this.apiValue, this.label, this.isSelectable);

  final String apiValue;
  final String label;
  final bool isSelectable;

  static List<GlucoseTakenContext> get selectableValues =>
      values.where((context) => context.isSelectable).toList(growable: false);

  factory GlucoseTakenContext.fromApiValue(String value) {
    return values.firstWhere(
      (context) => context.apiValue == value,
      orElse: () => GlucoseTakenContext.unknown,
    );
  }
}

class GlucoseReadingModel {
  const GlucoseReadingModel({
    required this.id,
    required this.profileId,
    required this.value,
    required this.unit,
    required this.takenContext,
    required this.takenAt,
    this.notes,
  });

  final String id;
  final String profileId;
  final double value;
  final String unit;
  final GlucoseTakenContext takenContext;
  final String? notes;
  final DateTime takenAt;

  factory GlucoseReadingModel.fromJson(Map<String, dynamic> json) {
    return GlucoseReadingModel(
      id: json['id'] as String,
      profileId: json['profileId'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      takenContext: GlucoseTakenContext.fromApiValue(
        json['takenContext'] as String,
      ),
      notes: json['notes'] as String?,
      takenAt: DateTime.parse(json['takenAt'] as String),
    );
  }
}
