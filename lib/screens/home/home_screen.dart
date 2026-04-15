import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../intro/intro_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // imagem de fundo
          SizedBox.expand(
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/background.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),

          // tela
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'MAGIALURA',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF8E7B9),
                        letterSpacing: 1.5,
                        shadows: const [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 10,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    Container(
                      width: 300,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color.fromARGB(255, 158, 138, 74),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _rpgMenuButton(
                            text: 'Iniciar',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const IntroScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _rpgMenuButton(
                            text: 'Continuar',
                            onPressed: () {
                              print('Continuar jogo');
                            },
                          ),
                          const SizedBox(height: 16),
                          _rpgMenuButton(
                            text: 'Configurações',
                            onPressed: () {
                              print('Configurações');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _rpgMenuButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B3F1D),
          foregroundColor: const Color(0xFFF8E7B9),
          elevation: 6,
          shadowColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 2),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          text,
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
