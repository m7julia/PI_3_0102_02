import 'package:flutter/material.dart';
import '../game/personagem/criar_personagem_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Introdução do jogo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Introdução',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CriarPersonagemScreen(),
                  ),
                );
              },
              child: const Text('Criar personagem'),
            ),
          ],
        ),
      ),
    );
  }
}