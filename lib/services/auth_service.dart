import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

import '../core/di/service_locator.dart';
import '../core/network/dio_client.dart';

class AuthService {
  final logger = getIt<Logger>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<String?> getIdToken() async {
    final user = _auth.currentUser;
    return await user?.getIdToken();
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final authz = await googleUser.authorizationClient.authorizeScopes([
        'email',
      ]);

      final credential = GoogleAuthProvider.credential(
        accessToken: authz.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      logger.e("Erro no Google Sign-In: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      // Limpa também o modo impersonation ao deslogar
      if (kDebugMode) {
        getIt<DioClient>().setImpersonationUid("");
      }
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      logger.e("Erro ao deslogar: $e");
    }
  }
}
