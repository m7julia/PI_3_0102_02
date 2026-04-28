import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MundoLuisScreen extends StatelessWidget {
  const MundoLuisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/bar_pirata.png',
              fit: BoxFit.cover,
            ),
          ),

          Container(color: Colors.black.withOpacity(0.6)),

          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 20),
              child: Image.asset(
                'assets/images/personagem_luis.png',
                height: 320,
                fit: BoxFit.contain,
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bar Pirata',
                    style: GoogleFonts.cinzel(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF8E7B9),
                      letterSpacing: 2,
                      shadows: const [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 10,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'O Início da Jornada',
                    style: GoogleFonts.cinzel(
                      fontSize: 22,
                      color: Colors.white70,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Você desperta em um lugar desconhecido... '
                    'Uma figura misteriosa se aproxima em silêncio.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF8E7B9), width: 2),
              ),
              child: Text(
                '??? : Finalmente... você acordou.',
                style: GoogleFonts.cinzel(
                  fontSize: 16,
                  color: const Color(0xFFF8E7B9),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
