import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    debugPrint('[main] Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('[main] Firebase initialized successfully');
  } catch (e, stack) {
    debugPrint('[main] Firebase init FAILED: $e');
    debugPrint('[main] Stack: $stack');
  }

  runApp(
    const ProviderScope(
      child: NumCricketApp(),
    ),
  );
}
