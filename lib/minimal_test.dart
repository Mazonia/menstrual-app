import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MinimalTestApp());
}

class MinimalTestApp extends StatelessWidget {
  const MinimalTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minimal Firebase Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const MinimalTestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MinimalTestScreen extends StatefulWidget {
  const MinimalTestScreen({super.key});

  @override
  State<MinimalTestScreen> createState() => _MinimalTestScreenState();
}

class _MinimalTestScreenState extends State<MinimalTestScreen> {
  bool _isInitialized = false;
  bool _isConnected = false;
  String _statusMessage = 'Initializing...';
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      _addLog('Initializing Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _addLog('Firebase initialized');
      setState(() {
        _isInitialized = true;
        _statusMessage = 'Firebase initialized successfully';
      });
    } catch (e) {
      _addLog('Error initializing Firebase: $e');
      setState(() {
        _isInitialized = false;
        _statusMessage = 'Firebase initialization failed: $e';
      });
      return;
    }
  }

  Future<void> _testConnection() async {
    if (!_isInitialized) {
      _addLog('Firebase not initialized yet');
      return;
    }

    setState(() {
      _statusMessage = 'Testing connection...';
    });

    try {
      _addLog('Testing Firestore write...');
      await FirebaseFirestore.instance
          .collection('test_connection')
          .doc('test_doc')
          .set({
            'timestamp': FieldValue.serverTimestamp(),
            'message': 'Test successful',
          });
      _addLog('Write successful');

      _addLog('Testing Firestore read...');
      final doc =
          await FirebaseFirestore.instance
              .collection('test_connection')
              .doc('test_doc')
              .get();

      if (doc.exists) {
        _addLog('Read successful');
        setState(() {
          _isConnected = true;
          _statusMessage = 'Firebase is connected!';
        });
      } else {
        _addLog('Document not found');
        setState(() {
          _isConnected = false;
          _statusMessage = 'Document not found after writing';
        });
      }

      _addLog('Cleaning up test document...');
      await FirebaseFirestore.instance
          .collection('test_connection')
          .doc('test_doc')
          .delete();
      _addLog('Test document deleted');
    } catch (e) {
      _addLog('Error during test: $e');
      setState(() {
        _isConnected = false;
        _statusMessage = 'Connection test failed: $e';
      });
    }
  }

  void _addLog(String log) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $log');
    });
    print(log);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Test'),
        backgroundColor: _isConnected ? Colors.green : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      _isConnected
                          ? Icons.check_circle
                          : (_isInitialized ? Icons.help : Icons.error),
                      color:
                          _isConnected
                              ? Colors.green
                              : (_isInitialized ? Colors.orange : Colors.red),
                      size: 50,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            _isConnected
                                ? Colors.green.shade800
                                : (_isInitialized
                                    ? Colors.orange.shade800
                                    : Colors.red.shade800),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isInitialized ? _testConnection : null,
              child: const Text('Test Database Connection'),
            ),
            const SizedBox(height: 16),
            const Text('Logs:'),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    return Text(
                      _logs[index],
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
