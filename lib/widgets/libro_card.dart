import 'package:flutter/material.dart';
import '../models/libro.dart';

class LibroCard extends StatelessWidget {
  final Libro libro;
  final VoidCallback onEliminar;
  final bool seleccionado;
  final VoidCallback onSeleccionar;

  const LibroCard({
    super.key,
    required this.libro,
    required this.onEliminar,
    required this.seleccionado,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: seleccionado ? 6 : 2,
      color: seleccionado ? const Color(0xFFEFEBE9) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: seleccionado
            ? const BorderSide(color: Color(0xFF5C4033), width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        onTap: onSeleccionar,
        leading: CircleAvatar(
          backgroundColor: seleccionado
              ? const Color(0xFF5C4033)
              : const Color(0xFFBCAAA4),
          child: seleccionado
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : Text(
                  libro.titulo[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        title: Text(
          libro.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${libro.autor} - ${libro.anio}'),
            Text('${libro.genero} - ${libro.calificacion.toStringAsFixed(1)} estrellas'),
            Text(
              libro.leido ? 'Leido' : 'Pendiente de leer',
              style: TextStyle(
                color: libro.leido ? Colors.green : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onEliminar,
        ),
        isThreeLine: true,
      ),
    );
  }
}