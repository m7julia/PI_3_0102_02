import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum _Etapa {
  carregando,
  chegada1,
  chegada2,
  chegada3,
  jogadorFala,
  reacao1,
  reacao2,
  reacao3,
  escolha,
  missao1,
  missao2,
  missao3,
  despedida,
}

class MundoGianScreen extends StatefulWidget {
  const MundoGianScreen({super.key});

  @override
  State<MundoGianScreen> createState() => _MundoGianScreenState();
}

class _MundoGianScreenState extends State<MundoGianScreen>
    with TickerProviderStateMixin {
  _Etapa _etapa = _Etapa.carregando;
  String _nomeJogador = 'Viajante';
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

  // ─────────────────────────────────────────────────────────────────────────
  // ✏️ TEXTOS — edite os diálogos do Gianluca aqui
  // ─────────────────────────────────────────────────────────────────────────
  String get _textoAtual {
    switch (_etapa) {
      case _Etapa.carregando:
        return '';
      case _Etapa.chegada1:
        return 'Bem-vindo ao Conservatório, vi"AU"jante!'; 
      case _Etapa.chegada2:
        return 'Sou Ludwig San Beernardo, mestre das melodias harmônicas.';
      case _Etapa.chegada3:
        return 'Diga-me... o que te trouxe até "AU"qui?'; 
      case _Etapa.jogadorFala:
        return 'Sou $_nomeJogador! Vim até você porque preciso encontrar uma saída.';
      case _Etapa.reacao1:
        return 'Deveras impressionante, $_nomeJogador!'; 
      case _Etapa.reacao2:
        return 'A música escolhe seus aprendizes com cuidado, posso ser de grande ajuda...';
      case _Etapa.reacao3:
        return 'Mas precisaria que me "AU"judasse primeiro. Ao tentar fazer a melodia proibida fui enfeitiçado pelo Sol Meio Diminuto e virei um cachorro!';
      case _Etapa.escolha:
        return 'Só serei liberto quando ensinar alguém a harmonia básica, aceita fazer parte disso, $_nomeJogador?';
      case _Etapa.missao1:
        return 'A música é a linguagem da alma, $_nomeJogador.';
      case _Etapa.missao2:
        return 'Cada nota carrega uma emoção diferente.';
      case _Etapa.missao3:
        return 'Aprenda a ouvi-las e o mundo se transformará.';
      case _Etapa.despedida:
        return 'Que sua jornada seja harmoniosa, $_nomeJogador!';
    }
  }

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
      debugPrint('[MundoGian] Erro ao buscar personagem: $e');
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

  bool get _ehFalaJogador => _etapa == _Etapa.jogadorFala;

  String get _labelBotao {
    if (_etapa == _Etapa.despedida) return 'Encerrar ✨';
    return 'Continuar →';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Conservatório Diminuto',
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
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background_conservatorio.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF2D1A0A)),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.55)),

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
              
            ),
          ),
        ),
      ),
    );
  }

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
                  fontStyle:
                      _ehFalaJogador ? FontStyle.italic : FontStyle.normal,
                ),
              ),
              const SizedBox(height: 16),
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
                          color: Color(0xFF9E8A4A), width: 1.5),
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
    final String nome =
        isJogador ? _nomeJogador : 'Ludwig San Beethoven';
    final Color cor =
        isJogador ? const Color(0xFF9E8A4A) : const Color(0xFF6B3F1D);
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