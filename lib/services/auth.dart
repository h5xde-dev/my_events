import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
class User {
  const User({required this.uid});
  final String uid;
}

abstract class AuthBase {
  Stream<User?> get onAuthStateChanged;
  Future<User?> currentUser();
  Future<User> signInAnonymously();
  Future<void> signOut();
}

class Auth implements AuthBase {
  final _firebaseAuth = firebase_auth.FirebaseAuth.instance;

  User? _userFromFirebase(firebase_auth.User? firebaseUser) {
    if (firebaseUser == null) {
      return null;
    }
    return User(uid: firebaseUser.uid);
  }

  @override
  Stream<User?> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
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
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}