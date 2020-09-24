import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<User> currentUser();
  Future<Map> signIn(String email, String password);
  Future<Map> createUser(String username, String email, String password);
  Future<void> signOut();
  Future<String> getEmail();
  Future<bool> isEmailVerified();
  Future<void> resetPassword(String email);
  Future<void> sendEmailVerification();
}

class AuthService implements BaseAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User> get authentication {
    return _auth.userChanges();
  }

  Future<Map> signIn(String email, String password) async {
    var responseMap = new Map();
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      responseMap["user"] = userCredential.user;
      responseMap["status"] = 'success';
      print(responseMap);
      return responseMap;
    } on FirebaseAuthException catch (e) {
      print('exception:' + e.toString());
      print('exception e.code:' + e.code);
      if (e.code == 'user-not-found') {
        responseMap["msg"] = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        responseMap["msg"] = 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        responseMap["msg"] = 'Invalid Email Id.';
      } else {
        responseMap["msg"] = 'Invalid Email Id Or Password.';
      }
      responseMap["status"] = 'failed';
      return responseMap;
    }
  }

  Future<Map> createUser(String username, String email, String password) async {
    var responseMap = new Map();
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user.updateProfile(displayName: username);
      await userCredential.user.reload();
      responseMap["user"] = userCredential.user;
      responseMap["status"] = 'success';
      return responseMap;
    } on FirebaseAuthException catch (e) {
      print('exception:' + e.toString());
      print('exception e.code:' + e.code);
      responseMap["msg"] = e.message;
      responseMap["status"] = 'failed';
      return responseMap;
    }
  }

  Future<User> currentUser() async {
    User user = await _auth.currentUser;
    return user != null ? user : null;
  }

  Future<void> signOut() async {
    return FirebaseAuth.instance.signOut();
  }

  Future<String> getEmail() async {
    User user = await _auth.currentUser;
    return user.email;
  }

  Future<bool> isEmailVerified() async {
    User user = await _auth.currentUser;
    return user.emailVerified;
  }

  Future<void> resetPassword(String email) async {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future sendEmailVerification() async {
    User user = await _auth.currentUser;
    return user.sendEmailVerification();
  }
}
