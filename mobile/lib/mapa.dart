import 'package:flutter/material.dart';

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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación de Entrega'),
        backgroundColor: Colors.blue[700],
      ),
      body: Column(
        children: [
          // Información de la dirección
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    direccion,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          
          // Mapa simulado (sin dependencias externas)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.map_outlined,
                    size: 100,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ubicación de Entrega',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Latitud: ${latitud.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Longitud: ${longitud.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '✅ Entrega registrada en esta ubicación\n\n'
                      'Nota: La funcionalidad completa de mapas\n'
                      'se implementará en la siguiente versión.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}