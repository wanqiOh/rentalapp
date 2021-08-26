import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rentalapp/dialog/dialog.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  // static Future<UserCredential> signInWithFacebook() async {
  //   // Trigger the sign-in flow
  //   final LoginResult result = await FacebookAuth.instance.login();
  //
  //   // Create a credential from the access token
  //   final FacebookAuthCredential facebookAuthCredential =
  //       FacebookAuthProvider.credential(result.accessToken.token);
  //
  //   // Once signed in, return the UserCredential
  //   return await FirebaseAuth.instance
  //       .signInWithCredential(facebookAuthCredential);
  // }
  //
  // static Future<UserCredential> signInWithGoogle() async {
  //   // Trigger the authentication flow
  //   final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
  //
  //   // Obtain the auth details from the request
  //   final GoogleSignInAuthentication googleAuth =
  //       await googleUser.authentication;
  //
  //   // Create a new credential
  //   final GoogleAuthCredential credential = GoogleAuthProvider.credential(
  //     accessToken: googleAuth.accessToken,
  //     idToken: googleAuth.idToken,
  //   );
  //
  //   // Once signed in, return the UserCredential
  //   return await FirebaseAuth.instance.signInWithCredential(credential);
  // }

  static Future<UserCredential> signUpWithEmailAndPassword(
      BuildContext context, String _email, String _password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      if (userCredential.user.emailVerified) {
        return userCredential;
      } else {
        try {
          await userCredential.user.sendEmailVerification();
          return userCredential;
        } catch (e) {
          print("An error occured while trying to send email verification");
          print(e.message);
        }
      }
    } on FirebaseAuthException catch (e) {
      print('code from created: ${e.code}');
    } catch (e) {
      print(e);
    }
  }

  static Future<UserCredential> signInWithEmailAndPassword(
      BuildContext context, String _email, String _password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      // print('User credential: ${userCredential}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      if (e.message != null) {
        Dialogs.showMessage(context,
            content: Text('${e.code.toUpperCase()} for this registered email'));
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
