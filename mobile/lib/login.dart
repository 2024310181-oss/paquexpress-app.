import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services.dart';
import 'paquetes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _loading = true);
    
    final response = await ApiService.login(
      _userController.text, 
      _passController.text
    );
    
    if (response['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('idAgente', response['id']);
      await prefs.setString('nombreAgente', response['nombre']);
      await prefs.setBool('isLogged', true);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PaquetesPage()),
      );
    } else {
      _showError(response['error'] ?? 'Credenciales incorrectas');
    }
    
    setState(() => _loading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String? _validarUsuario(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu usuario';
    }
    return null;
  }

  String? _validarPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu contraseña';
    }
    if (value.length < 3) {
      return 'La contraseña debe tener al menos 3 caracteres';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paquexpress Login'),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_shipping,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                'Paquexpress',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _userController,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: _validarUsuario,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: _validarPassword,
              ),
              const SizedBox(height: 30),
              _loading 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text(
                      'Ingresar al Sistema',
                      style: TextStyle(fontSize: 16),
                      ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.green,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}