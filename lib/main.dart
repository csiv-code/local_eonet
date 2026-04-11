import 'package:flutter/material.dart';
import 'servicio_nasa.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PantallaEventos(),
  ));
}

class PantallaEventos extends StatelessWidget {
  const PantallaEventos({super.key});

  @override
  Widget build(BuildContext context) {
    final servicio = ServicioNasa();

    return Scaffold(
      appBar: AppBar(title: const Text('Monitor EONET - NASA')),
      body: FutureBuilder<List<dynamic>>(
        future: servicio.obtenerEventos(),
        builder: (context, snapshot) {
          
          // 1. Cargando...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          // 2. Si algo sale mal o no hay datos (agrupado)
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay eventos o ocurrió un error.'));
          }

          // 3. Dibujar la lista
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
    );
  }
}