import 'package:flutter/material.dart';
import '../models/libro.dart';
import '../services/storage_service.dart';
import 'form_screen.dart';
import 'lista_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String usuario;
  const HomeScreen({super.key, required this.usuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Libro> _libros = [];
  int  _selectedIndex = 0;
  bool _cargando      = true;

  @override
  void initState() {
    super.initState();
    _cargarLibros();
  }

  Future<void> _cargarLibros() async {
    final libros = await StorageService.leerLibros(widget.usuario);
    setState(() {
      _libros..clear()..addAll(libros);
      _cargando = false;
    });
  }

  // ─── AGREGAR ─────────────────────────────────────────

  Future<void> _agregarLibro(Libro libro) async {
    setState(() => _libros.add(libro));
    await StorageService.guardarLibros(widget.usuario, _libros);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${libro.titulo}" agregado a tu biblioteca.'),
        backgroundColor: const Color(0xFF5C4033),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ─── ELIMINAR UNO ─────────────────────────────────────

  void _eliminarLibro(int index) {
    final nombre = _libros[index].titulo;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar libro'),
        content: Text('Deseas eliminar "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              setState(() => _libros.removeAt(index));
              await StorageService.guardarLibros(widget.usuario, _libros);
              if (!mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"$nombre" eliminado.'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // ─── ELIMINAR VARIOS ─────────────────────────────────
  // Recibe una lista de indices, los ordena de mayor a menor
  // para no desplazar los indices al borrar

  void _eliminarVarios(List<int> indices) {
    if (indices.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar libros'),
        content: Text(
          'Se eliminaran ${indices.length} libro(s) seleccionado(s). Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              // Ordenar de mayor a menor para no correr indices
              final ordenados = List<int>.from(indices)
                ..sort((a, b) => b.compareTo(a));
              setState(() {
                for (final i in ordenados) {
                  _libros.removeAt(i);
                }
              });
              await StorageService.guardarLibros(widget.usuario, _libros);
              if (!mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${indices.length} libro(s) eliminado(s).'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // ─── LOGOUT ──────────────────────────────────────────

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesion'),
        content: Text('Deseas salir, ${widget.usuario}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await StorageService.cerrarSesion();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  // ─── LIMPIAR ─────────────────────────────────────────

  void _confirmarLimpiar() {
    if (_libros.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La biblioteca ya esta vacia.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpiar biblioteca'),
        content: const Text('Se eliminaran todos los libros. Deseas continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              setState(() => _libros.clear());
              await StorageService.limpiarLibros(widget.usuario);
              if (!mounted) return;
              Navigator.pop(ctx);
            },
            child: const Text('Limpiar todo'),
          ),
        ],
      ),
    );
  }

  // ─── ESTADISTICAS ────────────────────────────────────

  void _mostrarEstadisticas() {
    final leidos     = _libros.where((l) => l.leido).length;
    final pendientes = _libros.length - leidos;
    final promedio   = _libros.isEmpty
        ? 0.0
        : _libros.map((l) => l.calificacion).reduce((a, b) => a + b) /
            _libros.length;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Estadisticas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statRow('Total de libros',      '${_libros.length}'),
            _statRow('Libros leidos',         '$leidos'),
            _statRow('Pendientes de leer',    '$pendientes'),
            _statRow('Calificacion promedio', promedio.toStringAsFixed(1)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarAcercaDe() {
    showAboutDialog(
      context: context,
      applicationName: 'Biblioteca Personal',
      applicationVersion: '2.0.0',
      applicationIcon: const Icon(
        Icons.menu_book_rounded,
        size: 48,
        color: Color(0xFF5C4033),
      ),
      children: [
        const Text('Aplicacion para gestionar tu coleccion de libros personal.'),
      ],
    );
  }

  Widget _statRow(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ─── BUILD ───────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screens = [
      ListaScreen(
        libros: _libros,
        onEliminar: _eliminarLibro,
        onEliminarVarios: _eliminarVarios,   // <-- nuevo
      ),
      FormScreen(onAgregarLibro: _agregarLibro),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C4033),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Biblioteca Personal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Hola, ${widget.usuario}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'stats':   _mostrarEstadisticas(); break;
                case 'limpiar': _confirmarLimpiar();    break;
                case 'logout':  _cerrarSesion();        break;
                case 'acerca':  _mostrarAcercaDe();     break;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'stats',
                child: Row(children: [
                  Icon(Icons.bar_chart),
                  SizedBox(width: 8),
                  Text('Estadisticas'),
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
                value: 'logout',
                child: Row(children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Cerrar sesion'),
                ]),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'acerca',
                child: Row(children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 8),
                  Text('Acerca de'),
                ]),
              ),
            ],
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF5C4033),
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            activeIcon: Icon(Icons.library_books),
            label: 'Mi Biblioteca',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box),
            label: 'Agregar Libro',
          ),
        ],
      ),
    );
  }
}