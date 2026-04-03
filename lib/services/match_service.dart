import 'package:dio/dio.dart';
import '../models/match_model.dart';
import '../core/constants.dart';

class MatchService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // Busca partidas próximas usando as coordenadas do GPS
  Future<List<MatchModel>> getNearbyMatches({
    required double lat,
    required double lng,
    double distanceMeters = 5000, // Raio de 5km (Padrão Curitiba)
  }) async {
    try {
      final response = await _dio.get(
        '/matches/nearby',
        queryParameters: {
          'latitude': lat,
          'longitude': lng,
          'distanceMeters': distanceMeters,
        }
      );

      print("✅ Status Code: ${response.statusCode}");
      print("📦 Dados Recebidos: ${response.data}");

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        // Mapeia o JSON para a nossa MatchModel.dart
        return data.map((json) => MatchModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      // Como referência técnica, trate os erros de rede de forma clara
      print("❌ Erro na API Vibe: ${e.message}");
      if (e.type == DioExceptionType.connectionError) {
        print("⚠️ Verifique se o Spring Boot está rodando no IntelliJ!");
      }
      return [];
    }
  }

  // Método para criar uma partida (POST) direto do App
  Future<MatchModel?> createMatch(MatchModel match) async {
    try {
      // Aqui o Dio converte o MatchModel automaticamente se você tiver o toJson()
      // Por enquanto, vamos focar na busca para ver os pins no mapa.
      return null;
    } catch (e) {
      print("❌ Erro ao criar partida: $e");
      return null;
    }
  }
}