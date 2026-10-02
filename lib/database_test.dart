import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DatabaseTestApp());
}

class DatabaseTestApp extends StatelessWidget {
  const DatabaseTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Database Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const FirebaseInitializer(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FirebaseInitializer extends StatelessWidget {
  const FirebaseInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize Firebase first
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        // Show loading during initialization
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing Firebase...'),
                ],
              ),
            ),
          );
        }

        // Show error if initialization failed
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Firebase Error'),
              backgroundColor: Colors.red,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Failed to initialize Firebase: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        // Firebase is initialized, now we can show the test screen
        return const DatabaseTestScreen();
      },
    );
  }
}

class DatabaseTestScreen extends StatefulWidget {
  const DatabaseTestScreen({super.key});

  @override
  State<DatabaseTestScreen> createState() => _DatabaseTestScreenState();
}

class _DatabaseTestScreenState extends State<DatabaseTestScreen> {
  String _status = 'Testing database connection...';
  bool _isLoading = true;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    try {
      // Test Firestore connection
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      print('Firebase instance obtained');

      try {
        print('Attempting to write test document');
        await firestore.collection('test_connection').doc('test_doc').set({
          'timestamp': FieldValue.serverTimestamp(),
          'test': 'Connection test successful',
        });
        print('Test document write successful');
      } catch (writeError) {
        print('Error writing to Firestore: $writeError');
        setState(() {
          _status = 'Error writing to database: $writeError';
          _isLoading = false;
        });
        return;
      }

      try {
        print('Attempting to read test document');
        final doc =
            await firestore.collection('test_connection').doc('test_doc').get();
        print('Test document read: ${doc.exists}');

        try {
          print('Attempting to delete test document');
          await firestore
              .collection('test_connection')
              .doc('test_doc')
              .delete();
          print('Test document deleted');
        } catch (e) {
          print('Error deleting document: $e');
        }

        if (doc.exists) {
          setState(() {
            _status =
                'Database connection successful! ✅\n\nYour Firebase database is working correctly.';
            _isLoading = false;
            _isConnected = true;
          });
        } else {
          setState(() {
            _status = 'Error: Document created but couldn\'t be read.';
            _isLoading = false;
          });
        }
      } catch (readError) {
        print('Error reading from Firestore: $readError');
        setState(() {
          _status = 'Error reading from database: $readError';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('General error in test connection: $e');
      setState(() {
        _status = 'Error connecting to Firebase: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Database Test'),
        backgroundColor: _isConnected ? Colors.green : null,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                )
              else
                Icon(
                  _isConnected ? Icons.check_circle : Icons.error,
                  color: _isConnected ? Colors.green : Colors.red,
                  size: 80,
                ),
              const SizedBox(height: 30),
              Text(
                _status,
                style: TextStyle(
                  fontSize: 16,
                  color:
                      _isConnected
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              if (!_isConnected && !_isLoading) ...[
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _status = 'Retrying connection...';
                    });
                    _testConnection();
                  },
                  child: const Text('Retry Connection'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
