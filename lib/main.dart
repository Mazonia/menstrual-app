import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Import for runZonedGuarded
import 'firebase_options.dart';
import 'providers/period_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_wrapper.dart';
import 'utils/notification_service.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Catch any errors during app startup
  runZonedGuarded(
    () async {
      bool isFirebaseConnected = false;

      try {
        // Initialize Firebase with the generated options
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );

        // Flag that Firebase is connected
        isFirebaseConnected = true;

        // Initialize notification service
        try {
          final notificationService = NotificationService();
          await notificationService.initialize();
        } catch (e) {
          print('Notification service initialization error: $e');
          // Continue even if notifications fail
        }
      } catch (e) {
        // Log the error but continue
        print('Firebase initialization error: $e');
      }

      // Run the app regardless of whether Firebase initialization succeeded
      runApp(MyApp(isFirebaseConnected: isFirebaseConnected));
    },
    (error, stack) {
      // Log any errors that occur during startup
      print('Uncaught error in main: $error');
      print(stack);
    },
  );
}

// Remove the test Firebase connection function as it might be causing issues
// Future<bool> testFirebaseConnection() async {
//   try {
//     // Test Firestore connection
//     FirebaseFirestore firestore = FirebaseFirestore.instance;
//     await firestore.collection('test_connection').doc('test_doc').set({
//       'timestamp': FieldValue.serverTimestamp(),
//       'test': 'Connection test successful',
//     });

//     // Retrieve the test document
//     final docSnapshot =
//         await firestore.collection('test_connection').doc('test_doc').get();

//     // Clean up test document
//     await firestore.collection('test_connection').doc('test_doc').delete();

//     return docSnapshot.exists;
//   } catch (e) {
//     print('Firebase connection error: $e');
//     return false;
//   }
// }

class MyApp extends StatelessWidget {
  final bool isFirebaseConnected;

  const MyApp({super.key, required this.isFirebaseConnected});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (context) => PeriodProvider()..initialize(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Period Tracker',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            // Show splash screen first, then navigate to the auth wrapper
            home: const SplashScreen(),
            routes: {'/auth': (context) => const AuthWrapper()},
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
