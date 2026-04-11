// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io'; // Agregado para leer el archivo y usar SecurityContext
import 'package:http/io_client.dart'; // Agregado para usar IOClient

Future<void> main() async {
  print('Solicitando datos a la NASA con certificado de seguridad...\n');

  // 1. Leemos el archivo del certificado desde la carpeta assets
  final bytesCertificado = File('assets/certificadoNASA.crt').readAsBytesSync();

  // 2. Configuramos el entorno seguro con tu archivo
  SecurityContext contextoSeguro = SecurityContext(withTrustedRoots: true);
  contextoSeguro.setTrustedCertificatesBytes(bytesCertificado);

  // 3. Creamos un cliente que usa estas nuevas reglas de seguridad
  HttpClient clienteDart = HttpClient(context: contextoSeguro);
  IOClient clienteSeguro = IOClient(clienteDart);

  // Direccion API
  final url = Uri.parse('https://eonet.gsfc.nasa.gov/api/v3/events');

  try {
    // 4. Hacemos la petición GET a internet usando nuestro cliente seguro
    final respuesta = await clienteSeguro.get(url);

    // Respuesta correcta
    if (respuesta.statusCode == 200) {
      
      // API a JSON
      final datos = json.decode(respuesta.body);
      
      // Eventos como Lista
      final eventos = datos['events'] as List;

      print('¡Éxito! Se encontraron ${eventos.length} eventos naturales globales:\n');

      // Mostrar Lista
      for (var evento in eventos) {
        final titulo = evento['title'];
        
        final categoria = evento['categories'][0]['title']; 

        print('- $titulo ($categoria)');
      }

    } else {
      print('Hubo un problema. Código de error: ${respuesta.statusCode}');
    }
  } catch (e) {
    print('Error de conexión o seguridad: $e');
  } finally {
    // 5. Siempre cerramos el cliente al final para liberar memoria
    clienteSeguro.close();
  }
}