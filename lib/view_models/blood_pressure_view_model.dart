import 'package:material_ui/material_ui.dart';
import 'package:saludap/models/blood_pressure_reading_model.dart';
import 'package:saludap/repositories/blood_pressure_repository.dart';
import 'package:saludap/services/api_exception.dart';

class BloodPressurePeriodSummary {
  const BloodPressurePeriodSummary({
    required this.averageSystolic,
    required this.averageDiastolic,
    required this.count,
  });

  final double averageSystolic;
  final double averageDiastolic;
  final int count;
}

class BloodPressureViewModel extends ChangeNotifier {
  BloodPressureViewModel(this._repository);

  final BloodPressureRepository _repository;
  List<BloodPressureReadingModel> _readings = const [];
  String? _profileId;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<BloodPressureReadingModel> get readings => _readings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  BloodPressureReadingModel? get latestReading =>
      _readings.isEmpty ? null : _readings.first;

  BloodPressurePeriodSummary? get sevenDaySummary {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final recent = _readings
        .where((reading) => reading.takenAt.isAfter(cutoff))
        .toList();
    if (recent.isEmpty) return null;

    final systolicTotal = recent.fold<int>(
      0,
      (total, reading) => total + reading.systolic,
    );
    final diastolicTotal = recent.fold<int>(
      0,
      (total, reading) => total + reading.diastolic,
    );
    return BloodPressurePeriodSummary(
      averageSystolic: systolicTotal / recent.length,
      averageDiastolic: diastolicTotal / recent.length,
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
    required int systolic,
    required int diastolic,
    int? pulse,
    String? notes,
  }) async {
    if (_isSaving) return false;
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final reading = await _repository.createReading(
        profileId: profileId,
        systolic: systolic,
        diastolic: diastolic,
        pulse: pulse,
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
