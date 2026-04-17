import 'package:flutter/material.dart';
import 'servicio_nasa.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PantallaEventos(),
  ));
}

class PantallaEventos extends StatefulWidget {
  const PantallaEventos({super.key});

  @override
  State<PantallaEventos> createState() => _PantallaEventosState();
}

class _PantallaEventosState extends State<PantallaEventos> {
  final servicio = ServicioNasa();
  
  String filtroCategoria = 'todos'; 
  String filtroContinente = 'todos'; 

  List<dynamic> listaDeCategorias = []; 

  @override
  void initState() {
    super.initState();
    _descargarCategorias();
  }

  Future<void> _descargarCategorias() async {
    final categoriasDescargadas = await servicio.obtenerCategorias();
    setState(() {
      listaDeCategorias = categoriasDescargadas;
    });
  }

  void recargarDatos() {
    setState(() {});
  }

  Widget _obtenerIcono(String categoriaId) {
    switch (categoriaId) {
      case 'wildfires': return const Icon(Icons.local_fire_department, color: Colors.red, size: 30);
      case 'volcanoes': return const Icon(Icons.terrain, color: Colors.deepOrange, size: 30);
      case 'severeStorms': return const Icon(Icons.thunderstorm, color: Colors.blueGrey, size: 30);
      case 'earthquakes': return const Icon(Icons.vibration, color: Colors.brown, size: 30);
      case 'floods': return const Icon(Icons.water, color: Colors.blue, size: 30);
      case 'snow':
      case 'seaLakeIce': return const Icon(Icons.ac_unit, color: Colors.lightBlue, size: 30);
      case 'drought': return const Icon(Icons.wb_sunny, color: Colors.orangeAccent, size: 30);
      case 'tempExtremes': return const Icon(Icons.thermostat, color: Colors.redAccent, size: 30);
      case 'dustHaze': return const Icon(Icons.blur_on, color: Colors.grey, size: 30);
      case 'landslides': return const Icon(Icons.landslide, color: Colors.brown, size: 30);
      default: return const Icon(Icons.warning_amber, color: Colors.orange, size: 30);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitor NASA'),
        backgroundColor: Colors.deepPurple[100],
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.public), 
            tooltip: 'Filtrar por Continente',
            onSelected: (String nuevoContinente) {
              setState(() {
                filtroContinente = nuevoContinente;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'todos', child: Text('Todo el mundo')),
              const PopupMenuItem(value: '-168,15,-52,72', child: Text('América del Norte')),
              const PopupMenuItem(value: '-82,-56,-34,13', child: Text('América del Sur')),
              const PopupMenuItem(value: '-10,35,40,71', child: Text('Europa')),
              const PopupMenuItem(value: '-18,-35,52,38', child: Text('África')),
              const PopupMenuItem(value: '40,5,180,75', child: Text('Asia')),
              const PopupMenuItem(value: '110,-47,180,-10', child: Text('Oceanía')),
            ],
          ),

          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar eventos',
            onSelected: (String nuevaCategoria) {
              setState(() {
                filtroCategoria = nuevaCategoria;
              });
            },
            itemBuilder: (context) {
              List<PopupMenuEntry<String>> opciones = [
                const PopupMenuItem(value: 'todos', child: Text('Todas las categorías')),
              ];
              for (var categoria in listaDeCategorias) {
                opciones.add(
                  PopupMenuItem(
                    value: categoria['id'], 
                    child: Text('• ${categoria['title']}'),
                  ),
                );
              }
              return opciones;
            },
          ),
          
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: recargarDatos,
            tooltip: 'Recargar lista',
          ),
        ],
      ),
      
      body: FutureBuilder<List<dynamic>>(
        future: servicio.obtenerEventos(
          categoriaId: filtroCategoria, 
          bbox: filtroContinente
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay eventos para estos filtros.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final evento = snapshot.data![index];
              final categoriaId = evento['categories'][0]['id'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: _obtenerIcono(categoriaId),
                  title: Text(evento['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(evento['categories'][0]['title']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}