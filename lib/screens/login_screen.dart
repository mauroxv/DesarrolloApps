import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _usuarioCtrl  = TextEditingController();
  final _passCtrl     = TextEditingController();

  bool    _cargando    = false;
  bool    _verPassword = false;
  String? _errorLogin;

  // Usuarios validos
  static const Map<String, String> _usuarios = {
    'mauricio':     'udc123456',
    'unicartagena': 'unicartagena',
    'heybert':      'udc654321',
    'test':         'test123',
  };

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando    = true;
      _errorLogin  = null;
    });

    await Future.delayed(const Duration(milliseconds: 400));

    final usuario = _usuarioCtrl.text.trim().toLowerCase();
    final pass    = _passCtrl.text;

    if (_usuarios[usuario] == pass) {
      await StorageService.guardarSesion(usuario);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(usuario: usuario),
        ),
      );
    } else {
      setState(() {
        _errorLogin = 'Usuario o contrasena incorrectos.';
        _cargando   = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icono superior
                  const Icon(
                    Icons.menu_book_rounded,
                    size: 80,
                    color: Color(0xFF5C4033),
                  ),
                  const SizedBox(height: 16),

                  // Titulo
                  const Text(
                    'Biblioteca Personal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C4033),
                    ),
                  ),
                  const Text(
                    'Inicia sesion para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  // Campo usuario
                  TextFormField(
                    controller: _usuarioCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Ingresa tu usuario'
                            : null,
                  ),
                  const SizedBox(height: 16),

                  // Campo contrasena
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: !_verPassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _iniciarSesion(),
                    decoration: InputDecoration(
                      labelText: 'Contrasena',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _verPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _verPassword = !_verPassword),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty)
                            ? 'Ingresa tu contrasena'
                            : null,
                  ),

                  // Error de credenciales
                  if (_errorLogin != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _errorLogin!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Boton
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C4033),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _cargando ? null : _iniciarSesion,
                    child: _cargando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Iniciar sesion',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}