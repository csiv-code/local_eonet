// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart'; // ¡Nueva herramienta para leer assets en Flutter!
import 'package:http/io_client.dart';

class ServicioNasa {
  Future<List<dynamic>> obtenerEventos() async {
    try {
      // 1. Así se leen los archivos empaquetados en Flutter:
      final byteData = await rootBundle.load('assets/certificadoNASA.crt');
      final bytesCertificado = byteData.buffer.asUint8List();

      // 2. Configuramos la seguridad igual que antes
      SecurityContext contextoSeguro = SecurityContext(withTrustedRoots: true);
      contextoSeguro.setTrustedCertificatesBytes(bytesCertificado);

      HttpClient clienteDart = HttpClient(context: contextoSeguro);
      IOClient clienteSeguro = IOClient(clienteDart);

      final url = Uri.parse('https://eonet.gsfc.nasa.gov/api/v3/events?limit=50');

      final respuesta = await clienteSeguro.get(url);

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        return datos['events'] as List; 
      } else {
        print('Error en la API. Código: ${respuesta.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error en la conexión: $e');
      return []; 
    }
  }
}