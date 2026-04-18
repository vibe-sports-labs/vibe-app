import 'package:flutter/material.dart';
import 'package:vibe_app/screens/login_screen.dart';
import 'package:vibe_app/screens/map_screen.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.map:
        return MaterialPageRoute(builder: (_) => const MapScreen());


      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: const Center(child: Text('Página não encontrada!')),
      );
    });
  }
}