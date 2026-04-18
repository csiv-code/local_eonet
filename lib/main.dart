import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; 
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

  Future<void> _mostrarReadme(BuildContext context) async {
    try {
      final String textoReadme = await rootBundle.loadString('README.md');
      if (!context.mounted) return;
      
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 10),
                Text('Read Me'),
              ],
            ),
            content: SingleChildScrollView(
              child: Text(textoReadme),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CERRAR'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se encontró el archivo README.md en la raíz')),
      );
    }
  }

  Widget _obtenerIcono(String categoriaId) {
    switch (categoriaId) {
      case 'wildfires': return const Icon(Icons.local_fire_department, color: Colors.red, size: 24);
      case 'volcanoes': return const Icon(Icons.terrain, color: Colors.deepOrange, size: 24);
      case 'severeStorms': return const Icon(Icons.thunderstorm, color: Colors.blueGrey, size: 24);
      case 'earthquakes': return const Icon(Icons.vibration, color: Colors.brown, size: 24);
      case 'floods': return const Icon(Icons.water, color: Colors.blue, size: 24);
      case 'snow':
      case 'seaLakeIce': return const Icon(Icons.ac_unit, color: Colors.lightBlue, size: 24);
      case 'drought': return const Icon(Icons.wb_sunny, color: Colors.orangeAccent, size: 24);
      case 'tempExtremes': return const Icon(Icons.thermostat, color: Colors.redAccent, size: 24);
      case 'dustHaze': return const Icon(Icons.blur_on, color: Colors.grey, size: 24);
      case 'landslides': return const Icon(Icons.landslide, color: Colors.brown, size: 24);
      default: return const Icon(Icons.warning_amber, color: Colors.orange, size: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Image.asset('assets/nasa_logo.png', width: 40, height: 40), 
            const SizedBox(width: 10),
            const Text('EONET', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
        actions: [
          const Center(
            child: Text('Powered by NASA', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 10),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 30),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),

      endDrawer: Drawer(
        backgroundColor: Colors.grey[300],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              child: Text('Opciones', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ExpansionTile(
              title: const Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                ListTile(
                  title: const Text('Todas'),
                  selected: filtroCategoria == 'todos',
                  onTap: () { setState(() => filtroCategoria = 'todos'); Navigator.pop(context); },
                ),
                ...listaDeCategorias.map((cat) => ListTile(
                  title: Text(cat['title']),
                  selected: filtroCategoria == cat['id'],
                  onTap: () { setState(() => filtroCategoria = cat['id']); Navigator.pop(context); },
                )),
              ],
            ),
            const Divider(color: Colors.black54),
            ExpansionTile(
              title: const Text('Continente', style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                ListTile(title: const Text('Todo el mundo'), onTap: () { setState(() => filtroContinente = 'todos'); Navigator.pop(context); }),
                ListTile(title: const Text('América del Norte'), onTap: () { setState(() => filtroContinente = '-168,15,-52,72'); Navigator.pop(context); }),
                ListTile(title: const Text('América del Sur'), onTap: () { setState(() => filtroContinente = '-82,-56,-34,13'); Navigator.pop(context); }),
                ListTile(title: const Text('Europa'), onTap: () { setState(() => filtroContinente = '-10,35,40,71'); Navigator.pop(context); }),
                ListTile(title: const Text('África'), onTap: () { setState(() => filtroContinente = '-18,-35,52,38'); Navigator.pop(context); }),
                ListTile(title: const Text('Asia'), onTap: () { setState(() => filtroContinente = '40,5,180,75'); Navigator.pop(context); }),
                ListTile(title: const Text('Oceanía'), onTap: () { setState(() => filtroContinente = '110,-47,180,-10'); Navigator.pop(context); }),
              ],
            ),
            const Divider(color: Colors.black54),
            ListTile(
              title: const Text('Refrescar', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                recargarDatos();
                Navigator.pop(context);
              },
            ),
            const Divider(color: Colors.black54),
            ListTile(
              title: const Text('Read Me', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context); 
                _mostrarReadme(context); 
              },
            ),
          ],
        ),
      ),
      
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: const Text(
              'Earth Observatory Natural Event Tracker', 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
            ),
          ),
          
          Expanded(

            child: FutureBuilder<List<dynamic>>(
              future: servicio.obtenerEventos(categoriaId: filtroCategoria, bbox: filtroContinente),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } 
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay eventos.'));
                }

                final eventos = snapshot.data!;
                
                List<Marker> marcadoresEnElMapa = [];
                for (var evento in eventos) {
                  final categoriaId = evento['categories'][0]['id'];
                  
                  if (evento['geometry'] != null && evento['geometry'].isNotEmpty) {
                    var coords = evento['geometry'][0]['coordinates'];
                    double lat = 0.0, lng = 0.0;
                    
                    if (coords is List && coords.length >= 2) {
                      if (coords[0] is List) { 
                        lng = coords[0][0].toDouble();
                        lat = coords[0][1].toDouble();
                      } else { 
                        lng = coords[0].toDouble();
                        lat = coords[1].toDouble();
                      }
                      
                      marcadoresEnElMapa.add(
                        Marker(
                          point: LatLng(lat, lng), 
                          width: 40,
                          height: 40,
                          child: _obtenerIcono(categoriaId), 
                        ),
                      );
                    }
                  }
                }

                return Row(
                  children: [
                    Container(
                      width: 250, 
                      color: Colors.grey[350], 
                      child: ListView.builder(
                        itemCount: eventos.length,
                        itemBuilder: (context, index) {
                          final evento = eventos[index];
                          final categoriaId = evento['categories'][0]['id'];

                          return Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.black, width: 1.0), 
                                right: BorderSide(color: Colors.black, width: 2.0),  
                              ),
                            ),
                            child: ListTile(
                              leading: _obtenerIcono(categoriaId), 
                              title: Text(
                                evento['title'], 
                                style: const TextStyle(fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Expanded(
                      child: FlutterMap(
                        options: const MapOptions(
                          initialCenter: LatLng(20.0, 0.0), 
                          initialZoom: 2.0, 
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.tuapp.eonet',
                          ),
                          MarkerLayer(
                            markers: marcadoresEnElMapa, 
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}