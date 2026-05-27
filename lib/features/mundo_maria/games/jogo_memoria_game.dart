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

    // ── Sequência orquestrada ─────────────────────────────────────────────────
    _runSequence();
  }

  Future<void> _runSequence() async {
    // Passo 1: fundo escurece
    await _bgController.forward();
    // Passo 2: ferradura cresce
    await _ferrController.forward();
    // Passo 3: brilho começa a pulsar (não awaita — roda em loop)
    _glowController.repeat(reverse: true);
    // Passo 4: texto sobe e aparece (pequena pausa dramática)
    await Future.delayed(const Duration(milliseconds: 200));
    await _textoController.forward();
    // Passo 5: botão aparece
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
            // Fundo com gradiente radial dourado
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
                                    color: Colors.amber.withValues(alpha: 0.8),
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
                              // Brilho âmbar interno
                              BoxShadow(
                                color: Colors.amberAccent
                                    .withValues(alpha: glowAlpha * 0.8),
                                blurRadius: glow,
                                spreadRadius: glow * 0.35,
                              ),
                              // Halo laranja externo
                              BoxShadow(
                                color: const Color(0xFFFF8C00)
                                    .withValues(alpha: glowAlpha * 0.5),
                                blurRadius: glow * 2.2,
                                spreadRadius: glow * 0.15,
                              ),
                              // Reflexo branco central suave
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
                            errorBuilder: (_, __, ___) => Text(
                              '🐴',
                              style: TextStyle(fontSize: 160),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Subtitle embaixo da ferradura ───────────────────────────
                  Opacity(
                    opacity: _textoOpacity.value,
                    child: Text(
                      '✦ A Ferradura ✦',
                      style: GoogleFonts.cinzel(
                        fontSize: 13,
                        color:
                            Colors.amberAccent.withValues(alpha: 0.75),
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
                            backgroundColor:
                                WidgetStateProperty.all(
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
class JogoMemoriaGame extends StatefulWidget {
  const JogoMemoriaGame({super.key});

  @override
  State<JogoMemoriaGame> createState() => _JogoMemoriaGameState();
}

class _JogoMemoriaGameState extends State<JogoMemoriaGame> {
  static const String _ferraduraAsset =
      'assets/images/icons/ferradura_icon.png';
  static const List<String> _cultivosAssets = [
    'assets/images/icons/abobora_icon.png',
    'assets/images/icons/milho_icon.png',
    'assets/images/icons/girassol_icon.png',
    'assets/images/icons/trigo_icon.png',
  ];
  static const int _totalPares = 4;

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
          AssetSource('audio/music/audio_fazenda_vale_dourado.mp3'));
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      debugPrint('Erro ao iniciar música no Memória: $e');
    }
  }

  Future<void> _pararMusica() async {
    try {
      await _musicPlayer.stop();
      await _musicPlayer.dispose();
    } catch (e) {
      debugPrint('Erro ao parar música no Memória: $e');
    }
  }

  @override
  void dispose() {
    _pararMusica();
    super.dispose();
  }

  late List<String> cartas;
  late List<bool> combinadas;
  late List<bool> reveladas;

  int? primeiroIndex;
  bool bloqueado = false;

  int pontuacao = 0;
  int paresEncontrados = 0;

  // Controla se o overlay cinematográfico está visível
  bool _mostrarReveal = false;

  bool _salvoNoFirestore = false;

  Future<void> _precarregarImagens() async {
    final allAssets = [..._cultivosAssets, ..._cultivosAssets, _ferraduraAsset];
    for (var asset in allAssets) {
      await precacheImage(AssetImage(asset), context);
    }
  }

  void iniciarJogo() {
    final baralho = [..._cultivosAssets, ..._cultivosAssets, _ferraduraAsset]
      ..shuffle(Random());
    cartas = baralho;
    combinadas = List.generate(9, (_) => false);
    reveladas = List.generate(9, (_) => false);
    primeiroIndex = null;
    bloqueado = false;
    pontuacao = 0;
    paresEncontrados = 0;
    _mostrarReveal = false;
    _salvoNoFirestore = false;
  }

  String _getEmojiForAsset(String assetPath) {
    if (assetPath == _ferraduraAsset) return '🐴';
    if (assetPath.contains('abobora')) return '🎃';
    if (assetPath.contains('milho')) return '🌽';
    if (assetPath.contains('girassol')) return '🌻';
    if (assetPath.contains('trigo')) return '🌾';
    return '?';
  }

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
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final idx = cartas.indexOf(_ferraduraAsset);
      setState(() {
        reveladas[idx] = true;
        combinadas[idx] = true;
      });

      // Pequena pausa para o jogador ver a ferradura na grade antes do reveal
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() => _mostrarReveal = true);
      });
    });
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
                  color: const Color(0xFF9E8A4A).withOpacity(0.4),
                  blurRadius: 25,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🐴 Jogo Concluído! 🐴',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFF8E7B9),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Todos os pares foram encontrados!\nPontuação final: $pontuacao pontos\n\nSua jornada na Fazenda Vale-Dourado foi registrada.\n\nDeseja encerrar sua aventura agora ou continuar explorando os mundos?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFF8E7B9),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_done,
                        color: Colors.greenAccent, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Progresso será salvo',
                      style: GoogleFonts.cinzel(
                          fontSize: 11, color: Colors.greenAccent),
                    ),
                  ],
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
                      child: Text('💾 Salvar e sair',
                          style: GoogleFonts.cinzel(
                              fontWeight: FontWeight.bold)),
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
                                child: const MundoLuisScreen(),  // 
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
                      child: Text('⚔️ Salvar e continuar',
                          style: GoogleFonts.cinzel(
                              fontWeight: FontWeight.bold)),
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

  Widget _buildImageCard(String assetPath, {double size = 55}) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          Text(_getEmojiForAsset(assetPath), style: TextStyle(fontSize: size)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Jogo da Memória',
          style: GoogleFonts.cinzel(
              color: const Color(0xFFF8E7B9), fontSize: 18),
        ),
        backgroundColor: const Color(0xFF6B3F1D),
        foregroundColor: const Color(0xFFF8E7B9),
        toolbarHeight: 56,
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Color(0xFFF8E7B9), size: 20),
                const SizedBox(width: 6),
                Text(
                  '$pontuacao',
                  style: GoogleFonts.cinzel(
                      fontSize: 18, color: const Color(0xFFF8E7B9)),
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
          Container(color: Colors.black.withOpacity(0.6)),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          _buildDescricaoMeta(),
                          _buildContadorPares(),
                          const SizedBox(height: 12),
                          _buildGrade(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF6B3F1D).withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF8E7B9).withOpacity(0.6),
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
            'Encontre os 4 pares para revelar a ferradura!',
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              fontSize: 11,
              color: const Color(0xFFF8E7B9).withOpacity(0.85),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFF8E7B9).withOpacity(0.4),
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
              label: encontrado ? '✓' : '?',
              corLabel: encontrado
                  ? Colors.greenAccent
                  : const Color(0xFFF8E7B9).withOpacity(0.5),
            );
          }),
          _buildIconeContador(
            asset: _ferraduraAsset,
            encontrado: ferraduraRevelada,
            label: ferraduraRevelada ? '✓' : '🔒',
            corLabel: ferraduraRevelada
                ? Colors.amberAccent
                : const Color(0xFFF8E7B9).withOpacity(0.5),
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
            _buildImageCard(asset, size: 38),
            if (encontrado)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration:
                      BoxDecoration(color: corCheck, shape: BoxShape.circle),
                  child:
                      const Icon(Icons.check, size: 10, color: Colors.black),
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.cinzel(
              fontSize: 10, color: corLabel, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildGrade() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: SizedBox(
          width: 340,
          height: 340,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
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
    Color bgColor = const Color(0xFF8B5A2B).withOpacity(0.9);

    if (combinada && ehFerr) {
      borderColor = Colors.amberAccent;
      borderWidth = 2.5;
      bgColor = Colors.amber.withOpacity(0.25);
    } else if (combinada) {
      borderColor = Colors.greenAccent;
      borderWidth = 2.5;
      bgColor = Colors.green.withOpacity(0.2);
    } else if (reveladas[index]) {
      borderColor = Colors.white;
      borderWidth = 2;
      bgColor = const Color(0xFF6B3F1D).withOpacity(0.9);
    }

    return GestureDetector(
      onTap: () => _tocarCarta(index),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: BorderRadius.circular(14),
          color: visivel ? bgColor : const Color(0xFF8B5A2B).withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: visivel
              ? _buildImageCard(cartas[index], size: 50)
              : Icon(
                  Icons.question_mark_rounded,
                  size: 38,
                  color: const Color(0xFFF8E7B9).withOpacity(0.7),
                ),
        ),
      ),
    );
  }

  Widget _buildOverlayConclusao() {
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF6B3F1D),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF8E7B9), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🌟 Nível Concluído! 🌟',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzelDecorative(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF8E7B9),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '🐴 A ferradura trouxe sorte! 🐴',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  fontSize: 13,
                  color: Colors.amberAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Pontuação: $pontuacao',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  fontSize: 13,
                  color: const Color(0xFFF8E7B9).withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _mostrarPopupEscolhaFinal(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B3F1D),
                  foregroundColor: const Color(0xFFF8E7B9),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Color(0xFFF8E7B9), width: 1),
                  ),
                ),
                child: Text(
                  'Continuar ➡️',
                  style: GoogleFonts.cinzel(
                    fontSize: 14,
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
