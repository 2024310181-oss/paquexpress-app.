import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services.dart';
import 'camara.dart';

class PaquetesPage extends StatefulWidget {
  @override
  _PaquetesPageState createState() => _PaquetesPageState();
}

class _PaquetesPageState extends State<PaquetesPage> {
  List<dynamic> _paquetes = [];
  bool _loading = true;
  String _nombreAgente = '';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    final idAgente = prefs.getInt('idAgente');
    _nombreAgente = prefs.getString('nombreAgente') ?? '';
    
    try {
      final response = await ApiService.getPaquetes(idAgente!);
      setState(() {
        _paquetes = response['paquetes'] ?? [];
        _loading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => _loading = false);
    }
  }

  void _seleccionarPaquete(Map<String, dynamic> paquete) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CamaraPage(paquete: paquete),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paquetes de $_nombreAgente'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _cargarDatos,
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _paquetes.isEmpty
              ? Center(child: Text('No hay paquetes asignados'))
              : ListView.builder(
                  itemCount: _paquetes.length,
                  itemBuilder: (context, index) {
                    final paquete = _paquetes[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        leading: Icon(Icons.add_box),
                        title: Text('Paquete: ${paquete['id_unico']}'),
                        subtitle: Text('Dest: ${paquete['destinatario']}'),
                        trailing: Icon(Icons.arrow_forward),
                        onTap: () => _seleccionarPaquete(paquete),
                      ),
                    );
                  },
                ),
    );
  }
}
