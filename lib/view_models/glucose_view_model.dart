import 'package:material_ui/material_ui.dart';
import 'package:saludap/models/glucose_reading_model.dart';
import 'package:saludap/repositories/glucose_repository.dart';
import 'package:saludap/services/api_exception.dart';

class GlucosePeriodSummary {
  const GlucosePeriodSummary({
    required this.context,
    required this.average,
    required this.count,
  });

  final GlucoseTakenContext context;
  final double average;
  final int count;
}

class GlucoseViewModel extends ChangeNotifier {
  GlucoseViewModel(this._repository);

  final GlucoseRepository _repository;
  List<GlucoseReadingModel> _readings = const [];
  String? _profileId;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<GlucoseReadingModel> get readings => _readings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  GlucoseReadingModel? get latestReading =>
      _readings.isEmpty ? null : _readings.first;

  GlucosePeriodSummary? get sevenDaySummaryForLatestContext {
    final latest = latestReading;
    if (latest == null) return null;

    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final recent = _readings
        .where(
          (reading) =>
              reading.takenContext == latest.takenContext &&
              reading.takenAt.isAfter(cutoff),
        )
        .toList();
    if (recent.isEmpty) return null;

    final total = recent.fold<double>(0, (sum, reading) => sum + reading.value);
    return GlucosePeriodSummary(
      context: latest.takenContext,
      average: total / recent.length,
      count: recent.length,
    );
  }

  Future<void> load(String profileId) async {
    if (_isLoading) return;
    _profileId = profileId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _readings = await _repository.listReadings(profileId);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final profileId = _profileId;
    if (profileId != null) await load(profileId);
  }

  Future<bool> create({
    required String profileId,
    required double value,
    required GlucoseTakenContext takenContext,
    String? notes,
  }) async {
    if (_isSaving) return false;
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final reading = await _repository.createReading(
        profileId: profileId,
        value: value,
        takenContext: takenContext,
        notes: notes,
        takenAt: DateTime.now(),
      );
      _readings = [reading, ..._readings];
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
