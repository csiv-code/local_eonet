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
  String filtroActual = 'todos'; 

  void recargarDatos() {
    setState(() {});
  }


  Widget _obtenerIcono(String categoriaId) {
    switch (categoriaId) {
      case 'wildfires':
        return const Icon(Icons.local_fire_department, color: Colors.red, size: 30);
      case 'volcanoes':
        return const Icon(Icons.terrain, color: Colors.deepOrange, size: 30);
      case 'severeStorms':
        return const Icon(Icons.thunderstorm, color: Colors.blueGrey, size: 30);
      case 'earthquakes':
        return const Icon(Icons.vibration, color: Colors.brown, size: 30);
      case 'floods':
        return const Icon(Icons.water, color: Colors.blue, size: 30);
      case 'snow':
      case 'seaLakeIce':
        return const Icon(Icons.ac_unit, color: Colors.lightBlue, size: 30);
      default:
        return const Icon(Icons.warning_amber, color: Colors.orange, size: 30);
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
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar eventos',
            onSelected: (String nuevaCategoria) {
              setState(() {
                filtroActual = nuevaCategoria;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'todos', child: Text('🌍 Todos los eventos')),
              const PopupMenuItem(value: 'wildfires', child: Text('🔥 Incendios')),
              const PopupMenuItem(value: 'volcanoes', child: Text('🌋 Volcanes')),
              const PopupMenuItem(value: 'severeStorms', child: Text('⛈️ Tormentas')),
              const PopupMenuItem(value: 'earthquakes', child: Text('🫨 Terremotos')),
              const PopupMenuItem(value: 'floods', child: Text('🌊 Inundaciones')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: recargarDatos,
            tooltip: 'Recargar lista',
          ),
        ],
      ),
      
      body: FutureBuilder<List<dynamic>>(
        future: servicio.obtenerEventos(categoriaId: filtroActual),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay eventos activos para esta categoría.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final evento = snapshot.data![index];
              final categoriaId = evento['categories'][0]['id']; // Extraemos el ID como 'wildfires'

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  // Usamos nuestra función traductora para mostrar el ícono correcto
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