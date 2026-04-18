import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_app/services/auth_service.dart';

import '../constants.dart';
import '../di/service_locator.dart';

class DioClient {
  final _prefs = getIt<SharedPreferences>();
  final Dio _dio = Dio();
  AuthService get _authService => getIt<AuthService>();
  final Logger _logger = getIt<Logger>();

  String? get impersonateUid {
    return _prefs.getString('impersonate_uid');
  }

  void setImpersonationUid(String? uid) {
    if (uid != null && uid.isNotEmpty) {
      _prefs.setString('impersonate_uid', uid);
    } else {
      _prefs.remove('impersonate_uid');
    }
  }

  DioClient() {
    _dio.options =  BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _authService.getIdToken();

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        if (kDebugMode && impersonateUid != null && impersonateUid!.isNotEmpty) {
          options.headers['X-Impersonate-User'] = impersonateUid;
        }

        _logger.d("Requisição: ${options.method} ${options.path}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.d("Resposta: ${response.statusCode} ${response.requestOptions.path}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (e.type == DioExceptionType.connectionTimeout) {
          _logger.f("Erro: O servidor demorou muito para responder (Timeout)");
        } else {
          _logger.e("Erro: ${e.message}");
        }
        return handler.next(e);
      },
    ));
  }

  Dio get instance => _dio;
}
