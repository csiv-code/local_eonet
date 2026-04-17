// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class ServicioNasa {

  Future<List<dynamic>> obtenerEventos({String categoriaId = 'todos'}) async {
    try {
      final byteData = await rootBundle.load('assets/certificadoNASA.crt');
      final bytesCertificado = byteData.buffer.asUint8List();

      SecurityContext contextoSeguro = SecurityContext(withTrustedRoots: true);
      contextoSeguro.setTrustedCertificatesBytes(bytesCertificado);

      HttpClient clienteDart = HttpClient(context: contextoSeguro);
      IOClient clienteSeguro = IOClient(clienteDart);

      String urlTexto = 'https://eonet.gsfc.nasa.gov/api/v3/events?limit=30';
      
      if (categoriaId != 'todos') {
        urlTexto += '&category=$categoriaId';
      }

      final url = Uri.parse(urlTexto);
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