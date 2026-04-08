import 'package:flutter/material.dart';
import '../intro/intro_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // IMAGEM DE FUNDO
          SizedBox.expand(
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/background.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Container(color: Colors.black.withOpacity(0.5)),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'RPG (DEFINIR NOME DO JOGO)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // BOTÕES
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const IntroScreen()),
                    );
                  },
                  child: const Text('Iniciar'),
                ),

                const SizedBox(width: 15),

                ElevatedButton(
                  onPressed: () {
                    print('Continuar jogo');
                  },
                  child: const Text('Continuar'),
                ),

                const SizedBox(width: 15),

                ElevatedButton(
                  onPressed: () {
                    print('Configurações');
                  },
                  child: const Text('Configurações'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
