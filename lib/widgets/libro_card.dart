import 'package:flutter/material.dart';
import '../models/libro.dart';

class LibroCard extends StatelessWidget {
  final Libro libro;
  final VoidCallback onEliminar;

  const LibroCard({super.key, required this.libro, required this.onEliminar});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF5C4033),
          child: Text(
            libro.titulo[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(libro.titulo,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${libro.autor} · ${libro.anio}'),
            Text('${libro.genero} · ⭐ ${libro.calificacion.toStringAsFixed(1)}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(libro.leido ? Icons.check_circle : Icons.radio_button_unchecked,
                color: libro.leido ? Colors.green : Colors.grey),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onEliminar,
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}