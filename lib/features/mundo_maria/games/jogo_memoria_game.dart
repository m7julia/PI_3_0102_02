import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/nivel_service.dart';

class JogoMemoriaGame extends StatefulWidget {
  const JogoMemoriaGame({super.key});

  @override
  State<JogoMemoriaGame> createState() => _JogoMemoriaGameState();
}

class _JogoMemoriaGameState extends State<JogoMemoriaGame> {
  // ── constantes ────────────────────────────────────────────────────────────
  static const String _ferraduraAsset =
      'assets/images/icons/ferradura_icon.png';
  static const List<String> _cultivosAssets = [
    'assets/images/icons/abobora_icon.png',
    'assets/images/icons/milho_icon.png',
    'assets/images/icons/girassol_icon.png',
    'assets/images/icons/trigo_icon.png',
  ];
  static const List<String> _cultivosEmojis = [
    '🎃',
    '🌽',
    '🌻',
    '🌾',
  ]; // Para fallback/texto
  static const int _totalPares = 4;

  // ── estado ────────────────────────────────────────────────────────────────
  late List<String> cartas; // caminho do asset em cada posição
  late List<bool> combinadas;
  late List<bool> reveladas;

  int? primeiroIndex;
  bool bloqueado = false;

  bool ferraduraRevelada = false;

  int pontuacao = 0;
  int paresEncontrados = 0;
  bool faseConcluida = false;

  // Cache de imagens pré-carregadas
  Map<String, Widget> _imageCache = {};

  @override
  void initState() {
    super.initState();
    _precarregarImagens();
    iniciarJogo();
  }

  // ── pré-carregamento das imagens ──────────────────────────────────────────
  Future<void> _precarregarImagens() async {
    final allAssets = [..._cultivosAssets, ..._cultivosAssets, _ferraduraAsset];
    for (var asset in allAssets) {
      await precacheImage(AssetImage(asset), context);
    }
  }

  // ── inicialização ─────────────────────────────────────────────────────────
  void iniciarJogo() {
    // 4 pares de cultivos (8 cartas) + 1 ferradura = 9 cartas
    final baralho = [..._cultivosAssets, ..._cultivosAssets, _ferraduraAsset]
      ..shuffle(Random());

    cartas = baralho;
    combinadas = List.generate(9, (_) => false);
    reveladas = List.generate(9, (_) => false);
    primeiroIndex = null;
    bloqueado = false;
    pontuacao = 0;
    paresEncontrados = 0;
    faseConcluida = false;
  }

  // ── obter emoji correspondente ao asset (para fallback) ───────────────────
  String _getEmojiForAsset(String assetPath) {
    if (assetPath == _ferraduraAsset) return '🐴';

    if (assetPath.contains('abobora')) return '🎃';
    if (assetPath.contains('milho')) return '🌽';
    if (assetPath.contains('girassol')) return '🌻';
    if (assetPath.contains('trigo')) return '🌾';

    return '?';
  }

  // ── lógica principal ──────────────────────────────────────────────────────
  void _tocarCarta(int index) {
    if (bloqueado) return;
    if (combinadas[index]) return;
    if (reveladas[index]) return;

    setState(() => reveladas[index] = true);

    if (primeiroIndex == null) {
      primeiroIndex = index;
      return;
    }

    final primeiro = primeiroIndex!;
    primeiroIndex = null;

    if (cartas[primeiro] == cartas[index]) {
      // PAR ENCONTRADO
      setState(() {
        combinadas[primeiro] = true;
        combinadas[index] = true;
        pontuacao += 10;
        paresEncontrados++;
      });

      if (paresEncontrados == _totalPares) {
        _revelarFerraduraEConcluir();
      }
    } else {
      bloqueado = true;
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() {
          reveladas[primeiro] = false;
          reveladas[index] = false;
          bloqueado = false;
        });
      });
    }
  }

  void _revelarFerraduraEConcluir() {
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      final idx = cartas.indexOf(_ferraduraAsset);
      setState(() {
        reveladas[idx] = true;
        combinadas[idx] = true;
      });

      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() => faseConcluida = true);
      });
    });
  }

  // ── widgets de imagem com fallback ────────────────────────────────────────
  Widget _buildImageCard(String assetPath, {double size = 60}) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback para emoji se a imagem não carregar
        return Text(
          _getEmojiForAsset(assetPath),
          style: TextStyle(fontSize: size),
        );
      },
    );
  }

  // ── build principal ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Jogo da Memória',
          style: GoogleFonts.cinzel(color: const Color(0xFFF8E7B9)),
        ),
        backgroundColor: const Color(0xFF6B3F1D),
        foregroundColor: const Color(0xFFF8E7B9),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Color(0xFFF8E7B9)),
                const SizedBox(width: 8),
                Text(
                  '$pontuacao',
                  style: GoogleFonts.cinzel(
                    fontSize: 18,
                    color: const Color(0xFFF8E7B9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fundo_fazenda.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF6B3F1D),
                  child: const Center(child: Text('Fundo não encontrado')),
                );
              },
            ),
          ),
          Container(
            color: Colors.black.withValues(
              alpha: 0.6,
            ), // Substituído withOpacity
          ),
          SafeArea(
            child: Column(
              children: [
                _buildDescricaoMeta(),
                _buildContadorPares(),
                Expanded(child: _buildGrade()),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () => setState(() => iniciarJogo()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B3F1D),
                      foregroundColor: const Color(0xFFF8E7B9),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                          color: Color(0xFFF8E7B9),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      'Novo Jogo',
                      style: GoogleFonts.cinzel(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (faseConcluida) _buildFaseConcluida(),
        ],
      ),
    );
  }

  // ── widgets auxiliares ────────────────────────────────────────────────────
  Widget _buildDescricaoMeta() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF6B3F1D).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF8E7B9).withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            '🧠 Jogo da Memória 🧠',
            style: GoogleFonts.cinzel(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFF8E7B9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Vire 2 cartas por vez e encontre os pares.\nAche todos os 4 pares para revelar a ferradura!',
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              fontSize: 11,
              color: const Color(0xFFF8E7B9).withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContadorPares() {
    final ferraduraIdx = cartas.indexOf(_ferraduraAsset);
    final ferraduraRevelada = ferraduraIdx >= 0 && combinadas[ferraduraIdx];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF8E7B9).withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ..._cultivosAssets.asMap().entries.map((entry) {
            final asset = entry.value;
            final idx1 = cartas.indexOf(asset);
            final idx2 = cartas.lastIndexOf(asset);
            final encontrado =
                idx1 >= 0 && idx2 >= 0 && combinadas[idx1] && combinadas[idx2];
            return _buildIconeContador(
              asset: asset,
              encontrado: encontrado,
              label: encontrado ? 'Par!' : '?/?',
              corLabel: encontrado
                  ? Colors.greenAccent
                  : const Color(0xFFF8E7B9).withValues(alpha: 0.5),
            );
          }),
          _buildIconeContador(
            asset: _ferraduraAsset,
            encontrado: ferraduraRevelada,
            label: ferraduraRevelada ? 'Única!' : '🔒',
            corLabel: ferraduraRevelada
                ? Colors.amberAccent
                : const Color(0xFFF8E7B9).withValues(alpha: 0.5),
            corCheck: Colors.amberAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildIconeContador({
    required String asset,
    required bool encontrado,
    required String label,
    required Color corLabel,
    Color corCheck = Colors.greenAccent,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            _buildImageCard(asset, size: 36),
            if (encontrado)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: corCheck,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 9, color: Colors.black),
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.cinzel(
            fontSize: 10,
            color: corLabel,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGrade() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 9,
            itemBuilder: (context, index) => _buildCarta(index),
          ),
        ),
      ),
    );
  }

  Widget _buildCarta(int index) {
    final bool visivel = reveladas[index] || combinadas[index];
    final bool combinada = combinadas[index];
    final bool ehFerr = cartas[index] == _ferraduraAsset;

    Color borderColor = const Color(0xFFF8E7B9);
    double borderWidth = 2;
    Color bgColor = const Color(0xFF8B5A2B).withValues(alpha: 0.9);
    List<BoxShadow> sombras = [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 5,
        offset: const Offset(2, 2),
      ),
    ];

    if (combinada && ehFerr) {
      borderColor = Colors.amberAccent;
      borderWidth = 3;
      bgColor = Colors.amber.withValues(alpha: 0.25);
      sombras = [
        BoxShadow(
          color: Colors.amberAccent.withValues(alpha: 0.5),
          blurRadius: 12,
          spreadRadius: 3,
        ),
      ];
    } else if (combinada) {
      borderColor = Colors.greenAccent;
      borderWidth = 3;
      bgColor = Colors.green.withValues(alpha: 0.2);
      sombras = [
        BoxShadow(
          color: Colors.greenAccent.withValues(alpha: 0.4),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ];
    } else if (reveladas[index]) {
      borderColor = Colors.white;
      borderWidth = 2.5;
      bgColor = const Color(0xFF6B3F1D).withValues(alpha: 0.9);
    }

    return GestureDetector(
      onTap: () => _tocarCarta(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: BorderRadius.circular(16),
          color: visivel
              ? bgColor
              : const Color(0xFF8B5A2B).withValues(alpha: 0.9),
          boxShadow: sombras,
        ),
        child: visivel
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildImageCard(cartas[index], size: 70),
                    if (ehFerr)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Única!',
                          style: GoogleFonts.cinzel(
                            fontSize: 12,
                            color: Colors.amberAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              )
            : Center(
                child: Icon(
                  Icons.question_mark_rounded,
                  size: 48,
                  color: const Color(0xFFF8E7B9).withValues(alpha: 0.8),
                ),
              ),
      ),
    );
  }

  Widget _buildFaseConcluida() {
    return Container(
      color: Colors.black.withValues(alpha: 0.78),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF6B3F1D),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF8E7B9), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🌟 Nível Concluído! 🌟',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzelDecorative(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF8E7B9),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '🐴 A ferradura trouxe sorte! 🐴',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  fontSize: 15,
                  color: Colors.amberAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Todos os pares foram encontrados!\nPontuação: $pontuacao pontos',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  fontSize: 14,
                  color: const Color(0xFFF8E7B9).withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() => iniciarJogo()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8E7B9),
                  foregroundColor: const Color(0xFF6B3F1D),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Jogar Novamente',
                  style: GoogleFonts.cinzel(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
