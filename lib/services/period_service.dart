import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/period_model.dart';

class PeriodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user ID or null if not authenticated
  String? get _userId => _auth.currentUser?.uid;

  // Check if user is logged in
  bool get isLoggedIn => _userId != null;

  // Reference to user's period data collection
  CollectionReference<Map<String, dynamic>> _getPeriodCollection() {
    if (_userId == null) {
      throw Exception('User must be authenticated to access period data');
    }
    return _firestore.collection('users').doc(_userId).collection('periods');
  }

  // Save period to Firestore
  Future<void> savePeriod(Period period) async {
    if (!isLoggedIn) return;

    try {
      await _getPeriodCollection()
          .doc(period.startDate.toIso8601String())
          .set(period.toJson());
    } catch (e) {
      throw Exception('Failed to save period data: $e');
    }
  }

  // Update period in Firestore
  Future<void> updatePeriod(Period period) async {
    if (!isLoggedIn) return;

    try {
      await _getPeriodCollection()
          .doc(period.startDate.toIso8601String())
          .update(period.toJson());
    } catch (e) {
      throw Exception('Failed to update period data: $e');
    }
  }

  // Delete period from Firestore
  Future<void> deletePeriod(DateTime startDate) async {
    if (!isLoggedIn) return;

    try {
      await _getPeriodCollection().doc(startDate.toIso8601String()).delete();
    } catch (e) {
      throw Exception('Failed to delete period data: $e');
    }
  }

  // Get all periods from Firestore
  Future<List<Period>> getAllPeriods() async {
    if (!isLoggedIn) return [];

    try {
      final snapshot =
          await _getPeriodCollection()
              .orderBy('startDate', descending: true)
              .get();
      return snapshot.docs.map((doc) => Period.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get period data: $e');
    }
  }

  // Stream of period data for real-time updates
  Stream<List<Period>> periodStream() {
    if (!isLoggedIn) {
      return Stream.value([]);
    }

    return _getPeriodCollection()
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Period.fromJson(doc.data()))
              .toList();
        });
  }

  // Save user settings (cycle length, period length)
  Future<void> saveUserSettings({
    required int cycleLength,
    required int periodLength,
  }) async {
    if (!isLoggedIn) return;

    try {
      await _firestore.collection('users').doc(_userId).update({
        'settings': {
          'cycleLength': cycleLength,
          'periodLength': periodLength,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      });
    } catch (e) {
      throw Exception('Failed to save user settings: $e');
    }
  }

  // Get user settings
  Future<Map<String, dynamic>?> getUserSettings() async {
    if (!isLoggedIn) return null;

    try {
      final doc = await _firestore.collection('users').doc(_userId).get();
      return doc.data()?['settings'] as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Failed to get user settings: $e');
    }
  }
}
