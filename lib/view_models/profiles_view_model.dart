import 'package:material_ui/material_ui.dart';
import 'package:saludap/models/profile_model.dart';
import 'package:saludap/repositories/profile_repository.dart';
import 'package:saludap/services/api_exception.dart';

class ProfilesViewModel extends ChangeNotifier {
  ProfilesViewModel(this._repository);

  final ProfileRepository _repository;
  List<ProfileModel> _profiles = const [];
  ProfileModel? _selectedProfile;
  bool _isLoading = false;
  String? _errorMessage;

  List<ProfileModel> get profiles => _profiles;
  ProfileModel? get selectedProfile => _selectedProfile;
  bool get hasProfiles => _profiles.isNotEmpty;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profiles = await _repository.listProfiles();
      _selectedProfile = _profiles.isEmpty ? null : _profiles.first;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void select(ProfileModel profile) {
    if (_selectedProfile?.id == profile.id) return;
    _selectedProfile = profile;
    notifyListeners();
  }
}
