import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000";
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
  };

  // Verificar sesión activa
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLogged') ?? false;
  }

  // Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('idAgente');
    await prefs.remove('nombreAgente');
    await prefs.remove('isLogged');
  }

  // Login con mejor manejo de errores
  static Future<Map<String, dynamic>> login(String usuario, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: headers,
        body: json.encode({
          'usuario': usuario.trim(),
          'password': password.trim(),
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false, 
          'error': 'Error del servidor: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false, 
        'error': 'Error de conexión: $e'
      };
    }
  }

  // Obtener paquetes con validación de sesión
  static Future<Map<String, dynamic>> getPaquetes(int idAgente) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/paquetes/$idAgente'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'paquetes': [], 
          'error': 'Error al cargar paquetes'
        };
      }
    } catch (e) {
      return {
        'paquetes': [], 
        'error': 'Error de conexión: $e'
      };
    }
  }

  // Registrar entrega con mejor manejo de errores
  static Future<Map<String, dynamic>> registrarEntrega(
    int idPaquete, 
    int idAgente, 
    String foto, 
    double latitud, 
    double longitud
  ) async {
    try {
      // Validar datos antes de enviar
      if (foto.isEmpty || latitud == 0.0 || longitud == 0.0) {
        return {
          'success': false, 
          'error': 'Datos incompletos para la entrega'
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/entregar'),
        headers: headers,
        body: json.encode({
          'id_paquete': idPaquete,
          'id_agente': idAgente,
          'foto': foto,
          'latitud': latitud,
          'longitud': longitud,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false, 
          'error': 'Error del servidor: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false, 
        'error': 'Error de conexión: $e'
      };
    }
  }
}