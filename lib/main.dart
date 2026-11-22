import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (AppConfig.firebaseConfigured) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: AppConfig.firebaseApiKey,
        appId: AppConfig.firebaseAppId,
        messagingSenderId: AppConfig.firebaseMessagingSenderId,
        projectId: AppConfig.firebaseProjectId,
        storageBucket: AppConfig.firebaseStorageBucket.isEmpty
            ? null
            : AppConfig.firebaseStorageBucket,
        iosBundleId: AppConfig.firebaseIosBundleId.isEmpty
            ? null
            : AppConfig.firebaseIosBundleId,
      ),
    );
  }
  runApp(const ProviderScope(child: RmBreedingApp()));
}
