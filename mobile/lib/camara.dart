import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
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
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraReady = false;
  bool _loading = false;
  XFile? _imageFile;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _getCurrentLocation();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      _controller = CameraController(_cameras![0], ResolutionPreset.medium);
      
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _isCameraReady = true);
    } catch (e) {
      print('Error inicializando cámara: $e');
    }
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
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    try {
      XFile file = await _controller!.takePicture();
      setState(() => _imageFile = file);
    } catch (e) {
      print('Error tomando foto: $e');
    }
  }

  void _verMapa() {
    if (_currentPosition == null) return;
    
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
    if (_imageFile == null || _currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toma una foto y obtén la ubicación primero')),
      );
      return;
    }

    setState(() => _loading = true);
    
    try {
      // Convertir imagen a base64
      List<int> imageBytes = await File(_imageFile!.path).readAsBytes();
      String base64Image = base64Encode(imageBytes);
      
      final prefs = await SharedPreferences.getInstance();
      final idAgente = prefs.getInt('idAgente');
      
      // Registrar entrega
      final response = await ApiService.registrarEntrega(
        widget.paquete['id'],
        idAgente!,
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

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildCameraPreview() {
    if (!_isCameraReady || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return CameraPreview(_controller!);
  }

  Widget _buildImagePreview() {
    if (_imageFile == null) return const SizedBox();
    
    return Image.file(File(_imageFile!.path));
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
            
            // Vista de cámara
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _imageFile == null 
                  ? _buildCameraPreview()
                  : _buildImagePreview(),
            ),
            
            const SizedBox(height: 20),
            
            // Botones de control - CORREGIDO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _takePicture,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Tomar Foto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
                
                ElevatedButton.icon(
                  onPressed: _verMapa,
                  icon: const Icon(Icons.location_on),
                  label: const Text('Ver Ubicación'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
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
                    : Text('Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}\n'
                          'Lon: ${_currentPosition!.longitude.toStringAsFixed(6)}'),
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