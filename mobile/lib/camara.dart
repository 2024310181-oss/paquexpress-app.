import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';  // ← NUEVO IMPORT
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services.dart';
import 'mapa.dart';

class CamaraPage extends StatefulWidget {
  final Map<String, dynamic> paquete;
  
  const CamaraPage({Key? key, required this.paquete}) : super(key: key);
  
  @override
  _CamaraPageState createState() => _CamaraPageState();
}

class _CamaraPageState extends State<CamaraPage> {
  bool _loading = false;
  Uint8List? _imageBytes;
  Position? _currentPosition;
  final ImagePicker _picker = ImagePicker();  // ← NUEVO

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activa el GPS para continuar')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() => _currentPosition = position);
    } catch (e) {
      print('Error obteniendo ubicación: $e');
    }
  }

  Future<void> _takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        if (mounted) {
          setState(() => _imageBytes = bytes);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto tomada exitosamente')),
          );
        }
      }
    } catch (e) {
      print('Error tomando foto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al tomar foto: $e')),
      );
    }
  }

  // ... el resto del código se mantiene igual
  void _verMapa() {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ubicación no disponible')),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapaPage(
          latitud: _currentPosition!.latitude,
          longitud: _currentPosition!.longitude,
          direccion: widget.paquete['direccion'],
        ),
      ),
    );
  }

  Future<void> _confirmarEntrega() async {
    if (_imageBytes == null || _currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toma una foto y obtén la ubicación primero')),
      );
      return;
    }

    setState(() => _loading = true);
    
    try {
      // Convertir imagen a base64
      String base64Image = base64Encode(_imageBytes!);
      
      final prefs = await SharedPreferences.getInstance();
      final idAgente = prefs.getInt('idAgente');
      
      if (idAgente == null) {
        throw Exception('No se encontró el ID del agente');
      }
      
      // Registrar entrega
      final response = await ApiService.registrarEntrega(
        widget.paquete['id'],
        idAgente,
        base64Image,
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Entrega registrada exitosamente!')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Error en el servidor: ${response['error']}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
    
    setState(() => _loading = false);
  }

  Widget _buildImagePreview() {
    if (_imageBytes != null) {
      return Image.memory(
        _imageBytes!,
        height: 300,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 50, color: Colors.grey[600]),
            const SizedBox(height: 10),
            Text(
              'Presiona "Tomar Foto" para capturar la evidencia',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entrega: ${widget.paquete['id_unico']}'),
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Info del paquete
            Card(
              child: ListTile(
                leading: const Icon(Icons.add_box, color: Colors.blue),
                title: Text('Paquete: ${widget.paquete['id_unico']}'),
                subtitle: Text(widget.paquete['direccion']),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Vista de imagen
            _buildImagePreview(),
            
            const SizedBox(height: 20),
            
            // Botones de control
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _takePicture,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Tomar Foto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                
                ElevatedButton.icon(
                  onPressed: _verMapa,
                  icon: const Icon(Icons.location_on),
                  label: const Text('Ver Ubicación'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ], 
            ),
            
            const SizedBox(height: 20),
            
            // Info GPS
            Card(
              child: ListTile(
                leading: const Icon(Icons.gps_fixed, color: Colors.red),
                title: const Text('Ubicación GPS'),
                subtitle: _currentPosition == null
                    ? const Text('Obteniendo ubicación...')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}'),
                          Text('Lon: ${_currentPosition!.longitude.toStringAsFixed(6)}'),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Botón de entrega
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _confirmarEntrega,
                    child: const Text(
                      'CONFIRMAR ENTREGA', 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
