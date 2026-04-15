import 'package:flutter/material.dart';
import '../models/libro.dart';
import 'form_screen.dart';
import 'lista_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Libro> _libros = [];
  int _selectedIndex = 0;

  void _agregarLibro(Libro libro) {
    setState(() {
      _libros.add(libro);
    });
    // Notificación snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ "${libro.titulo}" agregado a tu biblioteca'),
        backgroundColor: const Color(0xFF5C4033),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _eliminarLibro(int index) {
    final nombre = _libros[index].titulo;
    // Alerta de confirmación
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar libro'),
        content: Text('¿Seguro que deseas eliminar "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => _libros.removeAt(index));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🗑️ "$nombre" eliminado'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _mostrarAcercaDe() {
    showAboutDialog(
      context: context,
      applicationName: 'Biblioteca Personal',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.menu_book, size: 48, color: Color(0xFF5C4033)),
      children: [
        const Text('App para gestionar tu colección de libros personal. POWER BY MAVB Universidad de Cartagena'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      ListaScreen(libros: _libros, onEliminar: _eliminarLibro),
      FormScreen(onAgregarLibro: _agregarLibro),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C4033),
        title: const Text(
          '📚 Mi Biblioteca',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // MENÚ en AppBar (PopupMenuButton)
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'acerca') _mostrarAcercaDe();
              if (value == 'limpiar') _confirmarLimpiar();
              if (value == 'stats') _mostrarEstadisticas();
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'stats',
                child: Row(children: [
                  Icon(Icons.bar_chart, color: Color(0xFF5C4033)),
                  SizedBox(width: 8),
                  Text('Estadísticas'),
                ]),
              ),
              const PopupMenuItem(
                value: 'limpiar',
                child: Row(children: [
                  Icon(Icons.delete_sweep, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Limpiar lista'),
                ]),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'acerca',
                child: Row(children: [
                  Icon(Icons.info_outline, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Acerca de'),
                ]),
              ),
            ],
          ),
        ],
      ),
      // MENÚ inferior (BottomNavigationBar)
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF5C4033),
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Mi Biblioteca'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Agregar Libro'),
        ],
      ),
    );
  }

  void _confirmarLimpiar() {
    if (_libros.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La biblioteca ya está vacía')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ Limpiar biblioteca'),
        content: const Text('Se eliminarán TODOS los libros. ¿Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => _libros.clear());
              Navigator.pop(ctx);
            },
            child: const Text('Sí, limpiar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _mostrarEstadisticas() {
    final leidos = _libros.where((l) => l.leido).length;
    final pendientes = _libros.length - leidos;
    final promedio = _libros.isEmpty
        ? 0.0
        : _libros.map((l) => l.calificacion).reduce((a, b) => a + b) / _libros.length;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('📊 Estadísticas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statRow('Total de libros', '${_libros.length}'),
            _statRow('Libros leídos', '$leidos'),
            _statRow('Pendientes', '$pendientes'),
            _statRow('Calificación promedio', promedio.toStringAsFixed(1)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  Widget _statRow(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}