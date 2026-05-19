import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreditosScreen extends StatelessWidget {
  const CreditosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fundo_creditos.png',
              fit: BoxFit.cover,
            ),
          ),

          Container(color: Colors.black.withValues(alpha: 0.45)),

          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFFF8E7B9),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // Conteúdo scrollável
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 40),
              child: Column(
                children: [
                  // Título da tela
                  Text(
                    '✦  Créditos  ✦',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF8E7B9),
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '— Uma aventura criada com dedicação —',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(
                      fontSize: 13,
                      color: Colors.white38,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Equipe ──
                  _buildCard(
                    titulo: 'A EQuipe',
                    conteudo: Column(
                      children: [
                        _buildMembro('ANA CAROLINA FERREIRA ALVES BARCARO', 'TERRASEN'),
                        _buildMembro('GIANLUCA PRESTELLO CRUGEL', 'CONSERVATÓRIO DIMINUTO'),
                        _buildMembro('LUIS FILIPPI AGUIAR DA ROCHA', 'BAR PIRATA'),
                        _buildMembro('MARIA JULIA HOFSTETTER TREVISAN PEREIRA', 'FAZENDA VALE DOURADO'),
                        _buildMembro('RAFAEL FERREIRA LUCIETTO', 'ESTACIONAMENTO CAÓTICO'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Mundo ana créditos
                  _buildCard(
                    titulo: 'Mundo Terrasen',
                    conteudo: Column(
                      children: [
                        _buildLinha(
                          'Tronos de Vidro',
                          'Inspirado na obra de Sara J. Maas',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // IAs utilizadas
                  _buildCard(
                    titulo: 'Inteligências Artificiais utilizadas',
                    conteudo: Column(
                      children: [
                        _buildLinha('Claude', 'Código & lógica do jogo'),
                        _buildLinha('ChatGPT', 'Código & lógica do jogo'),
                        _buildLinha('GitHub Copilot', 'Assistência no código'),
                        _buildLinha('Gemini', 'Criação de todas as imagens'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    '✦ ✦ ✦',
                    style: GoogleFonts.cinzel(
                      fontSize: 20,
                      color: const Color(0xFF9E8A4A),
                      letterSpacing: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Magialura',
                    style: GoogleFonts.cinzel(
                      fontSize: 11,
                      color: Colors.white24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String titulo, required Widget conteudo}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF8E7B9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF8E7B9).withValues(alpha: 0.08),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            titulo,
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFF8E7B9),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Divider(color: const Color(0xFF9E8A4A).withValues(alpha: 0.5)),
          const SizedBox(height: 10),
          conteudo,
        ],
      ),
    );
  }

  Widget _buildMembro(String nome, String papel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nome,
            style: GoogleFonts.cinzel(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFF8E7B9),
            ),
          ),
          Text(
            papel,
            style: GoogleFonts.cinzel(
              fontSize: 13,
              color: Colors.white54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinha(String nome, String descricao) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nome,
            style: GoogleFonts.cinzel(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFF8E7B9),
            ),
          ),
          Flexible(
            child: Text(
              descricao,
              textAlign: TextAlign.end,
              style: GoogleFonts.cinzel(
                fontSize: 13,
                color: Colors.white54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
