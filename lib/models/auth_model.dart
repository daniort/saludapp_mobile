class AuthModel {
  const AuthModel({required this.user, required this.tokens});

  final AuthUserModel user;
  final AuthTokensModel tokens;

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final data = _readMap(json, 'data');

    return AuthModel.fromDataJson(data);
  }

  factory AuthModel.fromDataJson(Map<String, dynamic> data) {
    return AuthModel(
      user: AuthUserModel.fromJson(_readMap(data, 'user')),
      tokens: AuthTokensModel.fromJson(_readMap(data, 'tokens')),
    );
  }

  AuthModel withTokens(AuthTokensModel value) {
    return AuthModel(user: user, tokens: value);
  }

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'tokens': tokens.toJson(),
  };
}

class AuthUserModel {
  const AuthUserModel({
    required this.uid,
    required this.email,
    this.displayName,
  });

  final String uid;
  final String email;
  final String? displayName;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      uid: _readString(json, 'uid'),
      email: _readString(json, 'email'),
      displayName: json['displayName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
  };
}

class AuthTokensModel {
  const AuthTokensModel({
    required this.idToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
  });

  final String idToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    final expiresIn = json['expiresIn'];
    if (expiresIn is! num) {
      throw const FormatException('El campo tokens.expiresIn no es válido.');
    }

    return AuthTokensModel(
      idToken: _readString(json, 'idToken'),
      refreshToken: _readString(json, 'refreshToken'),
      expiresIn: expiresIn.toInt(),
      tokenType: _readString(json, 'tokenType'),
    );
  }

  Map<String, dynamic> toJson() => {
    'idToken': idToken,
    'refreshToken': refreshToken,
    'expiresIn': expiresIn,
    'tokenType': tokenType,
  };
}

Map<String, dynamic> _readMap(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! Map) {
    throw FormatException('El campo $key no es válido.');
  }

  return Map<String, dynamic>.from(value);
}

String _readString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.isEmpty) {
    throw FormatException('El campo $key no es válido.');
  }

  return value;
}
