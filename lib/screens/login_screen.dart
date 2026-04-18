import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vibe_app/core/routes/app_routes.dart';
import '../core/di/service_locator.dart';
import '../core/network/dio_client.dart';
import '../services/auth_service.dart';
import 'package:logger/logger.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = getIt<AuthService>();
  final _logger = getIt<Logger>();
  bool _isLoading = false;

  int _logoClickCount = 0;

  void _handleLogoClick() {
    if (!kDebugMode) return;

    _logoClickCount++;
    if (_logoClickCount >= 5) {
      _logoClickCount = 0;
      _showImpersonationDialog();
    }
  }

  void _showImpersonationDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Modo Impersonation (DEBUG)"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Insira o UID do usuário"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              _logger.w("🕵️ Simulando usuário: ${controller.text}");
              getIt<DioClient>().setImpersonationUid(controller.text);

              _logger.i("🔥 Login realizado: ${controller.text}");
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Modo Impersonation ativado")),
              );
              Navigator.pushReplacementNamed(context, AppRoutes.map);
            },
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final userCredential = await _authService.signInWithGoogle();
      
      if (!mounted) return;

      if (userCredential != null) {
        _logger.i("🔥 Login realizado: ${userCredential.user?.email}");
        Navigator.pushReplacementNamed(context, AppRoutes.map);
      }
    } catch (e) {
      _logger.e("❌ Falha no login", error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao entrar com Google. Tente novamente.")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.greenAccent.withOpacity(0.1),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _handleLogoClick,
                      child: const Icon(Icons.sports_soccer, size: 80, color: Colors.greenAccent),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "VIBE SPORTS LAB",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const Text(
                      "Sua performance começa aqui",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 60),
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.greenAccent)
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _handleGoogleLogin,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.network(
                                    'https://www.svgrepo.com/show/475656/google-color.svg',
                                    height: 24,
                                    placeholderBuilder: (context) => const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Flexible(
                                    child: Text(
                                      "Entrar com Google",
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
