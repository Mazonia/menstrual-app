import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Build status information
  String status = 'Connecting to Firebase...';
  bool isConnected = false;

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    status = 'Firebase connected successfully!';
    isConnected = true;
  } catch (e) {
    status = 'Firebase connection error: $e';
    print(status);
  }

  // Run the app with the connection status
  runApp(SimpleTestApp(status: status, isConnected: isConnected));
}

class SimpleTestApp extends StatelessWidget {
  final String status;
  final bool isConnected;

  const SimpleTestApp({
    super.key,
    required this.status,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Firebase Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Firebase Connection'),
          backgroundColor: isConnected ? Colors.green : Colors.red,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isConnected ? Icons.check_circle : Icons.error,
                  color: isConnected ? Colors.green : Colors.red,
                  size: 80,
                ),
                const SizedBox(height: 30),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        isConnected
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
