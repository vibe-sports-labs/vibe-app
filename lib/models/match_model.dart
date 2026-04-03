import 'package:google_maps_flutter/google_maps_flutter.dart';

class MatchModel {
  final String? id;
  final String title;
  final String organizerId;
  final String sportName; // Pegando do nosso Sport dinâmico
  final LatLng location;
  final String addressName;
  final DateTime startDateTime;
  final int maxPlayers;
  final int currentPlayersCount;
  final double? entryFee;
  final String status;

  MatchModel({
    this.id,
    required this.title,
    required this.organizerId,
    required this.sportName,
    required this.location,
    required this.addressName,
    required this.startDateTime,
    required this.maxPlayers,
    required this.currentPlayersCount,
    this.entryFee,
    required this.status,
  });

  // Factory para transformar o JSON da sua API Spring no Objeto do Flutter
  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'],
      title: json['title'] ?? '',
      organizerId: json['organizerId'] ?? '',
      sportName: json['sport'] != null ? json['sport']['name'] : 'Esporte',
      // No Spring, o GeoJsonPoint envia x (longitude) e y (latitude)
      location: LatLng(
        json['location']['y'].toDouble(),
        json['location']['x'].toDouble(),
      ),
      addressName: json['addressName'] ?? '',
      startDateTime: DateTime.parse(json['startDateTime']),
      maxPlayers: json['maxPlayers'] ?? 0,
      // Contamos o tamanho da lista currentPlayers que vem do Kotlin
      currentPlayersCount: (json['currentPlayers'] as List).length,
      entryFee: json['entryFee']?.toDouble(),
      status: json['status'] ?? 'OPEN',
    );
  }
}