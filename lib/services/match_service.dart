import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:vibe_app/core/di/service_locator.dart';
import '../core/network/dio_client.dart';
import '../models/match_model.dart';

class MatchService {
  final _dio = getIt<DioClient>().instance;
  final Logger _logger = getIt<Logger>();

  Future<List<MatchModel>> getNearbyMatches({
    required double lat,
    required double lng,
    double distanceMeters = 5000,
  }) async {
    try {
      final response = await _dio.get(
        '/v1/matches/nearby',
        queryParameters: {
          'latitude': lat,
          'longitude': lng,
          'distanceMeters': distanceMeters,
        }
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => MatchModel.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      _logger.e("Erro ao buscar partidas próximas: ${e.message}");
    }
    return [];
  }

  // Método para criar uma partida (POST) direto do App
  Future<MatchModel?> createMatch(MatchModel match) async {
    try {
      // Aqui o Dio converte o MatchModel automaticamente se você tiver o toJson()
      // Por enquanto, vamos focar na busca para ver os pins no mapa.
      return null;
    } catch (e) {
      _logger.e("❌ Erro ao criar partida: $e");
      return null;
    }
  }
}