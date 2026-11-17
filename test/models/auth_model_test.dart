import 'package:flutter_test/flutter_test.dart';
import 'package:saludap/models/auth_model.dart';

void main() {
  test('parses the authentication response', () {
    final auth = AuthModel.fromJson({
      'data': {
        'user': {
          'uid': 'user-id',
          'email': 'root@saludap.dev',
          'displayName': null,
        },
        'tokens': {
          'idToken': 'id-token',
          'refreshToken': 'refresh-token',
          'expiresIn': 3600,
          'tokenType': 'Bearer',
        },
      },
    });

    expect(auth.user.uid, 'user-id');
    expect(auth.user.email, 'root@saludap.dev');
    expect(auth.user.displayName, isNull);
    expect(auth.tokens.idToken, 'id-token');
    expect(auth.tokens.expiresIn, 3600);
    expect(auth.tokens.tokenType, 'Bearer');
  });
}
