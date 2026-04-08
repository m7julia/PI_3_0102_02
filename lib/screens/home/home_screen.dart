import 'package:flutter/material.dart';
import '../intro/intro_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RPG (DEFINIR NOME DO JOGO)')),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // INICIAR
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const IntroScreen()),
                );
              },
              child: const Text('Iniciar'),
            ),

            const SizedBox(width: 15), // espaço horizontal
            // CONTINUAR
            ElevatedButton(
              onPressed: () {
                print('Continuar jogo');
              },
              child: const Text('Continuar'),
            ),

            const SizedBox(width: 15),

            // CONFIGURAÇÕES
            ElevatedButton(
              onPressed: () {
                print('Abrir configurações');
              },
              child: const Text('Configurações'),
            ),
          ],
        ),
      ),
    );
  }
}
