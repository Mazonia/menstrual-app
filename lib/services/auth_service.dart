import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      if (userCredential.user != null) {
        try {
          await userCredential.user!.updateDisplayName(name);
        } catch (e) {
          print('Error updating display name: $e');
          // Continue even if display name update fails
        }

        // Create user profile in Firestore with retry
        try {
          await _createUserProfile(userCredential.user!.uid, name, email);
        } catch (e) {
          print('Error creating user profile in Firestore: $e');
          // We'll still return the user credential even if Firestore fails
          // The profile can be created later
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, check if user already exists in Firestore
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        try {
          final userDoc =
              await _firestore
                  .collection('users')
                  .doc(userCredential.user!.uid)
                  .get();

          // If user doesn't exist, create profile
          if (!userDoc.exists) {
            await _createUserProfile(
              userCredential.user!.uid,
              userCredential.user!.displayName ?? 'User',
              userCredential.user!.email ?? '',
            );
          }
        } catch (e) {
          print('Error checking/creating user profile: $e');
          // Continue even if profile creation fails
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error signing in with Google: $e');
    }
  }

  // Create user profile in Firestore with retry logic
  Future<void> _createUserProfile(String uid, String name, String email) async {
    int retries = 3;

    while (retries > 0) {
      try {
        await _firestore.collection('users').doc(uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return; // Success, exit the function
      } catch (e) {
        retries--;
        print('Error creating user profile, retries left: $retries, error: $e');
        if (retries <= 0) {
          throw Exception(
            'Failed to create user profile after multiple attempts: $e',
          );
        }
        // Wait before retrying
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Firebase Auth first
      await _auth.signOut();

      // Then try to sign out from Google (if applicable)
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        print('Error signing out from Google: $e');
        // Continue even if Google sign out fails
      }
    } catch (e) {
      print('Error during sign out: $e');
      throw Exception('Error signing out: $e');
    }
  }

  // Update user display name
  Future<void> updateUserName(String name) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Update display name in Firebase Auth
      await user.updateDisplayName(name);

      // Update display name in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to update user name: $e');
    }
  }

  // Handle Firebase Auth exceptions
  Exception _handleAuthException(FirebaseAuthException e) {
    print('Firebase Auth Error: [${e.code}] ${e.message}');

    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email.');
      case 'wrong-password':
        return Exception('Incorrect password.');
      case 'email-already-in-use':
        return Exception('The email address is already in use.');
      case 'weak-password':
        return Exception('The password provided is too weak.');
      case 'invalid-email':
        return Exception('The email address is invalid.');
      case 'operation-not-allowed':
        return Exception(
          'This sign-in method is not enabled in Firebase Console.',
        );
      case 'user-disabled':
        return Exception('This user account has been disabled.');
      case 'requires-recent-login':
        return Exception('Please sign in again to complete this action.');
      case 'network-request-failed':
        return Exception(
          'Network error - please check your internet connection.',
        );
      case 'too-many-requests':
        return Exception('Too many attempts - please try again later.');
      default:
        return Exception('Authentication error: ${e.message}');
    }
  }
}
