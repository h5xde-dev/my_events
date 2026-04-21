import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

class User {
  const User({required this.uid});
  final String uid;
}

abstract class AuthBase {
  Stream<User?> get onAuthStateChanged;
  Future<User?> currentUser();
  Future<User> signInAnonymously();
  Future<User> signInWithGoogle();
  Future<void> signOut();
}

class Auth implements AuthBase {
  final _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  User? _userFromFirebase(firebase_auth.User? firebaseUser) {
    if (firebaseUser == null) {
      return null;
    }
    return User(uid: firebaseUser.uid);
  }

  @override
  Stream<User?> get onAuthStateChanged {
    return _firebaseAuth.idTokenChanges().map(_userFromFirebase);
  }

  @override
  Future<User?> currentUser() async {
    final user = _firebaseAuth.currentUser;
    return _userFromFirebase(user);
  }

  @override
  Future<User> signInAnonymously() async {
    final credentials = await _firebaseAuth.signInAnonymously();
    final mappedUser = _userFromFirebase(credentials.user);
    if (mappedUser == null) {
      throw StateError('Anonymous sign-in returned null user');
    }
    return mappedUser;
  }

  @override
  Future<User> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw StateError('Google sign-in cancelled');
    }

    final googleAuth = await googleUser.authentication;
    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _firebaseAuth.signInWithCredential(credential);
    final mappedUser = _userFromFirebase(result.user);
    if (mappedUser == null) {
      throw StateError('Google sign-in returned null user');
    }
    return mappedUser;
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
