import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/match_model.dart';
import '../services/match_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MatchService _matchService = MatchService();
  GoogleMapController? _mapController;

  // Conjunto de marcadores que aparecerão no mapa
  Set<Marker> _markers = {};

  // Posição inicial (Barigui)
  static const _initialPosition = CameraPosition(
    target: LatLng(-25.4248, -49.3101),
    zoom: 14.0,
  );

  void _showMatchDetails(MatchModel match) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ajusta ao tamanho do conteúdo
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(match.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.sports_soccer, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  Text(match.sportName, style: const TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Expanded(child: Text(match.addressName)),
                ],
              ),
              const Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("💰 R\$ ${match.entryFee?.toStringAsFixed(2) ?? '0.00'}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ElevatedButton(
                    onPressed: () {
                      // Futuro: Lógica de inscrição (RabbitMQ)
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Inscrição solicitada!")),
                      );
                    },
                    child: const Text("Participar"),
                  )
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Função para buscar partidas da API e transformar em Markers
  Future<void> _fetchMatches(double lat, double lng) async {
    final matches = await _matchService.getNearbyMatches(lat: lat, lng: lng);

    setState(() {
      _markers = matches.map((match) {
        return Marker(
          markerId: MarkerId(match.id ?? DateTime.now().toString()),
          position: match.location,
          onTap: () {
            _showMatchDetails(match); // 👈 Chama o modal ao clicar
          },
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        );
      }).toSet();
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se o GPS está ligado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    // Pega a posição atual
    Position position = await Geolocator.getCurrentPosition();

    // Move a câmera do mapa para você
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ),
    );

    // Busca as partidas ao seu redor (5km)
    _fetchMatches(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vibe - Partidas em Curitiba'),
        backgroundColor: Colors.blueAccent,
      ),
      body: GoogleMap(
        initialCameraPosition: _initialPosition,
        markers: _markers,
        myLocationEnabled: true, // Mostra a bolinha azul no mapa
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          _determinePosition(); // 👈 Agora é dinâmico!
        },
      ),
      // Botão para atualizar manualmente (bom para testes)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _fetchMatches(-25.4248, -49.3101),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}