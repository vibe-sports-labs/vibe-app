import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_app/services/match_service.dart';
import '../../services/auth_service.dart';
import '../network/dio_client.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Core
  getIt.registerSingleton<Logger>(
    Logger(
      filter: ProductionFilter(),
      level: kDebugMode ? Level.all : Level.off,
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
      ),
    ),
  );

  getIt.registerSingleton<DioClient>(DioClient());
  getIt.registerLazySingleton<AuthService>(() => AuthService());

  // Business Services
  getIt.registerLazySingleton<MatchService>(() => MatchService());
}
