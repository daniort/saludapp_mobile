class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.profileType,
    required this.givenNames,
    required this.paternalSurname,
    required this.birthDate,
    required this.isOwner,
    this.maternalSurname,
  });

  final String id;
  final String profileType;
  final String givenNames;
  final String paternalSurname;
  final String? maternalSurname;
  final DateTime birthDate;
  final bool isOwner;

  String get fullName => [
    givenNames,
    paternalSurname,
    if (maternalSurname != null && maternalSurname!.isNotEmpty)
      maternalSurname!,
  ].join(' ');

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      profileType: json['profileType'] as String,
      givenNames: json['givenNames'] as String,
      paternalSurname: json['paternalSurname'] as String,
      maternalSurname: json['maternalSurname'] as String?,
      birthDate: DateTime.parse(json['birthDate'] as String),
      isOwner: json['isOwner'] as bool,
    );
  }
}
