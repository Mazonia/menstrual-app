import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

class FirebaseConnectionTest extends StatefulWidget {
  const FirebaseConnectionTest({super.key});

  @override
  FirebaseConnectionTestState createState() => FirebaseConnectionTestState();
}

class FirebaseConnectionTestState extends State<FirebaseConnectionTest> {
  String _testResult = 'Testing Firebase connection...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _testFirebaseConnection();
  }

  Future<void> _testFirebaseConnection() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Test Firestore connection
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('test_connection').doc('test_doc').set({
        'timestamp': FieldValue.serverTimestamp(),
        'test': 'Connection test successful',
      });

      // Retrieve the test document
      final docSnapshot =
          await firestore.collection('test_connection').doc('test_doc').get();

      if (docSnapshot.exists) {
        setState(() {
          _testResult =
              'Firebase connection successful! Database is working correctly.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _testResult =
              'Firebase connection error: Document not found after writing.';
          _isLoading = false;
        });
      }

      // Clean up test document
      await firestore.collection('test_connection').doc('test_doc').delete();
    } catch (e) {
      setState(() {
        _testResult = 'Firebase connection error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Connection Test')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Text(
                  _testResult,
                  style: TextStyle(
                    color:
                        _testResult.contains('successful')
                            ? Colors.green
                            : Colors.red,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
