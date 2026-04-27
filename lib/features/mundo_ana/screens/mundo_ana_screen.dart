import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum _Etapa {
  carregando,
  // Chegada
  chegada1,
  chegada2, // escolha aceitar/recusar
  // Missão
  missao1,
  missao2, // continuar
  // Desafio 1 — caminho
  desafio1,
  desafio1Erro,
  desafio1Sucesso,
  // Desafio 2 — criatura
  desafio2,
  desafio2SemBonus,
  desafio2Sucesso,
  // Desafio 3 — enigma
  desafio3,
  desafio3Erro,
  desafio3Sucesso,
  // Desafio 4 — ferido
  desafio4,
  desafio4Bonus,
  desafio4SemBonus,
  // Reunião dos fragmentos
  reuniao1,
  reuniao2, // continuar → formação
  // Finais
  finalPositivo1,
  finalPositivo2, // abrir portal
  finalNegativo1,
  finalNegativo2, // abrir portal
}

class MundoAnaScreen extends StatefulWidget {
  const MundoAnaScreen({super.key});

  @override
  State<MundoAnaScreen> createState() => _MundoAnaScreenState();
}

class _MundoAnaScreenState extends State<MundoAnaScreen>
    with TickerProviderStateMixin {
  _Etapa _etapa = _Etapa.carregando;
  String _nomeJogador = 'Viajante';
  String _textoExibido = '';
  bool _textoTerminou = false;
  bool _mostrarNpc = false;
  bool _mostrarDialogo = false;

  // Pontuação positiva (escolhas boas)
  int _pontosPositivos = 0;
  // Fragmentos coletados
  int _fragmentos = 0;
  // Vantagem no desafio da criatura
  bool _temVantagem = false;

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

      case _Etapa.chegada1:
        return 'Você atravessou portas que poucos sobreviveriam. Mas Terrasen não se curva a qualquer um. Eu sou Aelin Galathynius e este é um fragmento de Terrasen, um reino marcado por magia, resistência e reconstrução.';
      case _Etapa.chegada2:
        return 'Você aceita o desafio que Terrasen tem a oferecer?';

      case _Etapa.missao1:
        return 'O Amuleto de Orynth foi fragmentado. Para avançar, você deverá reconstruí-lo.';
      case _Etapa.missao2:
        return 'Cada fragmento está escondido em um desafio diferente. Coragem, sabedoria e coração serão postos à prova. Está preparado?';

      case _Etapa.desafio1:
        return 'Escolha o caminho correto para encontrar o primeiro fragmento.';
      case _Etapa.desafio1Erro:
        return 'Este caminho leva a um beco sem saída. A floresta sussurra... tente novamente, $_nomeJogador.';
      case _Etapa.desafio1Sucesso:
        return 'O Caminho C te conduz a uma clareira encantada. Um fragmento do Amuleto de Orynth brilha entre as raízes! ✨ Fragmento coletado: $_fragmentos/3';

      case _Etapa.desafio2:
        return 'Uma criatura surge à sua frente, bloqueando o caminho. O que você faz?';
      case _Etapa.desafio2SemBonus:
        return 'Você avança, mas a criatura deixou marcas. Continue com cautela, $_nomeJogador.';
      case _Etapa.desafio2Sucesso:
        return 'Ao observar, você percebe que a criatura está ferida e assustada. Ela se afasta e revela um segundo fragmento escondido atrás dela! ✨ Fragmento coletado: $_fragmentos/3';

      case _Etapa.desafio3:
        return 'Resolva o enigma para continuar:\n\n"Eu existia antes de tudo, mas nunca fui criado. Não tenho forma, mas moldo tudo. O que sou eu?"';
      case _Etapa.desafio3Erro:
        return 'Não é isso... O enigma permanece sem resposta. As runas continuam brilhando, esperando.';
      case _Etapa.desafio3Sucesso:
        return 'Correto! O presente é o único tempo que existe de verdade. As runas se iluminam e um terceiro fragmento cai aos seus pés! ✨ Fragmento coletado: $_fragmentos/3';

      case _Etapa.desafio4:
        return 'Você encontra alguém ferido pelo caminho, mas vê que tem um portal aberto à sua espera. O que você decide?';
      case _Etapa.desafio4Bonus:
        return 'Você para e ajuda. O ferido, grato, entrega um amuleto protetor. Seu coração acaba de ganhar um atributo positivo. +1 ✨';
      case _Etapa.desafio4SemBonus:
        return 'Você avança pelo portal. O objetivo foi alcançado, mas algo pesa em seu espírito.';

      case _Etapa.reuniao1:
        return 'Os fragmentos foram reunidos. O Amuleto de Orynth foi reconstruído.';
      case _Etapa.reuniao2:
        return 'Coragem. Sabedoria. Coração. Três forças, uma única chama. 🔥';

      case _Etapa.finalPositivo1:
        return 'Terrasen não vive em castelos, nem em coroas. Terrasen vive nas escolhas feitas quando ninguém está olhando.';
      case _Etapa.finalPositivo2:
        return 'Você carrega mais do que poder, $_nomeJogador — você carrega Terrasen. O portal aguarda.';

      case _Etapa.finalNegativo1:
        return 'Você tem poder, mas poder sem propósito é só destruição esperando para acontecer.';
      case _Etapa.finalNegativo2:
        return 'Você atravessará o portal, $_nomeJogador, mas ainda não pertence a este lugar. A jornada continua...';
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
      debugPrint('[MundoAna] Erro ao buscar personagem: $e');
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

  Future<void> _irParaEtapa(_Etapa proxima) async {
    await _executarShake();
    if (!mounted) return;
    setState(() => _etapa = proxima);
    await _animarTexto(_textoAtual);
  }

  // ── Handlers de escolha ──────────────────────────────────────────────────

  Future<void> _escolhaChegada(bool aceitou) async {
    if (!aceitou) {
      // Recusa → permanece na mesma tela (re-anima o texto)
      await _animarTexto(_textoAtual);
      return;
    }
    setState(() => _pontosPositivos++);
    await _irParaEtapa(_Etapa.missao1);
  }

  Future<void> _escolhaCaminho(int caminho) async {
    // 1=A erro, 2=B erro, 3=C sucesso
    if (caminho == 3) {
      setState(() => _fragmentos++);
      await _irParaEtapa(_Etapa.desafio1Sucesso);
    } else {
      await _irParaEtapa(_Etapa.desafio1Erro);
    }
  }

  Future<void> _escolhaCriatura(int opcao) async {
    // 1=Atacar sem bonus, 2=Fugir sem bonus, 3=Observar sucesso+vantagem
    if (opcao == 3) {
      setState(() {
        _fragmentos++;
        _temVantagem = true;
        _pontosPositivos++;
      });
      await _irParaEtapa(_Etapa.desafio2Sucesso);
    } else {
      await _irParaEtapa(_Etapa.desafio2SemBonus);
    }
  }

  Future<void> _escolhaEnigma(int opcao) async {
    // 1=Passado erro, 2=Presente sucesso, 3=Futuro erro
    if (opcao == 2) {
      setState(() {
        _fragmentos++;
        _pontosPositivos++;
      });
      await _irParaEtapa(_Etapa.desafio3Sucesso);
    } else {
      await _irParaEtapa(_Etapa.desafio3Erro);
    }
  }

  Future<void> _escolhaFerido(bool ajudou) async {
    if (ajudou) {
      setState(() => _pontosPositivos++);
      await _irParaEtapa(_Etapa.desafio4Bonus);
    } else {
      await _irParaEtapa(_Etapa.desafio4SemBonus);
    }
  }

  Future<void> _avancarSimples() async {
    if (!_textoTerminou) return;

    switch (_etapa) {
      case _Etapa.chegada1:
        await _irParaEtapa(_Etapa.chegada2);
        break;
      case _Etapa.missao1:
        await _irParaEtapa(_Etapa.missao2);
        break;
      case _Etapa.missao2:
        await _irParaEtapa(_Etapa.desafio1);
        break;
      case _Etapa.desafio1Erro:
        await _irParaEtapa(_Etapa.desafio1);
        break;
      case _Etapa.desafio1Sucesso:
        await _irParaEtapa(_Etapa.desafio2);
        break;
      case _Etapa.desafio2SemBonus:
        await _irParaEtapa(_Etapa.desafio3);
        break;
      case _Etapa.desafio2Sucesso:
        await _irParaEtapa(_Etapa.desafio3);
        break;
      case _Etapa.desafio3Erro:
        await _irParaEtapa(_Etapa.desafio3);
        break;
      case _Etapa.desafio3Sucesso:
        await _irParaEtapa(_Etapa.desafio4);
        break;
      case _Etapa.desafio4Bonus:
      case _Etapa.desafio4SemBonus:
        await _irParaEtapa(_Etapa.reuniao1);
        break;
      case _Etapa.reuniao1:
        await _irParaEtapa(_Etapa.reuniao2);
        break;
      case _Etapa.reuniao2:
        // Final positivo se ≥2 pontos positivos
        if (_pontosPositivos >= 2) {
          await _irParaEtapa(_Etapa.finalPositivo1);
        } else {
          await _irParaEtapa(_Etapa.finalNegativo1);
        }
        break;
      case _Etapa.finalPositivo1:
        await _irParaEtapa(_Etapa.finalPositivo2);
        break;
      case _Etapa.finalNegativo1:
        await _irParaEtapa(_Etapa.finalNegativo2);
        break;
      case _Etapa.finalPositivo2:
      case _Etapa.finalNegativo2:
        if (mounted) Navigator.pop(context);
        break;
      default:
        break;
    }
  }

  // ── Helpers de UI ────────────────────────────────────────────────────────

  bool get _mostrarBotaoContinuar {
    const etapasComEscolha = {
      _Etapa.chegada2,
      _Etapa.desafio1,
      _Etapa.desafio2,
      _Etapa.desafio3,
      _Etapa.desafio4,
    };
    return !etapasComEscolha.contains(_etapa) && _etapa != _Etapa.carregando;
  }

  String get _labelBotao {
    switch (_etapa) {
      case _Etapa.finalPositivo2:
      case _Etapa.finalNegativo2:
        return 'Abrir portal 🌀';
      case _Etapa.missao2:
        return 'Iniciar desafios ⚔️';
      case _Etapa.reuniao2:
        return 'Continuar ✨';
      default:
        return 'Continuar →';
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          // HUD fragmentos
          if (_fragmentos > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Chip(
                backgroundColor: const Color(0xFF9E8A4A).withValues(alpha: 0.3),
                label: Text(
                  '💎 $_fragmentos/3',
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFF8E7B9),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                side: const BorderSide(color: Color(0xFF9E8A4A)),
              ),
            ),
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
              'assets/images/fundo_terrasen.png',
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
                  color: const Color(0xFFF8E7B9),
                ),
              ),
              const SizedBox(height: 16),

              // Botões de escolha ou botão continuar
              if (_textoTerminou) _buildAcoes(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAcoes() {
    switch (_etapa) {
      case _Etapa.chegada2:
        return _buildEscolhas([
          _OpcaoBtn(label: '1. Aceitar o desafio ⚔️', onTap: () => _escolhaChegada(true)),
          _OpcaoBtn(label: '2. Recusar', onTap: () => _escolhaChegada(false), secundario: true),
        ]);

      case _Etapa.desafio1:
        return _buildEscolhas([
          _OpcaoBtn(label: '🌿 Caminho A', onTap: () => _escolhaCaminho(1), secundario: true),
          _OpcaoBtn(label: '🌑 Caminho B', onTap: () => _escolhaCaminho(2), secundario: true),
          _OpcaoBtn(label: '✨ Caminho C', onTap: () => _escolhaCaminho(3)),
        ]);

      case _Etapa.desafio2:
        return _buildEscolhas([
          _OpcaoBtn(label: '⚔️ Atacar', onTap: () => _escolhaCriatura(1), secundario: true),
          _OpcaoBtn(label: '🏃 Fugir', onTap: () => _escolhaCriatura(2), secundario: true),
          _OpcaoBtn(label: '👁️ Observar', onTap: () => _escolhaCriatura(3)),
        ]);

      case _Etapa.desafio3:
        return _buildEscolhas([
          _OpcaoBtn(label: '1. Passado', onTap: () => _escolhaEnigma(1), secundario: true),
          _OpcaoBtn(label: '2. Presente', onTap: () => _escolhaEnigma(2)),
          _OpcaoBtn(label: '3. Futuro', onTap: () => _escolhaEnigma(3), secundario: true),
        ]);

      case _Etapa.desafio4:
        return _buildEscolhas([
          _OpcaoBtn(label: '💛 Ajudar', onTap: () => _escolhaFerido(true)),
          _OpcaoBtn(label: '→ Ignorar e avançar', onTap: () => _escolhaFerido(false), secundario: true),
        ]);

      default:
        if (_mostrarBotaoContinuar) {
          return Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _avancarSimples,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B3F1D),
                foregroundColor: const Color(0xFFF8E7B9),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF9E8A4A), width: 1.5),
                ),
              ),
              child: Text(
                _labelBotao,
                style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
    }
  }

  Widget _buildEscolhas(List<_OpcaoBtn> opcoes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: opcoes
          .map(
            (o) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ElevatedButton(
                onPressed: o.onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: o.secundario
                      ? Colors.transparent
                      : const Color(0xFF6B3F1D),
                  foregroundColor: const Color(0xFFF8E7B9),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: o.secundario
                          ? const Color(0xFF9E8A4A).withValues(alpha: 0.5)
                          : const Color(0xFF9E8A4A),
                      width: 1.5,
                    ),
                  ),
                  elevation: o.secundario ? 0 : 4,
                ),
                child: Text(
                  o.label,
                  style: GoogleFonts.cinzel(
                    fontWeight: o.secundario ? FontWeight.normal : FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBadgeFalante() {
    final String nome = 'Aelin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF6B3F1D).withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFF8E7B9).withValues(alpha: 0.3),
        ),
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

// Modelo simples para botões de escolha
class _OpcaoBtn {
  final String label;
  final VoidCallback onTap;
  final bool secundario;

  const _OpcaoBtn({
    required this.label,
    required this.onTap,
    this.secundario = false,
  });
}