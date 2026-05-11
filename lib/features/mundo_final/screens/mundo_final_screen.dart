import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rpg_game/screens/home/home_screen.dart';

class MundoFinalScreen extends StatelessWidget {
  const MundoFinalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fundo_final.png',
              fit: BoxFit.cover,
            ),
          ),

          // Escurece o fundo
          Container(color: Colors.black.withValues(alpha: 0.2)),

          // Conteúdo principal
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.70),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF8E7B9), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF8E7B9).withValues(alpha: 0.2),
                      blurRadius: 20,
                    ),
                  ],
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Título
                    Text(
                      'Fim da Jornada',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF8E7B9),
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Texto final
                    Text(
                      'Parabéns, aventureiro.\n\n'
                      'Você atravessou todos os mundos e concluiu sua missão.\n\n'
                      'Obrigado por jogar nosso RPG!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        fontSize: 18,
                        height: 1.7,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Créditos
                    Text(
                      'Créditos',
                      style: GoogleFonts.cinzel(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF8E7B9),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      'Equipe do RPG\n'
                      'Ana '
                      'Gian '
                      'Luis '
                      'Maju '
                      'Rafa ',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        fontSize: 16,
                        height: 1.8,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Botão final
                    SizedBox(
                      width: 240,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B3F1D),
                          foregroundColor: const Color(0xFFF8E7B9),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(
                              color: Color(0xFF9E8A4A),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Text(
                          'Voltar ao menu incial',
                          style: GoogleFonts.cinzel(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
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
}
