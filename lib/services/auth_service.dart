import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow with a timeout
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Google Sign-In timed out. Check your Internet or SHA-1 key.');
        },
      );
      
      if (googleUser == null) {
        return null; // The user canceled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Check if user exists and save data if new
      await _saveUserData(userCredential.user);
      
      return userCredential;
    } catch (e) {
      // Use debugPrint to ensure it shows up in all environments
      print("GOOGLE SIGN-IN ERROR: $e"); 
      return null;
    }
  }

  // Save user data to Firestore
  Future<void> _saveUserData(User? user) async {
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);

    try {
      // Check if user exists
      final docSnapshot = await userRef.get();

      if (!docSnapshot.exists) {
        // New user - create record
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'userType': 'student', // Default to student, can be changed later
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Existing user - update login time
        await userRef.update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("Error saving user data: $e");
    }
  }

  // Sign up with Email & Password
  Future<UserCredential?> signUpWithEmail(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await userCredential.user?.updateDisplayName(name);
      
      // Save user data to Firestore
      await _saveUserData(userCredential.user);
      
      return userCredential;
    } catch (e) {
      print("EMAIL SIGN-UP ERROR: $e");
      return null;
    }
  }

  // Sign in with Email & Password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update last login
      await _saveUserData(userCredential.user);
      
      return userCredential;
    } catch (e) {
      print("EMAIL SIGN-IN ERROR: $e");
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
