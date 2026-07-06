import 'package:google_sign_in/google_sign_in.dart';
import 'package:mimio/core/config/google_config.dart';

class GoogleAuthService {
  GoogleAuthService()
      : _googleSignIn = GoogleSignIn(
          serverClientId: GoogleConfig.webClientId,
          scopes: const ['email', 'profile'],
        );

  final GoogleSignIn _googleSignIn;

  Future<String?> signInAndGetIdToken() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;

    final auth = await account.authentication;
    return auth.idToken;
  }

  Future<void> signOut() => _googleSignIn.signOut();
}
