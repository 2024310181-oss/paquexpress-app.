import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapaPage extends StatelessWidget {
  final double latitud;
  final double longitud;
  final String direccion;
  
  const MapaPage({
    Key? key,
    required this.latitud,
    required this.longitud,
    required this.direccion,
  }) : super(key: key);

  Future<void> _abrirMapaExterno() async {
    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitud,$longitud';
    final String appleMapsUrl = 'https://maps.apple.com/?q=$latitud,$longitud';
    
    try {
      // Intentar con Google Maps primero
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl));
      } 
      // Si no funciona, intentar con Apple Maps
      else if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
        await launchUrl(Uri.parse(appleMapsUrl));
      } 
      // Como última opción, usar OpenStreetMap
      else {
        final String osmUrl = 'https://www.openstreetmap.org/?mlat=$latitud&mlon=$longitud#map=15/$latitud/$longitud';
        if (await canLaunchUrl(Uri.parse(osmUrl))) {
          await launchUrl(Uri.parse(osmUrl));
        } else {
          throw 'No se pudo abrir ningún servicio de mapas';
        }
      }
    } catch (e) {
      print('Error abriendo mapa: $e');
    }
  }

  Widget _buildMapPreview() {
    return GestureDetector(
      onTap: _abrirMapaExterno,
      child: Container(
        height: 200,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Mapa simulado con icono
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_pin,
                    size: 60,
                    color: Colors.red[700],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'TOCA PARA VER EN MAPA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            
            // Coordenadas en esquina
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${latitud.toStringAsFixed(4)}, ${longitud.toStringAsFixed(4)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[700], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Ubicación verificada',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '• Coordenadas GPS validadas\n'
            '• Listo para registrar entrega\n'
            '• Toca el mapa para ver la ubicación exacta',
            style: TextStyle(
              fontSize: 14,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación de Entrega'),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: _abrirMapaExterno,
            tooltip: 'Abrir en Maps',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información de la dirección
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dirección de entrega:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        direccion,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Coordenadas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.gps_fixed, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Coordenadas:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${latitud.toStringAsFixed(6)}, ${longitud.toStringAsFixed(6)}',
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Mapa interactivo
          _buildMapPreview(),
          
          const SizedBox(height: 20),
          
          // Botón de acción principal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: _abrirMapaExterno,
              icon: const Icon(Icons.map),
              label: const Text('ABRIR EN GOOGLE MAPS'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Información de estado
          _buildInfoCard(),
        ],
      ),
    );
  }
}
