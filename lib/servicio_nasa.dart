// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';

class ServicioNasa {
  Future<List<dynamic>> obtenerEventos({String categoriaId = 'todos', String bbox = 'todos'}) async {
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
      
      if (bbox != 'todos') {
        urlTexto += '&bbox=$bbox';
      }

      final url = Uri.parse(urlTexto);
      final respuesta = await clienteSeguro.get(url);

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        return datos['events'] as List; 
      } else {
        return [];
      }
    } catch (e) {
      print('Error en la conexión de eventos: $e');
      return []; 
    }
  }

  Future<List<dynamic>> obtenerCategorias() async {
    try {
      final byteData = await rootBundle.load('assets/certificadoNASA.crt');
      final bytesCertificado = byteData.buffer.asUint8List();
      SecurityContext contextoSeguro = SecurityContext(withTrustedRoots: true);
      contextoSeguro.setTrustedCertificatesBytes(bytesCertificado);
      HttpClient clienteDart = HttpClient(context: contextoSeguro);
      IOClient clienteSeguro = IOClient(clienteDart);

      final url = Uri.parse('https://eonet.gsfc.nasa.gov/api/v3/categories');
      final respuesta = await clienteSeguro.get(url);

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        return datos['categories'] as List; 
      } else {
        return [];
      }
    } catch (e) {
      print('Error en la conexión de categorías: $e');
      return []; 
    }
  }
}