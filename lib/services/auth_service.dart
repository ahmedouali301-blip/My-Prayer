import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email and password
  Future<String?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await userCredential.user?.updateDisplayName(fullName);
      
      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'fullName': fullName,
        'createdAt': FieldValue.serverTimestamp(),
        'location': 'Sfax, Tunisie',
      });
      
      // Create personal prayer data for the user
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .collection('myprayer')
          .doc('data')
          .set({
        'currentPrayer': 'Waqtu Dhuhr',
        'currentTime': '9:41',
        'location': 'Sfax, Tunisie',
        'prayerTimes': {
          'Fajr': '05:30',
          'Chourouq': '06:40',
          'Dhuhr': '12:15',
          'Asr': '15:45',
          'Maghrib': '18:20',
          'Isha': '19:45',
        }
      });
      
      notifyListeners();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return 'Une erreur est survenue. Veuillez réessayer.';
    }
  }

  // Sign in with email and password
  Future<String?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return 'Une erreur est survenue. Veuillez réessayer.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  // Reset password
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return 'Une erreur est survenue. Veuillez réessayer.';
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser == null) return null;
    
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet email.';
      case 'invalid-email':
        return 'L\'adresse email est invalide.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'too-many-requests':
        return 'Trop de tentatives. Veuillez réessayer plus tard.';
      case 'operation-not-allowed':
        return 'L\'authentification par email n\'est pas activée.';
      case 'requires-recent-login':
        return 'Cette opération nécessite une connexion récente. Veuillez vous reconnecter.';
      default:
        return 'Une erreur est survenue: ${e.message}';
    }
  }

  // Public method to get error message
  String getErrorMessage(String error) {
    if (error.contains('wrong-password')) {
      return 'Mot de passe incorrect.';
    } else if (error.contains('requires-recent-login')) {
      return 'Cette opération nécessite une connexion récente. Veuillez vous reconnecter.';
    } else if (error.contains('email-already-in-use')) {
      return 'Cet email est déjà utilisé par un autre compte.';
    }
    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  // Update display name
  Future<void> updateDisplayName(String displayName) async {
    if (currentUser == null) throw Exception('Utilisateur non connecté');
    
    await currentUser!.updateDisplayName(displayName);
    
    // Update in Firestore
    await _firestore.collection('users').doc(currentUser!.uid).update({
      'fullName': displayName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    notifyListeners();
  }

  // Delete account
  Future<void> deleteAccount() async {
    if (currentUser == null) throw Exception('Utilisateur non connecté');
    
    final uid = currentUser!.uid;
    
    // Delete user data from Firestore
    await _firestore.collection('users').doc(uid).delete();
    
    // Delete user's prayer data
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('myprayer')
        .doc('data')
        .delete();
    
    // Delete the user account
    await currentUser!.delete();
    
    notifyListeners();
  }
}