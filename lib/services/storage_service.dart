import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/libro.dart';

class StorageService {
  static const String _keyUsuario = 'usuario_logueado';
  static const String _keyLibros  = 'lista_libros';

  // ---------- SESION ----------

  static Future<void> guardarSesion(String usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsuario, usuario);
  }

  static Future<String?> leerSesion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsuario);
  }

  static Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsuario);
  }

  // ---------- LIBROS ----------

  static Future<void> guardarLibros(List<Libro> libros) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = libros.map((l) => jsonEncode({
      'titulo':       l.titulo,
      'autor':        l.autor,
      'genero':       l.genero,
      'anio':         l.anio,
      'calificacion': l.calificacion,
      'leido':        l.leido,
    })).toList();
    await prefs.setStringList(_keyLibros, jsonList);
  }

  static Future<List<Libro>> leerLibros() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyLibros) ?? [];
    return jsonList.map((s) {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return Libro(
        titulo:       m['titulo'],
        autor:        m['autor'],
        genero:       m['genero'],
        anio:         m['anio'],
        calificacion: (m['calificacion'] as num).toDouble(),
        leido:        m['leido'],
      );
    }).toList();
  }
}