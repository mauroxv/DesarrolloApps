import 'package:flutter/material.dart';
import '../models/libro.dart';
import '../widgets/libro_card.dart';

class ListaScreen extends StatefulWidget {
  final List<Libro> libros;
  final Function(int) onEliminar;
  final Function(List<int>) onEliminarVarios;

  const ListaScreen({
    super.key,
    required this.libros,
    required this.onEliminar,
    required this.onEliminarVarios,
  });

  @override
  State<ListaScreen> createState() => _ListaScreenState();
}

class _ListaScreenState extends State<ListaScreen> {
  final Set<int> _seleccionados = {};

  void _toggleSeleccion(int index) {
    setState(() {
      if (_seleccionados.contains(index)) {
        _seleccionados.remove(index);
      } else {
        _seleccionados.add(index);
      }
    });
  }

  void _cancelarSeleccion() {
    setState(() => _seleccionados.clear());
  }

  void _eliminarSeleccionados() {
    // Pasa los indices seleccionados al home para que actualice
    // SharedPreferences y la lista principal
    widget.onEliminarVarios(_seleccionados.toList());
    setState(() => _seleccionados.clear());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.libros.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books_outlined, size: 80, color: Colors.brown),
            SizedBox(height: 16),
            Text(
              'Tu biblioteca esta vacia',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Agrega tu primer libro en la pestana Agregar',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Barra de seleccion: solo visible cuando hay algo seleccionado
        if (_seleccionados.isNotEmpty)
          Container(
            color: const Color(0xFF5C4033),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text(
                  '${_seleccionados.length} seleccionado(s)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _cancelarSeleccion,
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  label: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _eliminarSeleccionados,
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Eliminar'),
                ),
              ],
            ),
          ),

        // Lista de libros
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: widget.libros.length,
            itemBuilder: (ctx, i) => LibroCard(
              libro: widget.libros[i],
              seleccionado: _seleccionados.contains(i),
              onSeleccionar: () => _toggleSeleccion(i),
              onEliminar: () => widget.onEliminar(i),
            ),
          ),
        ),
      ],
    );
  }
}