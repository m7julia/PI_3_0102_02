import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rpg_game/features/mundo_ana/screens/mundo_ana_screen.dart';
import 'package:rpg_game/features/mundo_maria/games/jogo_memoria_game.dart';
import 'package:rpg_game/features/mundo_maria/games/ligue_3_game.dart';
import 'package:rpg_game/services/nivel_service.dart';

enum _Etapa {
  carregando,
  bloqueado,
  chegada1,
  chegada2,
  chegada3,
  jogadorFala,
  reacao1,
  reacao2,
  reacao3,
  perguntaCaminho1,
  perguntaCaminho2,
  perguntaCaminho3,
  escolha,
  introMemoria1,
  introMemoria2,
  introMemoria3,
  introMemoria4,
  introMemoria5,
  introLigue31,
  introLigue32,
  introLigue33,
  introLigue34,
  introLigue35,
}

class MundoMariaScreen extends StatefulWidget {
  const MundoMariaScreen({super.key});

  @override
  State<MundoMariaScreen> createState() => _MundoMariaScreenState();
}

class _MundoMariaScreenState extends State<MundoMariaScreen>
    with TickerProviderStateMixin {
  _Etapa _etapa = _Etapa.carregando;
  String _nomeJogador = 'Viajante';
  String? _personagemId;
  String _textoExibido = '';
  bool _textoTerminou = false;
  bool _mostrarNpc = false;
  bool _mostrarDialogo = false;
  bool _pularAnimacao = false;

  bool _somAtivado = true;
  late AudioPlayer _musicPlayer;

  late AnimationController _npcAnimCtrl;
  late AnimationController _dialogoAnimCtrl;
  late AnimationController _shakeCtrl;
  late AnimationController _opcaoAnimCtrl;

  late Animation<double> _npcScale;
  late Animation<double> _npcRotate;
  late Animation<double> _shakeAnim;
  late Animation<double> _opcaoScale;

  // ─── Popup: Fase bloqueada ────────────────────────────────────────────────

  Future<void> _mostrarPopupBloqueado() async {
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
                const Icon(Icons.lock, size: 70, color: Color(0xFFF8E7B9)),
                const SizedBox(height: 20),
                Text(
                  'Portal Bloqueado',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFF8E7B9),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Você ainda não possui a chave necessária para acessar a Fazenda Vale-Dourado.\n\nConclua primeiro o mundo anterior e obtenha sua chave antes de prosseguir.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFF8E7B9),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B3F1D),
                    foregroundColor: const Color(0xFFF8E7B9),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(
                        color: Color(0xFF9E8A4A),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Text(
                    'Voltar',
                    style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Volta para a tela anterior após fechar o popup
    if (mounted) Navigator.of(context).pop();
  }

  // ─── Popup: Conclusão / Chave obtida ─────────────────────────────────────

  Future<void> _mostrarPopupConclusao() async {
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
                Image.asset(
                  'assets/images/chave_amuleto.png',
                  height: 150,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.vpn_key_rounded,
                    size: 80,
                    color: Color(0xFFF8E7B9),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Chave da Fazenda Obtida',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFF8E7B9),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Muito bem, $_nomeJogador.\n\nVocê concluiu a jornada pela Fazenda Vale-Dourado e ajudou Margarida com a colheita.\n\nA chave deste mundo agora pertence a você.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFF8E7B9),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _mostrarPopupEscolhaFinal();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B3F1D),
                    foregroundColor: const Color(0xFFF8E7B9),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(
                        color: Color(0xFF9E8A4A),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Text(
                    'Abrir portal 🌀',
                    style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Popup: Escolha final (sair ou continuar) ─────────────────────────────

  Future<void> _mostrarPopupEscolhaFinal() async {
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
                  'O Portal Está Aberto',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFF8E7B9),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Sua jornada pela Fazenda Vale-Dourado foi registrada.\n\nDeseja encerrar sua aventura agora ou continuar explorando os mundos?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFF8E7B9),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 28),
                // Salvar e sair
                Center(
                  child: SizedBox(
                    width: 260,
                    child: ElevatedButton(
                      onPressed: () async {
                        await NivelService.completarNivelMaju();
                        Navigator.of(context).pop();
                        Navigator.of(this.context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B3F1D),
                        foregroundColor: const Color(0xFFF8E7B9),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(
                            color: Color(0xFF9E8A4A),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Text(
                        '💾 Salvar e sair',
                        style: GoogleFonts.cinzel(
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Salvar e continuar para o próximo mundo
                Center(
                  child: SizedBox(
                    width: 260,
                    child: ElevatedButton(
                      onPressed: () async {
                        await NivelService.completarNivelMaju();
                        Navigator.of(context).pop();
                        Navigator.push(
                          this.context,
                          MaterialPageRoute(
                            builder: (_) => const MundoAnaScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B3F1D),
                        foregroundColor: const Color(0xFFF8E7B9),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(
                            color: Color(0xFF9E8A4A),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Text(
                        '⚔️ Salvar e continuar',
                        style: GoogleFonts.cinzel(
                            fontWeight: FontWeight.bold),
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

  // ─── Textos das etapas ────────────────────────────────────────────────────

  String get _textoAtual {
    switch (_etapa) {
      case _Etapa.carregando:
      case _Etapa.bloqueado:
        return '';
      case _Etapa.chegada1:
        return 'Bem-vindo à minha fazenda, $_nomeJogador!';
      case _Etapa.chegada2:
        return 'Sou Margarida, cuidadora da Fazenda Vale-Dourado.';
      case _Etapa.chegada3:
        return 'Diga-me... o que te trouxe até aqui?';
      case _Etapa.jogadorFala:
        return 'Sou $_nomeJogador! Completei as notas de Beethoven e ganhei a chave do portal para chegar até você.';
      case _Etapa.reacao1:
        return 'Que maravilha, $_nomeJogador!';
      case _Etapa.reacao2:
        return 'As melodias de Beethoven escolheram bem seu mensageiro.';
      case _Etapa.reacao3:
        return 'Que bom que chegou — já tenho a missão perfeita para ti!';
      case _Etapa.perguntaCaminho1:
        return 'Mas antes de te enviar ao campo...';
      case _Etapa.perguntaCaminho2:
        return 'preciso saber que tipo de aventureiro você é.';
      case _Etapa.perguntaCaminho3:
        return 'Você prefere o caminho curto e difícil, ou o caminho longo e mais fácil?';
      case _Etapa.escolha:
        return 'Escolha seu caminho, $_nomeJogador...';
      case _Etapa.introMemoria1:
        return 'Para guardar a colheita de hoje, precisamos separar tudo em pares antes de levar ao celeiro.';
      case _Etapa.introMemoria2:
        return 'Cada item tem seu par — nada entra desemparelhado!';
      case _Etapa.introMemoria3:
        return 'Vire as cartas e encontre os quatro pares da colheita.';
      case _Etapa.introMemoria4:
        return 'Mas fique atento: em algum lugar está a minha ferradura da sorte.';
      case _Etapa.introMemoria5:
        return 'Se a encontrar, me avise!';
      case _Etapa.introLigue31:
        return 'Os vegetais aqui crescem em grupos e só são colhidos de três em três.';
      case _Etapa.introLigue32:
        return 'Para colher, ligue três do mesmo vegetal — eles saem da terra juntos!';
      case _Etapa.introLigue33:
        return 'Sua missão é coletar 6 unidades de cada vegetal:';
      case _Etapa.introLigue34:
        return '🌻 girassol, 🌽 milho, 🌾 trigo e 🎃 abóbora.';
      case _Etapa.introLigue35:
        return 'Quando completar tudo, venha me avisar!';
    }
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _configurarAnimacoes();
    _musicPlayer = AudioPlayer();
    _iniciarMusica();
    _buscarPersonagemEIniciar();
  }

  Future<void> _iniciarMusica() async {
    try {
      await _musicPlayer.setVolume(0.5);
      await _musicPlayer.play(AssetSource('audio/music/audio_fazenda_vale_dourado.mp3'));
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      debugPrint('Erro ao iniciar música: $e');
    }
  }

  Future<void> _pararMusica() async {
    try {
      await _musicPlayer.stop();
    } catch (e) {
      debugPrint('Erro ao parar música: $e');
    }
  }

  Future<void> _toggleSom() async {
    if (_somAtivado) {
      await _musicPlayer.pause();
      setState(() => _somAtivado = false);
    } else {
      await _musicPlayer.resume();
      setState(() => _somAtivado = true);
    }
  }

  @override
  void dispose() {
    _npcAnimCtrl.dispose();
    _dialogoAnimCtrl.dispose();
    _shakeCtrl.dispose();
    _opcaoAnimCtrl.dispose();
    _musicPlayer.dispose();
    super.dispose();
  }

  // ─── Animações ────────────────────────────────────────────────────────────

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

  // ─── Busca personagem + verifica bloqueio ─────────────────────────────────

  Future<void> _buscarPersonagemEIniciar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final personagemId = prefs.getString('personagemAtualId');

      String? nome;
      String? docId;

      if (personagemId != null) {
        final doc = await FirebaseFirestore.instance
            .collection('personagens')
            .doc(personagemId)
            .get();

        if (doc.exists) {
          docId = doc.id;
          nome = doc.data()?['nome'] as String?;
        }
      }

      // Fallback: personagem mais recente
      if (docId == null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('personagens')
            .orderBy('criadoEm', descending: true)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          docId = snapshot.docs.first.id;
          nome = snapshot.docs.first.data()['nome'] as String?;
        }
      }

      if (docId == null) {
        debugPrint('[MundoMaria] Nenhum personagem encontrado');
        if (mounted) Navigator.pop(context);
        return;
      }

      _personagemId = docId;

      if (nome != null && nome.isNotEmpty && mounted) {
        setState(() => _nomeJogador = nome!);
      }

      // Verifica se o Conservatório Diminuto (mundo anterior) foi concluído
      final doc = await FirebaseFirestore.instance
          .collection('personagens')
          .doc(docId)
          .get();

      if (!doc.exists) return;

      final data = doc.data()!;
      final mundoAnterior = data['conservatorio_diminuto'];
      bool concluiuAnterior = false;

      if (mundoAnterior is List && mundoAnterior.isNotEmpty) {
        concluiuAnterior = mundoAnterior[0] == true;
      }

      if (!concluiuAnterior) {
        if (mounted) await _mostrarPopupBloqueado();
        return;
      }

      await _iniciarCena();
    } catch (e) {
      debugPrint('[MundoMaria] Erro: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ─── Inicia a cena de diálogo ─────────────────────────────────────────────

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

  // ─── Texto animado (sem som) ─────────────────────────────────────────────

  void _pularTexto() {
    if (!_textoTerminou) {
      setState(() => _pularAnimacao = true);
    }
  }

  Future<void> _animarTexto(String texto) async {
    setState(() {
      _textoExibido = '';
      _textoTerminou = false;
      _pularAnimacao = false;
    });

    for (int i = 0; i < texto.length; i++) {
      if (_pularAnimacao) {
        setState(() {
          _textoExibido = texto;
          _textoTerminou = true;
        });
        break;
      }

      await Future.delayed(const Duration(milliseconds: 30));
      if (!mounted) return;
      setState(() => _textoExibido += texto[i]);
    }

    if (!mounted) return;
    if (!_pularAnimacao) {
      setState(() => _textoTerminou = true);
    }
  }

  // ─── Navegação de diálogo ─────────────────────────────────────────────────

  Future<void> _executarShake() async {
    _shakeCtrl.reset();
    await _shakeCtrl.forward();
  }

  Future<void> _avancarDialogo() async {
    if (!_textoTerminou) {
      _pularTexto();
      return;
    }

    await _executarShake();

    const sequencia = {
      _Etapa.chegada1: _Etapa.chegada2,
      _Etapa.chegada2: _Etapa.chegada3,
      _Etapa.chegada3: _Etapa.jogadorFala,
      _Etapa.jogadorFala: _Etapa.reacao1,
      _Etapa.reacao1: _Etapa.reacao2,
      _Etapa.reacao2: _Etapa.reacao3,
      _Etapa.reacao3: _Etapa.perguntaCaminho1,
      _Etapa.perguntaCaminho1: _Etapa.perguntaCaminho2,
      _Etapa.perguntaCaminho2: _Etapa.perguntaCaminho3,
      _Etapa.introMemoria1: _Etapa.introMemoria2,
      _Etapa.introMemoria2: _Etapa.introMemoria3,
      _Etapa.introMemoria3: _Etapa.introMemoria4,
      _Etapa.introMemoria4: _Etapa.introMemoria5,
      _Etapa.introLigue31: _Etapa.introLigue32,
      _Etapa.introLigue32: _Etapa.introLigue33,
      _Etapa.introLigue33: _Etapa.introLigue34,
      _Etapa.introLigue34: _Etapa.introLigue35,
    };

    if (_etapa == _Etapa.introMemoria5) {
      _irParaJogo(memoria: true);
      return;
    }
    if (_etapa == _Etapa.introLigue35) {
      _irParaJogo(memoria: false);
      return;
    }

    if (_etapa == _Etapa.perguntaCaminho3) {
      setState(() => _etapa = _Etapa.escolha);
      await _animarTexto(_textoAtual);
      _opcaoAnimCtrl.forward();
      return;
    }

    final proxima = sequencia[_etapa];
    if (proxima != null) {
      setState(() => _etapa = proxima);
      await _animarTexto(_textoAtual);
    }
  }

  Future<void> _escolherCaminhoMemoria() async {
    _opcaoAnimCtrl.reset();
    await _executarShake();
    setState(() => _etapa = _Etapa.introMemoria1);
    await _animarTexto(_textoAtual);
  }

  Future<void> _escolherCaminhoLigue3() async {
    _opcaoAnimCtrl.reset();
    await _executarShake();
    setState(() => _etapa = _Etapa.introLigue31);
    await _animarTexto(_textoAtual);
  }

  // ─── Navegação para minigame ──────────────────────────────────────────────

  void _irParaJogo({required bool memoria}) {
    _pararMusica();
    Navigator.push<bool>(
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
    ).then((venceu) {
      _iniciarMusica();
      if (mounted && venceu == true) {
        _mostrarPopupConclusao();
      }
    });
  }

  // ─── Helpers de UI ────────────────────────────────────────────────────────

  bool get _mostrarBotaoContinuar =>
      _etapa != _Etapa.escolha &&
      _etapa != _Etapa.carregando &&
      _etapa != _Etapa.bloqueado;

  String get _labelBotao {
    if (!_textoTerminou) return 'Pular ⚡';
    if (_etapa == _Etapa.introMemoria5 || _etapa == _Etapa.introLigue35) {
      return 'Vamos lá! ✨';
    }
    return 'Continuar →';
  }

  bool get _ehFalaJogador => _etapa == _Etapa.jogadorFala;

  // ─── Build ────────────────────────────────────────────────────────────────

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
          onPressed: () {
            _pararMusica();
            Navigator.pop(context);
          },
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
              'assets/images/fundo_fazenda.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF2D1A0A)),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.50)),
          Positioned(
            bottom: 200,
            left: 20,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              offset: _mostrarNpc ? Offset.zero : const Offset(-0.3, 0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 700),
                opacity: _mostrarNpc ? 1 : 0,
                child: Image.asset(
                  'assets/images/personagem_margarida.png',
                  width: 220,
                  height: 220,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    width: 220,
                    height: 220,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6B3F1D),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 80,
                      color: Color(0xFFF8E7B9),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_etapa == _Etapa.carregando)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFF8E7B9)),
            ),
          if (_etapa != _Etapa.carregando && _etapa != _Etapa.bloqueado)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const Spacer(),
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

  // ─── Widgets ──────────────────────────────────────────────────────────────

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
            color: Colors.black.withValues(alpha: 0.85),
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
              if (_etapa == _Etapa.escolha && _textoTerminou)
                ScaleTransition(
                  scale: _opcaoScale,
                  child: _buildOpcoesCaminho(),
                ),
              if (_mostrarBotaoContinuar)
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed:
                        _textoTerminou ? _avancarDialogo : _pularTexto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _textoTerminou
                          ? const Color(0xFF6B3F1D)
                          : const Color(0xFF9E8A4A),
                      foregroundColor: const Color(0xFFF8E7B9),
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
    final String nome = isJogador ? _nomeJogador : 'Margarida';
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: cor.withValues(alpha: 0.5), width: 1.5),
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