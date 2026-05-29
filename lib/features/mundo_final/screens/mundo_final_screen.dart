import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rpg_game/screens/home/home_screen.dart';

class MundoFinalScreen extends StatelessWidget {
  const MundoFinalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fim da Jornada',
          style: GoogleFonts.cinzel(
            color: const Color(0xFFF8E7B9),
            fontWeight: FontWeight.bold,
            fontSize: (size.width * 0.045).clamp(15.0, 20.0),
          ),
        ),
        backgroundColor: const Color(0xFF6B3F1D),
        foregroundColor: const Color(0xFFF8E7B9),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Fundo
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fundo_final.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF1E1208)),
            ),
          ),

          Container(color: Colors.black.withValues(alpha: 0.50)),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
              child: Column(
                children: [
                  const Spacer(),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(size.width * 0.045),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF9E8A4A),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9E8A4A).withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Parabéns, aventureiro.\n\n'
                          'Você atravessou todos os mundos e concluiu sua missão.\n\n'
                          'Obrigado por jogar nosso RPG!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cinzel(
                            fontSize: (size.width * 0.037).clamp(13.0, 16.0),
                            height: 1.65,
                            color: const Color(0xFFF8E7B9),
                          ),
                        ),

                        SizedBox(height: size.height * 0.025),

                        SizedBox(
                          width: double.infinity,
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
                              padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.016,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: const BorderSide(
                                  color: Color(0xFF9E8A4A),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child: Text(
                              'Voltar ao menu inicial',
                              style: GoogleFonts.cinzel(
                                fontWeight: FontWeight.bold,
                                fontSize: (size.width * 0.035).clamp(12.0, 15.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.03),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}