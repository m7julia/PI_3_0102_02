import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:rpg_game/features/mundo_maria/games/jogo_memoria_game.dart';
import 'package:rpg_game/features/mundo_maria/games/ligue_3_game.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Etapas do diálogo
// ─────────────────────────────────────────────────────────────────────────────
enum _Etapa {
  chegada,         // Margarida se apresenta
  jogadorFala,     // Jogador menciona as notas de Beethoven
  reacao,          // "Que maravilha!"
  perguntaCaminho, // Pergunta sobre caminho curto ou longo
  escolha,         // Botões de escolha visíveis
  introMemoria,    // Narrativa do Jogo da Memória
  introLigue3,     // Narrativa do Ligue 3
}

// ─────────────────────────────────────────────────────────────────────────────
// MundoMariaScreen
// ─────────────────────────────────────────────────────────────────────────────
class MundoMariaScreen extends StatefulWidget {
  /// Nome do personagem vindo da tela anterior.
  final String nomeJogador;

  const MundoMariaScreen({super.key, required this.nomeJogador});

  @override
  State<MundoMariaScreen> createState() => _MundoMariaScreenState();
}

class _MundoMariaScreenState extends State<MundoMariaScreen>
    with TickerProviderStateMixin {

  // ── estado ─────────────────────────────────────────────────────────────────
  _Etapa _etapa = _Etapa.chegada;
  String _textoExibido = '';
  bool _textoTerminou = false;
  bool _mostrarNpc = false;
  bool _mostrarDialogo = false;

  // ── som ────────────────────────────────────────────────────────────────────
  bool _somAtivado = false;
  bool _audioLiberado = false;
  bool _tocandoSomLetra = false;
  late AudioPlayer _audioPlayer;

  // ── animações ──────────────────────────────────────────────────────────────
  late AnimationController _npcAnimCtrl;
  late AnimationController _dialogoAnimCtrl;
  late AnimationController _shakeCtrl;
  late AnimationController _opcaoAnimCtrl;

  late Animation<double> _npcScale;
  late Animation<double> _npcRotate;
  late Animation<double> _shakeAnim;
  late Animation<double> _opcaoScale;

  // ─────────────────────────────────────────────────────────────────────────
  // Textos por etapa
  // ─────────────────────────────────────────────────────────────────────────
  String get _textoAtual {
    switch (_etapa) {
      case _Etapa.chegada:
        return 'Bem-vindo à minha fazenda, viajante! Fico feliz em ver que o portal abriu. Sou Margarida, guardiã destas terras. Diga-me... o que te trouxe até aqui?';
      case _Etapa.jogadorFala:
        return 'Sou ${widget.nomeJogador}! Completei as notas de Beethoven e ganhei a chave do portal para chegar até você.';
      case _Etapa.reacao:
        return 'Que maravilha, ${widget.nomeJogador}! As melodias de Beethoven escolheram bem seu mensageiro. Que bom que chegou — já tenho a missão perfeita para ti!';
      case _Etapa.perguntaCaminho:
        return 'Mas antes de te enviar ao campo... preciso saber que tipo de aventureiro você é.\n\nVocê prefere o caminho curto e difícil, ou o caminho longo e mais fácil?';
      case _Etapa.escolha:
        return 'Escolha seu caminho, ${widget.nomeJogador}...';
      case _Etapa.introMemoria:
        return 'Para guardar a colheita de hoje, precisamos separar tudo em pares antes de levar ao celeiro. Cada item tem seu par — nada entra desemparelhado!\n\nVire as cartas e encontre os quatro pares da colheita. Mas fique atento: em algum lugar está a minha ferradura da sorte. Se a encontrar, me avise!';
      case _Etapa.introLigue3:
        return 'Os vegetais aqui crescem em grupos e só são colhidos de três em três. Para colher, ligue três do mesmo vegetal — eles saem da terra juntos!\n\nSua missão é coletar 6 unidades de cada vegetal: girassol, milho, trigo e abóbora. Quando completar tudo, venha me avisar!';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Ciclo de vida
  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _configurarAnimacoes();
    _audioPlayer = AudioPlayer();
    _iniciarCena();
  }

  void _configurarAnimacoes() {
    _npcAnimCtrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _npcScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _npcAnimCtrl, curve: Curves.elasticOut),
    );
    _npcRotate = Tween<double>(begin: -0.05, end: 0.0).animate(
      CurvedAnimation(parent: _npcAnimCtrl, curve: Curves.easeOut),
    );

    _dialogoAnimCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _shakeCtrl = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnim = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );

    _opcaoAnimCtrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _opcaoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _opcaoAnimCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _npcAnimCtrl.dispose();
    _dialogoAnimCtrl.dispose();
    _shakeCtrl.dispose();
    _opcaoAnimCtrl.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Lógica de cena e som
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _iniciarCena() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    setState(() => _mostrarNpc = true);
    _npcAnimCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    setState(() => _mostrarDialogo = true);
    _dialogoAnimCtrl.forward();

    await _animarTexto(_textoAtual);
  }

  Future<void> _toggleSom() async {
    if (!_somAtivado) {
      try {
        await _audioPlayer.setVolume(0.01);
        await _audioPlayer.play(AssetSource('audio/typewriter_click.mp3'));
        await Future.delayed(const Duration(milliseconds: 80));
        await _audioPlayer.stop();
        await _audioPlayer.setVolume(1.0);
        setState(() {
          _somAtivado = true;
          _audioLiberado = true;
        });
      } catch (e) {
        debugPrint('Erro ao ativar som: $e');
      }
    } else {
      setState(() => _somAtivado = false);
    }
  }

  Future<void> _tocarSomLetra() async {
    if (!_somAtivado || !_audioLiberado || _tocandoSomLetra) return;
    try {
      _tocandoSomLetra = true;
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/typewriter_click.mp3'));
    } catch (e) {
      debugPrint('Erro ao tocar som: $e');
    } finally {
      _tocandoSomLetra = false;
    }
  }

  Future<void> _animarTexto(String texto) async {
    setState(() {
      _textoExibido = '';
      _textoTerminou = false;
    });

    for (int i = 0; i < texto.length; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (!mounted) return;
      setState(() => _textoExibido += texto[i]);
      if (texto[i] != ' ' && i % 2 == 0) _tocarSomLetra();
    }

    if (!mounted) return;
    setState(() => _textoTerminou = true);
  }

  Future<void> _executarShake() async {
    _shakeCtrl.reset();
    await _shakeCtrl.forward();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Fluxo de diálogo
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _avancarDialogo() async {
    if (!_textoTerminou) return;

    switch (_etapa) {
      case _Etapa.chegada:
        // Jogador responde, Margarida reage em sequência
        await _executarShake();
        setState(() => _etapa = _Etapa.jogadorFala);
        await _animarTexto(_textoAtual);
        await Future.delayed(const Duration(milliseconds: 700));
        await _executarShake();
        setState(() => _etapa = _Etapa.reacao);
        await _animarTexto(_textoAtual);
        break;

      case _Etapa.reacao:
        await _executarShake();
        setState(() => _etapa = _Etapa.perguntaCaminho);
        await _animarTexto(_textoAtual);
        break;

      case _Etapa.perguntaCaminho:
        await _executarShake();
        setState(() => _etapa = _Etapa.escolha);
        await _animarTexto(_textoAtual);
        _opcaoAnimCtrl.forward();
        break;

      case _Etapa.introMemoria:
        _irParaJogo(memoria: true);
        break;

      case _Etapa.introLigue3:
        _irParaJogo(memoria: false);
        break;

      default:
        break;
    }
  }

  Future<void> _escolherCaminhoMemoria() async {
    _opcaoAnimCtrl.reset();
    await _executarShake();
    setState(() => _etapa = _Etapa.introMemoria);
    await _animarTexto(_textoAtual);
  }

  Future<void> _escolherCaminhoLigue3() async {
    _opcaoAnimCtrl.reset();
    await _executarShake();
    setState(() => _etapa = _Etapa.introLigue3);
    await _animarTexto(_textoAtual);
  }

  void _irParaJogo({required bool memoria}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) =>
            memoria ? const JogoMemoriaGame() : const Ligue3Game(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────
  bool get _mostrarBotaoContinuar =>
      _etapa != _Etapa.escolha && _etapa != _Etapa.jogadorFala;

  String get _labelBotao {
    if (_etapa == _Etapa.introMemoria || _etapa == _Etapa.introLigue3) {
      return 'Vamos lá!';
    }
    return 'Continuar';
  }

  bool get _ehFalaJogador => _etapa == _Etapa.jogadorFala;

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mundo da Maria',
          style: GoogleFonts.cinzel(
            color: const Color(0xFFF8E7B9),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6B3F1D),
        foregroundColor: const Color(0xFFF8E7B9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _toggleSom,
            icon: Icon(
              _somAtivado ? Icons.volume_up : Icons.volume_off,
              color: const Color(0xFFF8E7B9),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fundo
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fundo_fazenda.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF2D1A0A)),
            ),
          ),
          // Overlay
          Container(color: Colors.black.withValues(alpha: 0.55)),

          // Conteúdo
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Spacer(),
                  _buildNpc(),
                  const SizedBox(height: 20),
                  _buildCaixaDialogo(),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── NPC Margarida ─────────────────────────────────────────────────────────
  Widget _buildNpc() {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      offset: _mostrarNpc ? Offset.zero : const Offset(0, 0.2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 700),
        opacity: _mostrarNpc ? 1 : 0,
        child: AnimatedBuilder(
          animation: _shakeAnim,
          builder: (context, child) {
            final offset = sin(_shakeAnim.value * 6 * pi) * 8;
            return Transform.translate(
              offset: Offset(offset, 0),
              child: child,
            );
          },
          child: ScaleTransition(
            scale: _npcScale,
            child: RotationTransition(
              turns: _npcRotate,
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/margarida_npc.png',
                    width: 190,
                    height: 190,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B3F1D).withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFF8E7B9).withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Text('🌸', style: TextStyle(fontSize: 72)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                      CurvedAnimation(
                          parent: _npcAnimCtrl, curve: Curves.elasticOut),
                    ),
                    child: Text(
                      'Margarida',
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 20,
                        color: const Color(0xFFF8E7B9),
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    'Guardiã da Fazenda',
                    style: GoogleFonts.cinzel(
                      fontSize: 11,
                      color: const Color(0xFFF8E7B9).withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Caixa de diálogo ──────────────────────────────────────────────────────
  Widget _buildCaixaDialogo() {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      offset: _mostrarDialogo ? Offset.zero : const Offset(0, 0.3),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 700),
        opacity: _mostrarDialogo ? 1 : 0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.78),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge de quem está falando
              _buildBadgeFalante(),
              const SizedBox(height: 8),

              // Texto animado
              Text(
                _textoExibido,
                style: GoogleFonts.cinzel(
                  fontSize: 15,
                  height: 1.65,
                  color: _ehFalaJogador
                      ? const Color(0xFFF8E7B9).withValues(alpha: 0.7)
                      : const Color(0xFFF8E7B9),
                  fontStyle:
                      _ehFalaJogador ? FontStyle.italic : FontStyle.normal,
                ),
              ),

              const SizedBox(height: 16),

              // Opções de caminho
              if (_etapa == _Etapa.escolha && _textoTerminou)
                ScaleTransition(
                  scale: _opcaoScale,
                  child: _buildOpcoesCaminho(),
                ),

              // Botão continuar
              if (_mostrarBotaoContinuar)
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _textoTerminou ? _avancarDialogo : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B3F1D),
                      foregroundColor: const Color(0xFFF8E7B9),
                      disabledBackgroundColor:
                          const Color(0xFF6B3F1D).withValues(alpha: 0.4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFF9E8A4A),
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Text(
                      _labelBotao,
                      style:
                          GoogleFonts.cinzel(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Badge de falante ──────────────────────────────────────────────────────
  Widget _buildBadgeFalante() {
    final bool isJogador = _ehFalaJogador;
    final String nome = isJogador ? widget.nomeJogador : 'Margarida';
    final Color cor = isJogador
        ? const Color(0xFF9E8A4A)
        : const Color(0xFF6B3F1D);
    final Color bordaCor = isJogador
        ? const Color(0xFF9E8A4A).withValues(alpha: 0.5)
        : const Color(0xFFF8E7B9).withValues(alpha: 0.3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bordaCor),
      ),
      child: Text(
        nome,
        style: GoogleFonts.cinzel(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFF8E7B9).withValues(alpha: 0.65),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ── Botões de escolha ─────────────────────────────────────────────────────
  Widget _buildOpcoesCaminho() {
    return Column(
      children: [
        _buildBotaoOpcao(
          label: '⚔️  Caminho curto e difícil',
          descricao: 'Jogo da Memória',
          cor: const Color(0xFFE24B4A),
          onPressed: _escolherCaminhoMemoria,
        ),
        const SizedBox(height: 10),
        _buildBotaoOpcao(
          label: '🌿  Caminho longo e mais fácil',
          descricao: 'Ligue 3',
          cor: const Color(0xFF639922),
          onPressed: _escolherCaminhoLigue3,
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildBotaoOpcao({
    required String label,
    required String descricao,
    required Color cor,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        splashColor: cor.withValues(alpha: 0.15),
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: cor.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.cinzel(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF8E7B9),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      descricao,
                      style: GoogleFonts.cinzel(
                        fontSize: 11,
                        color: cor.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: cor.withValues(alpha: 0.7),
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}