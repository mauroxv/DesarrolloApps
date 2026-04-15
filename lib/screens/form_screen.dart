import 'package:flutter/material.dart';
import '../models/libro.dart';

class FormScreen extends StatefulWidget {
  final Function(Libro) onAgregarLibro;
  const FormScreen({super.key, required this.onAgregarLibro});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _autorCtrl = TextEditingController();
  final _anioCtrl = TextEditingController();

  String _generoSeleccionado = 'Ficción';
  double _calificacion = 3.0;
  bool _leido = false;

  final List<String> _generos = [
    'Ficción', 'No ficción', 'Ciencia ficción',
    'Fantasía', 'Misterio', 'Romance', 'Historia', 'Biografía', 'Otro'
  ];

  void _enviarFormulario() {
    if (_formKey.currentState!.validate()) {
      final libro = Libro(
        titulo: _tituloCtrl.text.trim(),
        autor: _autorCtrl.text.trim(),
        genero: _generoSeleccionado,
        anio: int.parse(_anioCtrl.text),
        calificacion: _calificacion,
        leido: _leido,
      );
      widget.onAgregarLibro(libro);
      _limpiarFormulario();
    }
  }

  void _limpiarFormulario() {
    _formKey.currentState!.reset();
    _tituloCtrl.clear();
    _autorCtrl.clear();
    _anioCtrl.clear();
    setState(() {
      _generoSeleccionado = 'Ficción';
      _calificacion = 3.0;
      _leido = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Agregar nuevo libro',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Campo Título
            TextFormField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(
                labelText: 'Título del libro *',
                prefixIcon: Icon(Icons.book),
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'El título es obligatorio' : null,
            ),
            const SizedBox(height: 16),

            // Campo Autor
            TextFormField(
              controller: _autorCtrl,
              decoration: const InputDecoration(
                labelText: 'Autor *',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'El autor es obligatorio' : null,
            ),
            const SizedBox(height: 16),

            // Campo Año
            TextFormField(
              controller: _anioCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Año de publicación *',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'El año es obligatorio';
                final n = int.tryParse(v);
                if (n == null || n < 1000 || n > 2025) return 'Año inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Dropdown Género
            DropdownButtonFormField<String>(
              value: _generoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Género',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: _generos.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (v) => setState(() => _generoSeleccionado = v!),
            ),
            const SizedBox(height: 20),

            // Calificación con Slider
            Text('Calificación: ${_calificacion.toStringAsFixed(1)} ⭐',
                style: const TextStyle(fontSize: 16)),
            Slider(
              value: _calificacion,
              min: 1,
              max: 5,
              divisions: 8,
              activeColor: const Color(0xFF5C4033),
              label: _calificacion.toStringAsFixed(1),
              onChanged: (v) => setState(() => _calificacion = v),
            ),
            const SizedBox(height: 8),

            // Switch Leído
            SwitchListTile(
              title: const Text('¿Ya lo leíste?'),
              subtitle: Text(_leido ? 'Marcado como leído ✅' : 'Pendiente de leer'),
              value: _leido,
              activeColor: const Color(0xFF5C4033),
              onChanged: (v) => setState(() => _leido = v),
            ),
            const SizedBox(height: 24),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _limpiarFormulario,
                    icon: const Icon(Icons.clear),
                    label: const Text('Limpiar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C4033),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _enviarFormulario,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar libro'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}