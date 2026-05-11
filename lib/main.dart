import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const BibliotecaApp());
}

class BibliotecaApp extends StatelessWidget {
  const BibliotecaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biblioteca Personal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C4033),
        ),
        useMaterial3: true,
      ),
      home: FutureBuilder<String?>(
        future: StorageService.leerSesion(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.data != null) {
            return HomeScreen(usuario: snapshot.data!);
          }
          return const LoginScreen();
        },
      ),
    );
  }
}