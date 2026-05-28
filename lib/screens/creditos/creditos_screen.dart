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

                  _buildCard(
                    titulo: 'A EQuipe',
                    conteudo: Column(
                      children: [
                        _buildMembro(
                          'ANA CAROLINA FERREIRA ALVES BARCARO',
                          'TERRASEN',
                        ),
                        _buildMembro(
                          'GIANLUCA PRESTELLO CRUGEL',
                          'CONSERVATÓRIO DIMINUTO',
                        ),
                        _buildMembro(
                          'LUIS FILIPPI AGUIAR DA ROCHA',
                          'BAR PIRATA',
                        ),
                        _buildMembro(
                          'MARIA JULIA HOFSTETTER TREVISAN PEREIRA',
                          'FAZENDA VALE DOURADO',
                        ),
                        _buildMembro(
                          'RAFAEL FERREIRA LUCIETTO',
                          'ESTACIONAMENTO CAÓTICO',
                        ),
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
                          'Trono de Vidro',
                          'Inspirado na obra de Sara J. Maas',
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                  _buildCard(
                    titulo: 'Tela criar personagem',
                    conteudo: Column(
                      children: [
                        _buildLinha(
                          'Rowan',
                          'Personagem inspirado na obra de Sara J. Maas',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Mundo ana créditos
                  _buildCard(
                    titulo: 'Mundo Conservatório Diminuto',
                    conteudo: Column(
                      children: [
                        _buildLinha(
                          'Beethoven, O Magnífico',
                          'Personagem inspirado na obra de Brian Levant com junção do músico e compositor Ludwig van Beethoven',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // SEÇÃO DE TRILHA SONORA
                  _buildCard(
                    titulo: '🎵  Trilha Sonora  🎵',
                    conteudo: Column(
                      children: [
                        _buildMusica(
                          'Happy Farm',
                          'Infraction [No Copyright Music]',
                          'Trilha sonora da Fazenda Vale Dourado',
                        ),

                        const SizedBox(height: 12),

                        _buildMusica(
                          'Powerful Dramatic Trailer',
                          'ArtMyLife',
                          'Trilha sonora da tela de inicio',
                        ),

                        const SizedBox(height: 12),

                        _buildMusica(
                          'Kingdoms and Castles',
                          'Youtube Audio Library',
                          'Trilha sonora de Terrasen',
                        ),

                         const SizedBox(height: 12),

                        _buildMusica(
                          'Für Elise',
                          'Ludwig van Beethoven',
                          'Trilha sonora do Conservatório Diminuto',
                        ),

                        const SizedBox(height: 12),

                        _buildMusica(
                          'es a Pirate',
                          'Composta por Klaus Badelt e Hans Zimmer',
                          'Trilha sonora do Bar Pirata',
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

          // Botão de voltar (por último para ficar em cima)
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Para telas menores, empilha os textos
          if (constraints.maxWidth < 500) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: GoogleFonts.cinzel(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF8E7B9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  papel,
                  style: GoogleFonts.cinzel(
                    fontSize: 12,
                    color: Colors.white54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            );
          }
          // Layout padrão horizontal
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 3,
                child: Text(
                  nome,
                  style: GoogleFonts.cinzel(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF8E7B9),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                flex: 2,
                child: Text(
                  papel,
                  textAlign: TextAlign.end,
                  style: GoogleFonts.cinzel(
                    fontSize: 13,
                    color: Colors.white54,
                    fontStyle: FontStyle.italic,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLinha(String nome, String descricao) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 500) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: GoogleFonts.cinzel(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF8E7B9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  descricao,
                  style: GoogleFonts.cinzel(
                    fontSize: 12,
                    color: Colors.white54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 1,
                child: Text(
                  nome,
                  style: GoogleFonts.cinzel(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF8E7B9),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                flex: 2,
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
          );
        },
      ),
    );
  }

  // Widget para exibir música com detalhes (responsivo)
  Widget _buildMusica(String titulo, String artista, String descricao) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8E7B9).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF9E8A4A).withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Para telas muito pequenas, empilha verticalmente
          if (constraints.maxWidth < 400) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.music_note,
                      color: Color(0xFFF8E7B9),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titulo,
                            style: GoogleFonts.cinzel(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFF8E7B9),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            artista,
                            style: GoogleFonts.cinzel(
                              fontSize: 11,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 44),
                  child: Text(
                    descricao,
                    style: GoogleFonts.cinzel(
                      fontSize: 12,
                      color: const Color(0xFF9E8A4A),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            );
          }
          // Layout padrão horizontal
          return Row(
            children: [
              const Icon(Icons.music_note, color: Color(0xFFF8E7B9), size: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: GoogleFonts.cinzel(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF8E7B9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      artista,
                      style: GoogleFonts.cinzel(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descricao,
                      style: GoogleFonts.cinzel(
                        fontSize: 12,
                        color: const Color(0xFF9E8A4A),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
