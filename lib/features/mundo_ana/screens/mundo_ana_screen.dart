import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Etapas do diálogo — EDITE os nomes para o seu mundo
// ─────────────────────────────────────────────────────────────────────────────
enum _Etapa {
  carregando,
  chegada1,
  chegada2,
  chegada3,
  jogadorFala,
  reacao1,
  reacao2,
  reacao3,
  missao1,
  missao2,
  missao3,
  despedida,
}


class MundoAnaScreen extends StatefulWidget {
  const MundoAnaScreen({super.key});

  @override
  State<MundoAnaScreen> createState() => _MundoAnaScreenState();
}

class _MundoAnaScreenState extends State<MundoAnaScreen>
    with TickerProviderStateMixin {
  _Etapa _etapa = _Etapa.carregando;
  String _nomeJogador = 'Viajante'; // fallback enquanto carrega
  String _textoExibido = '';
  bool _textoTerminou = false;
  bool _mostrarNpc = false;
  bool _mostrarDialogo = false;
  bool _erroBusca = false;

  bool _somAtivado = false;
  bool _audioLiberado = false;
  bool _tocandoSomLetra = false;
  late AudioPlayer _audioPlayer;

  late AnimationController _npcAnimCtrl;
  late AnimationController _dialogoAnimCtrl;
  late AnimationController _shakeCtrl;

  late Animation<double> _npcScale;
  late Animation<double> _npcRotate;
  late Animation<double> _shakeAnim;


  String get _textoAtual {
    switch (_etapa) {
      case _Etapa.carregando:
        return '';

      // Ana fala primeiro
      case _Etapa.chegada1:
        return 'Olá, viajante. Você atravessou portas que poucos sobreviveriam. Mas Terrasen não se curva a qualquer um. Eu sou Aelin Galathynius e este é um fragmento de Terrasen, um reino marcado por magia, resistência e reconstrução.'; 
      case _Etapa.chegada2:
        return ''; // ✏️ edite
      case _Etapa.chegada3:
        return 'Diga-me... o que te trouxe até aqui?'; // ✏️ edite

      // Jogador se apresenta (usa o nome do Firestore)
      case _Etapa.jogadorFala:
        return 'Sou $_nomeJogador! Vim até você para [motivo].'; // ✏️ edite

      // Ana reage
      case _Etapa.reacao1:
        return 'Que ótimo, $_nomeJogador!'; // ✏️ edite
      case _Etapa.reacao2:
        return '[Reação do Ana sobre o jogador].'; // ✏️ edite
      case _Etapa.reacao3:
        return 'Então tenho uma missão especial para ti!'; // ✏️ edite

      // Missão / continuação
      case _Etapa.missao1:
        return '[Explique a missão ou o contexto do seu mundo].'; // ✏️ edite
      case _Etapa.missao2:
        return '[Continue explicando — detalhe importante].'; // ✏️ edite
      case _Etapa.missao3:
        return '[Último detalhe antes da despedida].'; // ✏️ edite

      // Despedida
      case _Etapa.despedida:
        return 'Boa sorte, $_nomeJogador. Que sua jornada seja gloriosa!'; // ✏️ edite
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
    _buscarNomeEIniciar();
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
  }

  @override
  void dispose() {
    _npcAnimCtrl.dispose();
    _dialogoAnimCtrl.dispose();
    _shakeCtrl.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Busca nome no Firestore e inicia cena
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _buscarNomeEIniciar() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('personagens')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final nome = data['nome'] as String?;
        if (nome != null && nome.isNotEmpty) {
          if (mounted) setState(() => _nomeJogador = nome);
        }
      }
    } catch (e) {
      debugPrint('[MundoAna] Erro ao buscar personagem: $e');
      if (mounted) setState(() => _erroBusca = true);
    }

    await _iniciarCena();
  }

  Future<void> _iniciarCena() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    setState(() {
      _mostrarNpc = true;
      _etapa = _Etapa.chegada1;
    });
    _npcAnimCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    setState(() => _mostrarDialogo = true);
    _dialogoAnimCtrl.forward();

    await _animarTexto(_textoAtual);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Som
  // ─────────────────────────────────────────────────────────────────────────
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
  // Fluxo de diálogo — sequência linear, sem minigame
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _avancarDialogo() async {
    if (!_textoTerminou) return;
    await _executarShake();

    const sequencia = {
      _Etapa.chegada1: _Etapa.chegada2,
      _Etapa.chegada2: _Etapa.chegada3,
      _Etapa.chegada3: _Etapa.jogadorFala,
      _Etapa.jogadorFala: _Etapa.reacao1,
      _Etapa.reacao1: _Etapa.reacao2,
      _Etapa.reacao2: _Etapa.reacao3,
      _Etapa.reacao3: _Etapa.missao1,
      _Etapa.missao1: _Etapa.missao2,
      _Etapa.missao2: _Etapa.missao3,
      _Etapa.missao3: _Etapa.despedida,
    };

    // Última etapa — volta para o menu
    if (_etapa == _Etapa.despedida) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final proxima = sequencia[_etapa];
    if (proxima != null) {
      setState(() => _etapa = proxima);
      await _animarTexto(_textoAtual);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────
  bool get _ehFalaJogador => _etapa == _Etapa.jogadorFala;

  String get _labelBotao {
    if (_etapa == _Etapa.despedida) return 'Encerrar ✨';
    return 'Continuar →';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ✏️ Mude o título para o nome do seu mundo
        title: Text(
          'Terrasen',
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
          // ✏️ Troque 'fundo_fazenda.jpeg' pela sua imagem de fundo
          // (coloque o arquivo em assets/images/ e declare no pubspec.yaml)
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fundo_terrasen.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF2D1A0A)),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.55)),

          // Loading enquanto busca o nome
          if (_etapa == _Etapa.carregando)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFF8E7B9)),
            ),

          if (_etapa != _Etapa.carregando)
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

  // ── Ana ───────────────────────────────────────────────────────────────────
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
            return Transform.translate(offset: Offset(offset, 0), child: child);
          },
          child: ScaleTransition(
            scale: _npcScale,
            child: RotationTransition(
              turns: _npcRotate,
              // ✏️ Troque pela imagem do seu Ana (coloque em assets/images/)
              child: Image.asset(
                'assets/images/aelin.png',
                height: 220,
                errorBuilder: (_, __, ___) => const SizedBox(
                  height: 220,
                  child: Icon(Icons.person, size: 100, color: Color(0xFFF8E7B9)),
                ),
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
            border: Border.all(color: const Color(0xFF9E8A4A), width: 2),
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
              _buildBadgeFalante(),
              const SizedBox(height: 8),
              Text(
                _textoExibido,
                style: GoogleFonts.cinzel(
                  fontSize: 15,
                  height: 1.65,
                  color: _ehFalaJogador
                      ? const Color(0xFFF8E7B9).withValues(alpha: 0.7)
                      : const Color(0xFFF8E7B9),
                  fontStyle: _ehFalaJogador
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
              const SizedBox(height: 16),
              if (_etapa != _Etapa.carregando)
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
                        horizontal: 24,
                        vertical: 12,
                      ),
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
                      style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeFalante() {
    final bool isJogador = _ehFalaJogador;
    // ✏️ Troque 'Ana' pelo nome do seu personagem
    final String nome = isJogador ? _nomeJogador : 'Aelin';
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
}