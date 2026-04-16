import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../services/personagem_service.dart';
import '../../../models/personagem.dart';

class CriarPersonagemScreen extends StatefulWidget {
  const CriarPersonagemScreen({super.key});

  @override
  State<CriarPersonagemScreen> createState() => _CriarPersonagemScreenState();
}

class _CriarPersonagemScreenState extends State<CriarPersonagemScreen>
    with TickerProviderStateMixin {
  final TextEditingController nomeController = TextEditingController();

  bool _salvando = false;
  int etapa = 0;
  String nomeJogador = '';

  String textoExibido = '';
  bool textoTerminou = false;

  bool mostrarNpc = false;
  bool mostrarDialogo = false;

  bool _somAtivado = false;
  bool _audioLiberado = false;
  bool _tocandoSomLetra = false;

  late AnimationController _npcAnimationController;
  late AnimationController _buttonAnimationController;
  late AnimationController _npcShakeController;
  late Animation<double> _npcScaleAnimation;
  late Animation<double> _npcRotateAnimation;
  late Animation<double> _npcShakeAnimation;
  late Animation<double> _buttonScaleAnimation;

  late AudioPlayer _audioPlayer;

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
      setState(() {
        _somAtivado = false;
      });
    }
  }

  final List<String> falasIniciais = [
    'Saudações, viajante...',
    'Há muito tempo aguardávamos sua chegada.',
    'Antes de começar sua jornada, diga-me: qual é o seu nome?',
  ];

  @override
  void initState() {
    super.initState();

    _npcAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _npcScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _npcAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _npcRotateAnimation = Tween<double>(begin: -0.05, end: 0.0).animate(
      CurvedAnimation(parent: _npcAnimationController, curve: Curves.easeOut),
    );

    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _buttonScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _npcShakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _npcShakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _npcShakeController, curve: Curves.elasticIn),
    );

    _audioPlayer = AudioPlayer();

    _iniciarCena();
  }

  Future<void> _iniciarCena() async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;
    setState(() => mostrarNpc = true);
    _npcAnimationController.forward();

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => mostrarDialogo = true);
    _buttonAnimationController.forward();

    await _animarTexto(textoAtualCompleto);
  }

  String get textoAtualCompleto {
    if (etapa == 3) {
      return 'Muito bem... então você será conhecido como $nomeJogador.\nSua jornada está prestes a começar.';
    }

    return falasIniciais[etapa];
  }

  Future<void> _tocarSomLetra() async {
    if (!_somAtivado || !_audioLiberado || _tocandoSomLetra) return;

    try {
      _tocandoSomLetra = true;
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/typewriter_click.mp3'));
    } catch (e) {
      debugPrint('Erro ao tocar som da letra: $e');
    } finally {
      _tocandoSomLetra = false;
    }
  }

  Future<void> _animarTexto(String texto) async {
    setState(() {
      textoExibido = '';
      textoTerminou = false;
    });

    for (int i = 0; i < texto.length; i++) {
      await Future.delayed(const Duration(milliseconds: 35));

      if (!mounted) return;

      setState(() {
        textoExibido += texto[i];
      });

      if (texto[i] != ' ' && i % 2 == 0) {
        _tocarSomLetra();
      }
    }

    if (!mounted) return;

    setState(() {
      textoTerminou = true;
    });
  }

  Future<void> _animarNpcShake() async {
    _npcShakeController.reset();
    await _npcShakeController.forward();
  }

  void avancarDialogo() {
    if (!textoTerminou) return;

    if (etapa < 2) {
      _animarNpcShake();
      setState(() {
        etapa++;
      });

      _animarTexto(textoAtualCompleto);
    }
  }

  Future<void> confirmarNome() async {
    final nome = nomeController.text.trim();

    if (nome.isEmpty) {
      _mostrarMensagem('Digite um nome para o personagem');
      return;
    }

    await _animarNpcShake();
    setState(() {
      nomeJogador = nome;
      etapa = 3;
    });

    await _animarTexto(textoAtualCompleto);
  }

  Future<void> finalizarCriacao() async {
    setState(() => _salvando = true);

    try {
      final service = PersonagemService();

      final personagem = Personagem(
        nome: nomeJogador,
        vidaAtual: 100,
        vidaMax: 100,
      );

      await service.criarPersonagem(personagem);

      _mostrarMensagem('Personagem criado com sucesso!');

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      _mostrarMensagem('Erro ao salvar: $e');
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  Future<void> _acaoBotaoPrincipal() async {
    if (_salvando || !textoTerminou) return;

    if (etapa == 2) {
      await confirmarNome();
    } else if (etapa == 3) {
      await finalizarCriacao();
    } else {
      avancarDialogo();
    }
  }

  void _mostrarMensagem(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.cinzel(color: const Color(0xFFF8E7B9)),
        ),
        backgroundColor: const Color(0xFF3B1F0A),
      ),
    );
  }

  @override
  void dispose() {
    nomeController.dispose();
    _npcAnimationController.dispose();
    _buttonAnimationController.dispose();
    _npcShakeController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/criar_personagem.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color.fromARGB(255, 158, 138, 74),
                            width: 1.5,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Color(0xFFF8E7B9),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color.fromARGB(255, 158, 138, 74),
                            width: 1.5,
                          ),
                        ),
                        child: IconButton(
                          onPressed: _toggleSom,
                          icon: Icon(
                            _somAtivado ? Icons.volume_up : Icons.volume_off,
                            color: const Color(0xFFF8E7B9),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  AnimatedSlide(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOut,
                    offset: mostrarNpc ? Offset.zero : const Offset(0, 0.25),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 700),
                      opacity: mostrarNpc ? 1 : 0,
                      child: AnimatedBuilder(
                        animation: _npcShakeAnimation,
                        builder: (context, child) {
                          final shake =
                              sin(_npcShakeAnimation.value * 6 * pi) * 8;
                          return Transform.translate(
                            offset: Offset(shake, 0),
                            child: child,
                          );
                        },
                        child: ScaleTransition(
                          scale: _npcScaleAnimation,
                          child: RotationTransition(
                            turns: _npcRotateAnimation,
                            child: Column(
                              children: [
                                Container(
                                  decoration: const BoxDecoration(),
                                  child: Image.asset(
                                    'assets/images/personagem_rafa.png',
                                    width: 210,
                                    height: 210,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ScaleTransition(
                                  scale: Tween<double>(begin: 0.8, end: 1.0)
                                      .animate(
                                        CurvedAnimation(
                                          parent: _npcAnimationController,
                                          curve: Curves.elasticOut,
                                        ),
                                      ),
                                  child: Text(
                                    'Motorista Suspeito',
                                    style: GoogleFonts.cinzelDecorative(
                                      fontSize: 22,
                                      color: const Color(0xFFF8E7B9),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedSlide(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOut,
                    offset: mostrarDialogo
                        ? Offset.zero
                        : const Offset(0, 0.35),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 700),
                      opacity: mostrarDialogo ? 1 : 0,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _buttonAnimationController,
                            curve: Curves.easeOut,
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color.fromARGB(255, 158, 138, 74),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(
                                  255,
                                  158,
                                  138,
                                  74,
                                ).withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                textoExibido,
                                style: GoogleFonts.cinzel(
                                  fontSize: 18,
                                  height: 1.5,
                                  color: const Color(0xFFF8E7B9),
                                ),
                              ),
                              if (etapa == 2 && textoTerminou) ...[
                                const SizedBox(height: 20),
                                TextField(
                                  controller: nomeController,
                                  style: GoogleFonts.cinzel(
                                    color: const Color(0xFFF8E7B9),
                                  ),
                                  cursorColor: const Color(0xFFF8E7B9),
                                  decoration: InputDecoration(
                                    hintText: 'Digite o nome do personagem',
                                    hintStyle: GoogleFonts.cinzel(
                                      color: const Color(
                                        0xFFF8E7B9,
                                      ).withOpacity(0.4),
                                    ),
                                    filled: true,
                                    fillColor: Colors.black.withOpacity(0.35),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color.fromARGB(
                                          255,
                                          158,
                                          138,
                                          74,
                                        ),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFF8E7B9),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ScaleTransition(
                                  scale: _buttonScaleAnimation,
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: _salvando || !textoTerminou
                                        ? null
                                        : _acaoBotaoPrincipal,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6B3F1D),
                                      foregroundColor: const Color(0xFFF8E7B9),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: const BorderSide(
                                          color: Color.fromARGB(
                                            255,
                                            158,
                                            138,
                                            74,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    child: _salvando
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xFFF8E7B9),
                                            ),
                                          )
                                        : Text(
                                            etapa == 2
                                                ? 'Confirmar'
                                                : etapa == 3
                                                ? 'Começar'
                                                : 'Continuar',
                                            style: GoogleFonts.cinzel(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
