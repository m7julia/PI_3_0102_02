import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rpg_game/features/mundo_luis/screens/mundo_luis.dart';
import 'package:rpg_game/screens/home/home_screen.dart';
import 'package:rpg_game/services/nivel_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:rpg_game/models/location_gate_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// OVERLAY CINEMATOGRÁFICO DA FERRADURA
// ═══════════════════════════════════════════════════════════════════════════════
class FerradoraRevealOverlay extends StatefulWidget {
  final VoidCallback onContinuar;

  const FerradoraRevealOverlay({super.key, required this.onContinuar});

  @override
  State<FerradoraRevealOverlay> createState() =>
      _FerradoraRevealOverlayState();
}

class _FerradoraRevealOverlayState extends State<FerradoraRevealOverlay>
    with TickerProviderStateMixin {
  // 1. Fundo escurece
  late AnimationController _bgController;
  late Animation<double> _bgOpacity;

  // 2. Ferradura cresce do centro
  late AnimationController _ferrController;
  late Animation<double> _ferrScale;
  late Animation<double> _ferrOpacity;
  late Animation<double> _ferrRotation;

  // 3. Brilho pulsante após crescer
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  // 4. Texto aparece
  late AnimationController _textoController;
  late Animation<double> _textoOpacity;
  late Animation<Offset> _textoSlide;

  // 5. Botão aparece
  late AnimationController _btnController;
  late Animation<double> _btnOpacity;
  late Animation<double> _btnScale;

  @override
  void initState() {
    super.initState();

    // ── 1. Fundo ──────────────────────────────────────────────────────────────
    _bgController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _bgOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _bgController, curve: Curves.easeIn));

    // ── 2. Ferradura ──────────────────────────────────────────────────────────
    _ferrController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    _ferrScale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.15)
              .chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 70),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.15, end: 0.95)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 15),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.95, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 15),
    ]).animate(_ferrController);
    _ferrOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _ferrController,
            curve: const Interval(0.0, 0.3, curve: Curves.easeIn)));
    _ferrRotation = Tween<double>(begin: -0.15, end: 0.0).animate(
        CurvedAnimation(parent: _ferrController, curve: Curves.easeOutBack));

    // ── 3. Brilho pulsante ────────────────────────────────────────────────────
    _glowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600));
    _glowAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));

    // ── 4. Texto ──────────────────────────────────────────────────────────────
    _textoController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _textoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textoController, curve: Curves.easeIn));
    _textoSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(parent: _textoController, curve: Curves.easeOut));

    // ── 5. Botão ──────────────────────────────────────────────────────────────
    _btnController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _btnOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _btnController, curve: Curves.easeIn));
    _btnScale = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _btnController, curve: Curves.easeOutBack));

    _runSequence();
  }

  Future<void> _runSequence() async {
    await _bgController.forward();
    await _ferrController.forward();
    _glowController.repeat(reverse: true);
    await Future.delayed(const Duration(milliseconds: 200));
    await _textoController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    await _btnController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _ferrController.dispose();
    _glowController.dispose();
    _textoController.dispose();
    _btnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _bgController,
        _ferrController,
        _glowController,
        _textoController,
        _btnController,
      ]),
      builder: (context, _) {
        final double glow = 18 + (_glowAnim.value * 28);
        final double glowAlpha = 0.45 + (_glowAnim.value * 0.45);

        return Opacity(
          opacity: _bgOpacity.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  const Color(0xFF3D1F00).withValues(alpha: 0.97),
                  const Color(0xFF0D0700).withValues(alpha: 0.99),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // ── Texto principal ─────────────────────────────────────────
                  SlideTransition(
                    position: _textoSlide,
                    child: Opacity(
                      opacity: _textoOpacity.value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          children: [
                            Text(
                              'Ao armazenar toda a plantação',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cinzel(
                                fontSize: 15,
                                color: const Color(0xFFF8E7B9)
                                    .withValues(alpha: 0.85),
                                letterSpacing: 0.8,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'você conquistou a chave do portal',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cinzelDecorative(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.amberAccent,
                                letterSpacing: 1.2,
                                height: 1.4,
                                shadows: [
                                  Shadow(
                                    color:
                                        Colors.amber.withValues(alpha: 0.8),
                                    blurRadius: 18,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Ferradura animada ───────────────────────────────────────
                  Transform.rotate(
                    angle: _ferrRotation.value,
                    child: Transform.scale(
                      scale: _ferrScale.value,
                      child: Opacity(
                        opacity: _ferrOpacity.value,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amberAccent
                                    .withValues(alpha: glowAlpha * 0.8),
                                blurRadius: glow,
                                spreadRadius: glow * 0.35,
                              ),
                              BoxShadow(
                                color: const Color(0xFFFF8C00)
                                    .withValues(alpha: glowAlpha * 0.5),
                                blurRadius: glow * 2.2,
                                spreadRadius: glow * 0.15,
                              ),
                              BoxShadow(
                                color: Colors.white
                                    .withValues(alpha: glowAlpha * 0.15),
                                blurRadius: glow * 0.5,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/icons/ferradura_icon.png',
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Text(
                              '🐴',
                              style: TextStyle(fontSize: 160),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Opacity(
                    opacity: _textoOpacity.value,
                    child: Text(
                      '✦ A Ferradura ✦',
                      style: GoogleFonts.cinzel(
                        fontSize: 13,
                        color: Colors.amberAccent.withValues(alpha: 0.75),
                        letterSpacing: 3,
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── Botão continuar ─────────────────────────────────────────
                  Transform.scale(
                    scale: _btnScale.value,
                    child: Opacity(
                      opacity: _btnOpacity.value,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: ElevatedButton(
                          onPressed: widget.onContinuar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: const Color(0xFFF8E7B9),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 48, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(
                                  color: Color(0xFF9E8A4A), width: 1.5),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ).copyWith(
                            backgroundColor: WidgetStateProperty.all(
                              const Color(0xFF6B3F1D).withValues(alpha: 0.85),
                            ),
                          ),
                          child: Text(
                            'Continuar a jornada  ➡️',
                            style: GoogleFonts.cinzel(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// JOGO PRINCIPAL
// ═══════════════════════════════════════════════════════════════════════════════
class Ligue3Game extends StatefulWidget {
  const Ligue3Game({super.key});

  @override
  State<Ligue3Game> createState() => _Ligue3GameState();
}

class _Ligue3GameState extends State<Ligue3Game> {
  static const int gridSize = 5;
  static const int metaPorElemento = 6;

  late AudioPlayer _musicPlayer;
  bool _musicaAtivada = true;

  @override
  void initState() {
    super.initState();
    _precarregarImagens();
    _iniciarMusica();
    iniciarJogo();
  }

  Future<void> _iniciarMusica() async {
    try {
      _musicPlayer = AudioPlayer();
      await _musicPlayer.setVolume(0.5);
      await _musicPlayer.play(
        AssetSource('audio/music/audio_fazenda_vale_dourado.mp3'),
      );
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      debugPrint('Erro ao iniciar música no Ligue3: $e');
    }
  }

  Future<void> _pararMusica() async {
    try {
      await _musicPlayer.stop();
      await _musicPlayer.dispose();
    } catch (e) {
      debugPrint('Erro ao parar música no Ligue3: $e');
    }
  }

  @override
  void dispose() {
    _pararMusica();
    super.dispose();
  }

  static const List<Map<String, dynamic>> cultivos = [
    {
      'asset': 'assets/images/icons/girassol_icon.png',
      'nome': 'Girassol',
      'cor': Color(0xFFF9A825),
      'emoji': '🌻',
    },
    {
      'asset': 'assets/images/icons/milho_icon.png',
      'nome': 'Milho',
      'cor': Color(0xFF558B2F),
      'emoji': '🌽',
    },
    {
      'asset': 'assets/images/icons/trigo_icon.png',
      'nome': 'Trigo',
      'cor': Color(0xFFBF8C00),
      'emoji': '🌾',
    },
    {
      'asset': 'assets/images/icons/abobora_icon.png',
      'nome': 'Abóbora',
      'cor': Color(0xFFE64A19),
      'emoji': '🎃',
    },
  ];

  late List<List<String>> matriz;
  List<List<int>> selecionados = [];
  Map<String, int> colhidos = {};
  int pontuacao = 0;
  String mensagem = '';
  bool mensagemErro = false;
  bool faseConcluida = false;
  List<int>? dragOrigem;

  // Controla o overlay cinematográfico
  bool _mostrarReveal = false;

  bool _salvoNoFirestore = false;

  Future<void> _precarregarImagens() async {
    for (var cultivo in cultivos) {
      await precacheImage(AssetImage(cultivo['asset']), context);
    }
  }

  void iniciarJogo() {
    matriz = _gerarMatrizSemTrios();
    selecionados = [];
    colhidos = {for (var cultivo in cultivos) cultivo['asset'] as String: 0};
    pontuacao = 0;
    mensagem = '';
    mensagemErro = false;
    faseConcluida = false;
    _mostrarReveal = false;
    _salvoNoFirestore = false;
  }

  List<List<String>> _gerarMatrizSemTrios() {
    final rng = Random();
    List<String> pool = [];
    for (var cultivo in cultivos) {
      for (int k = 0; k < metaPorElemento; k++) {
        pool.add(cultivo['asset'] as String);
      }
    }
    pool.add(cultivos[rng.nextInt(cultivos.length)]['asset'] as String);

    List<List<String>> board;
    int tentativas = 0;
    do {
      pool.shuffle(rng);
      board = List.generate(
        gridSize,
        (r) => List.generate(gridSize, (c) => pool[r * gridSize + c]),
      );
      tentativas++;
      if (tentativas > 10000) break;
    } while (_temTrioInicial(board));

    return board;
  }

  bool _temTrioInicial(List<List<String>> b) {
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c <= gridSize - 3; c++) {
        if (b[r][c] == b[r][c + 1] && b[r][c] == b[r][c + 2]) return true;
      }
    }
    for (int c = 0; c < gridSize; c++) {
      for (int r = 0; r <= gridSize - 3; r++) {
        if (b[r][c] == b[r + 1][c] && b[r][c] == b[r + 2][c]) return true;
      }
    }
    return false;
  }

  String _getEmojiForAsset(String assetPath) {
    final cultivo = cultivos.firstWhere(
      (c) => c['asset'] == assetPath,
      orElse: () => cultivos[0],
    );
    return cultivo['emoji'] as String;
  }

  Color _getCorForAsset(String assetPath) {
    final cultivo = cultivos.firstWhere(
      (c) => c['asset'] == assetPath,
      orElse: () => cultivos[0],
    );
    return cultivo['cor'] as Color;
  }

  Widget _buildImageWidget(String assetPath, {double size = 32}) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          Text(_getEmojiForAsset(assetPath), style: TextStyle(fontSize: size)),
    );
  }

  void _tocarCelula(int linha, int coluna) {
    final pos = [linha, coluna];
    final jaSelected =
        selecionados.any((s) => s[0] == linha && s[1] == coluna);

    setState(() {
      if (jaSelected) {
        selecionados.removeWhere((s) => s[0] == linha && s[1] == coluna);
        return;
      }

      final assetAtual = matriz[linha][coluna];

      if (selecionados.isNotEmpty &&
          matriz[selecionados[0][0]][selecionados[0][1]] != assetAtual) {
        selecionados = [pos];
        return;
      }

      if (selecionados.length < 3) selecionados.add(pos);

      if (selecionados.length == 3) _tentarCombinar();
    });
  }

  void _tentarCombinar() {
    final asset = matriz[selecionados[0][0]][selecionados[0][1]];
    final todosIguais =
        selecionados.every((s) => matriz[s[0]][s[1]] == asset);

    if (!todosIguais) {
      selecionados = [];
      return;
    }

    colhidos[asset] = (colhidos[asset] ?? 0) + 3;
    pontuacao += 10;

    for (final pos in selecionados) {
      matriz[pos[0]][pos[1]] = '';
    }
    selecionados = [];

    _aplicarGravidade();
    _verificarFaseConcluida();

    mensagem = '+10 pontos colhidos!';
    mensagemErro = false;
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => mensagem = '');
    });
  }

  void _aplicarGravidade() {
    final rng = Random();
    for (int c = 0; c < gridSize; c++) {
      List<String> coluna = [];
      for (int r = gridSize - 1; r >= 0; r--) {
        if (matriz[r][c].isNotEmpty) coluna.add(matriz[r][c]);
      }
      while (coluna.length < gridSize) {
        coluna
            .add(cultivos[rng.nextInt(cultivos.length)]['asset'] as String);
      }
      for (int r = gridSize - 1; r >= 0; r--) {
        matriz[r][c] = coluna[gridSize - 1 - r];
      }
    }
    _corrigirTrios();
  }

  void _corrigirTrios() {
    bool houveCorrecao = true;
    int tentativas = 0;
    final rng = Random();
    while (houveCorrecao && tentativas < 100) {
      houveCorrecao = false;
      tentativas++;
      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c <= gridSize - 3; c++) {
          if (matriz[r][c] == matriz[r][c + 1] &&
              matriz[r][c] == matriz[r][c + 2]) {
            final outros = cultivos
                .map((e) => e['asset'] as String)
                .where((e) => e != matriz[r][c])
                .toList();
            matriz[r][c + 2] = outros[rng.nextInt(outros.length)];
            houveCorrecao = true;
          }
        }
      }
      for (int c = 0; c < gridSize; c++) {
        for (int r = 0; r <= gridSize - 3; r++) {
          if (matriz[r][c] == matriz[r + 1][c] &&
              matriz[r][c] == matriz[r + 2][c]) {
            final outros = cultivos
                .map((e) => e['asset'] as String)
                .where((e) => e != matriz[r][c])
                .toList();
            matriz[r + 2][c] = outros[rng.nextInt(outros.length)];
            houveCorrecao = true;
          }
        }
      }
    }
  }

  void _verificarFaseConcluida() {
    final completo = cultivos.every(
      (cultivo) =>
          (colhidos[cultivo['asset'] as String] ?? 0) >= metaPorElemento,
    );
    if (completo && !faseConcluida) {
      faseConcluida = true;
      // Pequena pausa antes de mostrar o overlay
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _mostrarReveal = true);
      });
    }
  }

  Future<void> _mostrarPopupEscolhaFinal() async {
    await _pararMusica();
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1208),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF9E8A4A), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9E8A4A).withValues(alpha: 0.4),
                  blurRadius: 25,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🎉 Fase Concluída! 🎉',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFF8E7B9),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Você colheu tudo!\nPontuação final: $pontuacao pontos\n\nSua jornada na Fazenda Vale-Dourado foi registrada.\n\nDeseja encerrar sua aventura agora ou continuar explorando os mundos?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFF8E7B9),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 28),
                Center(
                  child: SizedBox(
                    width: 260,
                    child: ElevatedButton(
                      onPressed: () async {
                        await NivelService.completarNivelMaju();
                        if (mounted) {
                          Navigator.of(context).pop();
                          Navigator.pushAndRemoveUntil(
                            this.context,
                            MaterialPageRoute(
                                builder: (_) => const HomeScreen()),
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B3F1D),
                        foregroundColor: const Color(0xFFF8E7B9),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(
                              color: Color(0xFF9E8A4A), width: 1.5),
                        ),
                      ),
                      child: Text(
                        '💾 Salvar e sair',
                        style:
                            GoogleFonts.cinzel(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: SizedBox(
                    width: 260,
                    child: ElevatedButton(
                      onPressed: () async {
                        await NivelService.completarNivelMaju();
                        if (mounted) {
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            this.context,
                            MaterialPageRoute(
                              builder: (_) => LocationGateWidget(
                                key: UniqueKey(),
                                localizacaoFase: const GeoPoint(
                                  -22.83347,
                                  -47.04992,
                                ),
                                nomeFase: 'Bar Pirata',
                                child: const MundoLuisScreen(),
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B3F1D),
                        foregroundColor: const Color(0xFFF8E7B9),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(
                              color: Color(0xFF9E8A4A), width: 1.5),
                        ),
                      ),
                      child: Text(
                        '⚔️ Salvar e continuar',
                        style:
                            GoogleFonts.cinzel(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _iniciarDrag(int linha, int coluna) {
    dragOrigem = [linha, coluna];
  }

  void _finalizarDrop(int linhaDestino, int colunaDestino) {
    if (dragOrigem == null) return;
    final lo = dragOrigem![0], co = dragOrigem![1];
    dragOrigem = null;

    if (lo == linhaDestino && co == colunaDestino) return;

    // Só permite mover para célula adjacente (cima, baixo, esquerda, direita)
    final diffLinha = (lo - linhaDestino).abs();
    final diffColuna = (co - colunaDestino).abs();
    final ehAdjacente = (diffLinha == 1 && diffColuna == 0) ||
        (diffLinha == 0 && diffColuna == 1);

    if (!ehAdjacente) return;

    setState(() {
      final tmp = matriz[lo][co];
      matriz[lo][co] = matriz[linhaDestino][colunaDestino];
      matriz[linhaDestino][colunaDestino] = tmp;
      selecionados = [];
      _verificarCombinacaoAutomatica();
    });
  }

  void _verificarCombinacaoAutomatica() {
    bool houveMatch = true;
    while (houveMatch) {
      houveMatch = false;
      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c <= gridSize - 3; c++) {
          if (matriz[r][c].isNotEmpty &&
              matriz[r][c] == matriz[r][c + 1] &&
              matriz[r][c] == matriz[r][c + 2]) {
            final asset = matriz[r][c];
            colhidos[asset] = (colhidos[asset] ?? 0) + 3;
            pontuacao += 10;
            matriz[r][c] = matriz[r][c + 1] = matriz[r][c + 2] = '';
            houveMatch = true;
          }
        }
      }
      for (int c = 0; c < gridSize; c++) {
        for (int r = 0; r <= gridSize - 3; r++) {
          if (matriz[r][c].isNotEmpty &&
              matriz[r][c] == matriz[r + 1][c] &&
              matriz[r][c] == matriz[r + 2][c]) {
            final asset = matriz[r][c];
            colhidos[asset] = (colhidos[asset] ?? 0) + 3;
            pontuacao += 10;
            matriz[r][c] = matriz[r + 1][c] = matriz[r + 2][c] = '';
            houveMatch = true;
          }
        }
      }
      if (houveMatch) _aplicarGravidade();
    }
    _verificarFaseConcluida();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ligue 3',
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
                const SizedBox(width: 6),
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
          // ── Fundo ────────────────────────────────────────────────────────────
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fundo_fazenda.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  Container(color: const Color(0xFF6B3F1D)),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.6)),

          // ── Conteúdo do jogo ──────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                _buildDescricaoMeta(),
                _buildContadores(),
                if (mensagem.isNotEmpty) _buildMensagem(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Toque 3 iguais ou arraste para mover',
                    style: GoogleFonts.cinzel(
                      fontSize: 12,
                      color:
                          const Color(0xFFF8E7B9).withValues(alpha: 0.75),
                    ),
                  ),
                ),
                Expanded(child: _buildGrade()),
              ],
            ),
          ),

          // ── Overlay cinematográfico da ferradura ──────────────────────────────
          if (_mostrarReveal)
            Positioned.fill(
              child: FerradoraRevealOverlay(
                onContinuar: () {
                  setState(() => _mostrarReveal = false);
                  _mostrarPopupEscolhaFinal();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDescricaoMeta() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
            '🌾 Meta da Fase 🌾',
            style: GoogleFonts.cinzel(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFF8E7B9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Combine grupos de 3 para colher 6 unidades\nde cada elemento da fazenda!',
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

  Widget _buildContadores() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
        children: cultivos.map((cultivo) {
          final asset = cultivo['asset'] as String;
          final cor = cultivo['cor'] as Color;
          final atual = colhidos[asset] ?? 0;
          final progresso = (atual / metaPorElemento).clamp(0.0, 1.0);
          final completo = atual >= metaPorElemento;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildImageWidget(asset, size: 36),
                      if (completo)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 9,
                              color: Colors.black,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progresso,
                      minHeight: 6,
                      backgroundColor:
                          const Color(0xFFF8E7B9).withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        completo ? Colors.greenAccent : cor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$atual/$metaPorElemento',
                    style: GoogleFonts.cinzel(
                      fontSize: 10,
                      color: completo
                          ? Colors.greenAccent
                          : const Color(0xFFF8E7B9),
                      fontWeight: completo
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMensagem() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(mensagem),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              mensagemErro ? Colors.red.shade700 : Colors.green.shade700,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          mensagem,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGrade() {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridSize,
              crossAxisSpacing: 7,
              mainAxisSpacing: 7,
            ),
            itemCount: gridSize * gridSize,
            itemBuilder: (context, index) {
              final linha = index ~/ gridSize;
              final coluna = index % gridSize;
              final asset = matriz[linha][coluna];
              final selecionado = selecionados.any(
                (s) => s[0] == linha && s[1] == coluna,
              );

              return DragTarget<List<int>>(
                onWillAcceptWithDetails: (details) => true,
                onAcceptWithDetails: (details) =>
                    _finalizarDrop(linha, coluna),
                builder: (context, candidateData, rejectedData) {
                  final highlight = candidateData.isNotEmpty;
                  return Draggable<List<int>>(
                    data: [linha, coluna],
                    onDragStarted: () => _iniciarDrag(linha, coluna),
                    feedback: Material(
                      color: Colors.transparent,
                      child: _buildImageWidget(asset, size: 40),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: _buildCelula(asset, false, false),
                    ),
                    child: GestureDetector(
                      onTap: () => _tocarCelula(linha, coluna),
                      child: _buildCelula(asset, selecionado, highlight),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCelula(String asset, bool selecionado, bool highlight) {
    final cor = _getCorForAsset(asset);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        border: Border.all(
          color: selecionado
              ? Colors.greenAccent
              : highlight
                  ? Colors.white
                  : const Color(0xFFF8E7B9).withValues(alpha: 0.7),
          width: selecionado || highlight ? 3 : 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
        color: selecionado
            ? cor.withValues(alpha: 0.4)
            : const Color(0xFF6B3F1D).withValues(alpha: 0.88),
        boxShadow: selecionado
            ? [
                BoxShadow(
                  color: cor.withValues(alpha: 0.55),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(child: _buildImageWidget(asset, size: 48)),
    );
  }
}