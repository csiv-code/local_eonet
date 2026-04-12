import 'package:flutter/material.dart';
import 'servicio_nasa.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PantallaEventos(),
  ));
}

// 1. Volvemos a StatefulWidget para poder "refrescar" la pantalla
class PantallaEventos extends StatefulWidget {
  const PantallaEventos({super.key});

  @override
  State<PantallaEventos> createState() => _PantallaEventosState();
}

class _PantallaEventosState extends State<PantallaEventos> {
  final servicio = ServicioNasa();

  // 2. Esta función es la magia del botón. 
  // setState le dice a Flutter: "Vuelve a dibujar toda la pantalla"
  void recargarDatos() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monitor EONET - NASA')),
      
      body: FutureBuilder<List<dynamic>>(
        // Al redibujarse la pantalla, esto vuelve a llamar a la NASA
        future: servicio.obtenerEventos(),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay eventos o ocurrió un error.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final evento = snapshot.data![index];
              return ListTile(
                leading: const Icon(Icons.warning_amber, color: Colors.orange),
                title: Text(evento['title']),
                subtitle: Text(evento['categories'][0]['title']),
              );
            },
          );
        },
      ),


      floatingActionButton: FloatingActionButton(
        onPressed: recargarDatos,
        backgroundColor: Colors.deepPurple[100],
        child: const Icon(Icons.refresh),
      ),
    );
  }
}