import 'package:flutter/material.dart';
import '../models/libro.dart';
import '../widgets/libro_card.dart';

class ListaScreen extends StatelessWidget {
  final List<Libro> libros;
  final Function(int) onEliminar;

  const ListaScreen({super.key, required this.libros, required this.onEliminar});

  @override
  Widget build(BuildContext context) {
    if (libros.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 80, color: Colors.brown),
            SizedBox(height: 16),
            Text('Tu biblioteca está vacía',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Agrega tu primer libro en la pestaña "Agregar"',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: libros.length,
      itemBuilder: (ctx, i) => LibroCard(
        libro: libros[i],
        onEliminar: () => onEliminar(i),
      ),
    );
  }
}