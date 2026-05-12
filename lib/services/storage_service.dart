import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/libro.dart';

class StorageService {

  // Clave de sesion (unica, indica quien esta logueado)
  static const String _keyUsuario = 'usuario_logueado';

  // Claves dinamicas por usuario
  static String _keyLibros(String usuario) => 'lista_libros_$usuario';
  static String _keyNombre(String usuario)  => 'nombre_completo_$usuario';

  // ─────────────────────────────────────────────
  //  SESION
  // ─────────────────────────────────────────────

  /// Guarda que usuario inicio sesion
  static Future<void> guardarSesion(String usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsuario, usuario);
  }

  /// Lee quien esta logueado. Retorna null si no hay sesion.
  static Future<String?> leerSesion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsuario);
  }

  /// Elimina la sesion activa
  static Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsuario);
  }

  // ─────────────────────────────────────────────
  //  LIBROS — separados por usuario
  // ─────────────────────────────────────────────

  /// Guarda la lista de libros del usuario indicado
  static Future<void> guardarLibros(String usuario, List<Libro> libros) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = libros.map((l) => jsonEncode({
      'titulo':       l.titulo,
      'autor':        l.autor,
      'genero':       l.genero,
      'anio':         l.anio,
      'calificacion': l.calificacion,
      'leido':        l.leido,
    })).toList();
    await prefs.setStringList(_keyLibros(usuario), jsonList);
  }

  /// Lee la lista de libros del usuario indicado
  static Future<List<Libro>> leerLibros(String usuario) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyLibros(usuario)) ?? [];
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

  /// Elimina todos los libros del usuario indicado
  static Future<void> limpiarLibros(String usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLibros(usuario));
  }
}