import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vibe_app/core/di/service_locator.dart';
import 'package:vibe_app/core/network/dio_client.dart';
import 'package:vibe_app/screens/login_screen.dart';
import 'package:vibe_app/services/auth_service.dart';
import 'core/routes/routes_generator.dart';
import 'firebase_options.dart';
import 'screens/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupServiceLocator();

  runApp(const VibeApp());
}

class VibeApp extends StatelessWidget {
  const VibeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibe Sports',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: getIt<AuthService>().user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (kDebugMode && getIt<DioClient>().impersonateUid != null && getIt<DioClient>().impersonateUid!.isNotEmpty) {
           return const MapScreen();
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: snapshot.hasData ? const MapScreen() : const LoginScreen(),
        );
      },
    );
  }
}
