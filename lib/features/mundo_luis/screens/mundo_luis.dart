import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rpg_game/features/mundo_final/screens/mundo_final_screen.dart';
import 'package:audioplayers/audioplayers.dart';

class MundoLuisScreen extends StatefulWidget {
  const MundoLuisScreen({super.key});

  @override
  State<MundoLuisScreen> createState() => _MundoLuisScreenState();
}

class _MundoLuisScreenState extends State<MundoLuisScreen> {
  late AudioPlayer _musicPlayer;
  bool _somAtivado = true;

  bool missaoAceita = false;
  bool achouLuneta = false;
  bool achouMapa = false;
  bool achouCerveja = false;
  bool falouComAraraComPistas = false;
  bool achouMoeda = false;
  String nomeJogador = 'viajante';
  String? _personagemId;

  String? imagemItemEncontrado;

  String falaAtual = 'Temos um invasor! Piratas, ataquem!';
  String textoVisivel = '';
  Timer? timerTexto;
  bool textoCompleto = false;

  List<String> opcoesAtuais = ['Continuar'];

  // ─── Mostrar NPC e diálogo (igual ao MundoMaria) ─────────────────────────
  bool _mostrarNpc = false;
  bool _mostrarDialogo = false;

  int get itensTotais => 3;
  int get itensEncontrados =>
      (achouLuneta ? 1 : 0) + (achouCerveja ? 1 : 0) + (achouMapa ? 1 : 0);

  @override
  void initState() {
    super.initState();
    _musicPlayer = AudioPlayer();
    _iniciarMusica();
    carregarNomeJogador();
  }

  @override
  void dispose() {
    timerTexto?.cancel();
    _pararMusica();
    _musicPlayer.dispose();
    super.dispose();
  }

  Future<void> _iniciarMusica() async {
    try {
      await _musicPlayer.setVolume(0.5);
      await _musicPlayer.play(AssetSource('audio/music/bar_pirata.mp3'));
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

  // ─── Popup: mundo bloqueado ───────────────────────────────────────────────
  Future<void> _mostrarPopupBloqueado() async {
    final size = MediaQuery.of(context).size;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: size.width * 0.06,
            vertical: size.height * 0.06,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 420,
              maxHeight: size.height * 0.80,
            ),
            child: Container(
              padding: EdgeInsets.all(size.width * 0.06),
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock,
                      size: (size.width * 0.16).clamp(48.0, 70.0),
                      color: const Color(0xFFF8E7B9),
                    ),
                    SizedBox(height: size.height * 0.025),
                    Text(
                      'Portal Bloqueado',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        color: const Color(0xFFF8E7B9),
                        fontSize: (size.width * 0.055).clamp(18.0, 26.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: size.height * 0.022),
                    Text(
                      'Você ainda não possui a chave necessária para acessar o Bar Pirata.\n\nConclua primeiro o mundo "Fazenda Vale Dourado" e obtenha sua chave antes de prosseguir.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        color: const Color(0xFFF8E7B9),
                        fontSize: (size.width * 0.036).clamp(13.0, 16.0),
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: size.height * 0.032),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B3F1D),
                        foregroundColor: const Color(0xFFF8E7B9),
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.07,
                          vertical: size.height * 0.016,
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
            ),
          ),
        );
      },
    );

    if (mounted) Navigator.of(context).pop();
  }

  // ─── Popup: conclusão (chave obtida) ─────────────────────────────────────
  Future<void> _mostrarPopupConclusao() async {
    final size = MediaQuery.of(context).size;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: size.width * 0.06,
            vertical: size.height * 0.06,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 420,
              maxHeight: size.height * 0.85,
            ),
            child: Container(
              padding: EdgeInsets.all(size.width * 0.06),
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/icons_bar/moeda_ouro.png',
                      height: (size.height * 0.18).clamp(100.0, 150.0),
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: size.height * 0.025),
                    Text(
                      'Chave do Bar Pirata Obtida',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        color: const Color(0xFFF8E7B9),
                        fontSize: (size.width * 0.055).clamp(18.0, 26.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: size.height * 0.022),
                    Text(
                      'Muito bem, $nomeJogador.\n\nVocê concluiu a jornada pelo Bar Pirata e encontrou a Moeda de Ouro.\n\nA chave deste mundo agora pertence a você.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        color: const Color(0xFFF8E7B9),
                        fontSize: (size.width * 0.036).clamp(13.0, 16.0),
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: size.height * 0.032),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _mostrarPopupEscolhaFinal();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B3F1D),
                        foregroundColor: const Color(0xFFF8E7B9),
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.07,
                          vertical: size.height * 0.016,
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
            ),
          ),
        );
      },
    );
  }

  Future<void> _mostrarPopupEscolhaFinal() async {
    final size = MediaQuery.of(context).size;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: size.width * 0.06,
            vertical: size.height * 0.06,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 420,
              maxHeight: size.height * 0.85,
            ),
            child: Container(
              padding: EdgeInsets.all(size.width * 0.06),
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'O Portal Está Aberto',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        color: const Color(0xFFF8E7B9),
                        fontSize: (size.width * 0.055).clamp(18.0, 26.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: size.height * 0.025),
                    Text(
                      'Sua jornada no Bar Pirata foi registrada.\n\nDeseja encerrar sua aventura agora ou continuar explorando os mundos?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        color: const Color(0xFFF8E7B9),
                        fontSize: (size.width * 0.036).clamp(13.0, 16.0),
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: size.height * 0.032),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _salvarProgressoBarPirata();
                          Navigator.of(context).pop();
                          Navigator.of(this.context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B3F1D),
                          foregroundColor: const Color(0xFFF8E7B9),
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.016,
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
                          '💾 Salvar e sair',
                          style: GoogleFonts.cinzel(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.015),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _salvarProgressoBarPirata();
                          Navigator.of(context).pop();
                          Navigator.push(
                            this.context,
                            MaterialPageRoute(
                              builder: (_) => const MundoFinalScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B3F1D),
                          foregroundColor: const Color(0xFFF8E7B9),
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.016,
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
                          '⚔️ Salvar e continuar',
                          style: GoogleFonts.cinzel(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Carregar nome + verificar bloqueio ───────────────────────────────────
  Future<void> carregarNomeJogador() async {
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
        debugPrint('[MundoLuis] Nenhum personagem encontrado');
        if (mounted) Navigator.pop(context);
        return;
      }

      _personagemId = docId;

      if (nome != null && nome.isNotEmpty && mounted) {
        setState(() => nomeJogador = nome!);
      }

      final doc = await FirebaseFirestore.instance
          .collection('personagens')
          .doc(docId)
          .get();

      if (!doc.exists) return;

      final data = doc.data()!;
      final fazenda = data['fazenda_vale_dourado'];
      bool concluiuAnterior = false;

      if (fazenda is List && fazenda.isNotEmpty) {
        concluiuAnterior = fazenda[0] == true;
      }

      if (!concluiuAnterior) {
        if (mounted) await _mostrarPopupBloqueado();
        return;
      }

      // Inicia a cena com animação igual ao MundoMaria
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() {
        _mostrarNpc = true;
        _mostrarDialogo = true;
      });
      mostrarTexto(falaAtual);
    } catch (e) {
      debugPrint('[MundoLuis] Erro: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void mostrarTexto(String texto) {
    timerTexto?.cancel();
    setState(() {
      textoVisivel = '';
      textoCompleto = false;
    });

    int index = 0;
    timerTexto = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (index < texto.length) {
        setState(() => textoVisivel += texto[index]);
        index++;
      } else {
        timer.cancel();
        setState(() => textoCompleto = true);
      }
    });
  }

  void acelerarTexto() {
    if (!textoCompleto) {
      timerTexto?.cancel();
      setState(() {
        textoVisivel = falaAtual;
        textoCompleto = true;
      });
    }
  }

  void atualizarFala(String novaFala) {
    falaAtual = novaFala;
    mostrarTexto(falaAtual);
  }

  List<String> opcoesDeBusca() {
    return [
      'Procurar perto da máquina de música',
      'Procurar atrás do balcão do bar',
      'Procurar no depósito de cerveja',
      'Procurar na gaiola da arara',
    ];
  }

  void escolherOpcao(String opcao) async {
    String? novaFala;
    List<String>? novasOpcoes;
    String? novaImagem;

    if (opcao == 'Continuar') {
      if (falaAtual == 'Temos um invasor! Piratas, ataquem!') {
        novaFala =
            'Calma, pessoal! A Margarida me enviou para procurar vocês. '
            'Meu nome é $nomeJogador, e ela pediu que eu falasse com Luis Gancho-fino...';
        novasOpcoes = ['Continuar'];
      } else if (falaAtual.contains('A Margarida me enviou')) {
        novaFala =
            'Luis Gancho-fino: Faz tempo que não ouço esse nome.. '
            'Ela ainda tá bem? Ou continua mandando todo mundo trabalhar?';
        novasOpcoes = ['Continuar'];
      } else if (falaAtual.contains('Faz tempo que não ouço esse nome')) {
        novaFala =
            '$nomeJogador: Tá ótima! Doce, gentil… e mandona do jeitinho dela. '
            'Inclusive, me mandou ajudar vocês a encontrar uma tal moeda de ouro perdida.';
        novasOpcoes = ['Continuar'];
      } else {
        novaFala =
            'Luis Gancho-fino: Ahhh, Margarida… ajudando até de longe! '
            'Daqui a pouco ela aparece aqui mandando a gente arrumar o bar também…';
        novasOpcoes = ['Aceitar a busca', 'Hesitar'];
      }
    } else if (opcao == 'Aceitar a busca' || opcao == 'Hesitar') {
      final falaInicio = opcao == 'Hesitar'
          ? 'Luis Gancho-fino: Hesitar? Aqui não temos tempo pra isso, marujo! '
          : 'Luis Gancho-fino: Que bom! Sabia que podia contar com você!\n\n';

      novaFala =
          '${falaInicio}A moeda de ouro dos piratas foi perdida! '
          'Para avançar, você precisa encontrá-la.';
      novasOpcoes = ['Iniciar busca'];
    } else if (opcao == 'Iniciar busca') {
      novaFala = 'Luis Gancho-fino: Onde deseja começar a procurar?';
      novasOpcoes = opcoesDeBusca();
    } else if (opcao == 'Procurar perto da máquina de música') {
      novaImagem = 'assets/images/icons_bar/luneta.png';
      novaFala =
          'Você encontrou uma luneta!\n\n'
          'Luis Gancho-fino: Minha luneta! '
          'Sem ela eu tava mirando até em barril achando que era inimigo!';
      novasOpcoes = opcoesDeBusca();
    } else if (opcao == 'Procurar atrás do balcão do bar') {
      novaImagem = 'assets/images/icons_bar/cerveja.png';
      novaFala =
          'Você encontrou uma cerveja!\n\n'
          'Luis Gancho-fino: Você sabe mesmo como agradar um pirata… '
          'mas ainda falta minha moeda!';
      novasOpcoes = opcoesDeBusca();
    } else if (opcao == 'Procurar no depósito de cerveja') {
      if (falouComAraraComPistas && achouMapa && achouLuneta) {
        novaImagem = 'assets/images/icons_bar/moeda_ouro.png';
        novaFala =
            'Você encontrou a moeda de ouro perdida!\n\n'
            'Luis Gancho-fino: Finalmente alguém encontrou a moeda! '
            'Hoje a bebida é por minha conta!\n\n'
            'Em forma de agradecimento, leve esta moeda. '
            'Tenha certeza que será útil em suas próximas buscas!';
        novasOpcoes = ['Receber recompensa'];
      } else {
        novaImagem = 'assets/images/icons_bar/mapa.png';
        novaFala =
            'Você encontrou um mapa do tesouro!\n\n'
            'Luis Gancho-fino: Pelas barbas do capitão! '
            'Esse mapa pode nos ajudar…';
        novasOpcoes = opcoesDeBusca();
      }
    } else if (opcao == 'Procurar na gaiola da arara') {
      if (!achouMapa && !achouLuneta) {
        novaFala = 'Arara: Muito escuro… não dá pra ver nada…';
        novasOpcoes = opcoesDeBusca();
      } else if (achouLuneta && !achouMapa) {
        novaFala = 'Arara: Ver é bom… mas sem direção você se perde!';
        novasOpcoes = opcoesDeBusca();
      } else if (achouMapa && !achouLuneta) {
        novaFala = 'Arara: Saber o caminho não basta… precisa enxergar!';
        novasOpcoes = opcoesDeBusca();
      } else {
        novaFala =
            'Arara: Brilha no escuro… no meio dos barris!\n\n'
            'Luis Gancho-fino: Com essa pista, o depósito parece ser o lugar certo…';
        novasOpcoes = ['Procurar no depósito de cerveja'];
      }
    } else if (opcao == 'Receber recompensa') {
      novaImagem = 'assets/images/icons_bar/moeda_ouro.png';
      novaFala =
          'Um verdadeiro pirata não é medido pelo ouro que carrega, '
          'mas pelas escolhas que faz em meio ao caos.\n\n'
          'Hoje, você provou seu valor neste bar.\n\n'
          'Missão concluída!';
      novasOpcoes = [];

      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 1800), () async {
          if (mounted) await _mostrarPopupConclusao();
        });
      }
    }

    setState(() {
      imagemItemEncontrado = novaImagem;

      if (opcao == 'Procurar perto da máquina de música') {
        achouLuneta = true;
      } else if (opcao == 'Procurar atrás do balcão do bar') {
        achouCerveja = true;
      } else if (opcao == 'Procurar no depósito de cerveja') {
        if (falouComAraraComPistas && achouMapa && achouLuneta) {
          achouMoeda = true;
        } else {
          achouMapa = true;
        }
      } else if (opcao == 'Procurar na gaiola da arara') {
        if (achouMapa && achouLuneta) {
          falouComAraraComPistas = true;
        }
      } else if (opcao == 'Aceitar a busca' || opcao == 'Hesitar') {
        missaoAceita = true;
      }

      if (novasOpcoes != null) {
        opcoesAtuais = novasOpcoes;
      }
    });

    if (novaFala != null) {
      atualizarFala(novaFala);
    }
  }

  Future<void> _salvarProgressoBarPirata() async {
    if (_personagemId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('personagens')
          .doc(_personagemId)
          .update({
            'bar_pirata': [true, Timestamp.now(), '[22.83347° S, 47.04992° W]'],
          });
    } catch (e) {
      debugPrint('Erro ao salvar progresso: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Mesmo tamanho de NPC que o MundoMaria
    final npcSize = (size.width * 0.50).clamp(140.0, 240.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bar Pirata',
          style: GoogleFonts.cinzel(
            color: const Color(0xFFF8E7B9),
            fontWeight: FontWeight.bold,
            fontSize: (size.width * 0.045).clamp(15.0, 20.0),
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
          // Background
          SizedBox.expand(
            child: Image.asset(
              'assets/images/bar_pirata.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF0D0A1A)),
            ),
          ),

          // Overlay escuro — mesmo alpha do MundoMaria
          Container(color: Colors.black.withValues(alpha: 0.50)),

          // ── NPC Luis — posicionamento idêntico ao MundoMaria ────────────
          Positioned(
            bottom: size.height * 0.24,
            left: size.width * 0.03,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              offset: _mostrarNpc ? Offset.zero : const Offset(-0.3, 0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 700),
                opacity: _mostrarNpc ? 1 : 0,
                child: Image.asset(
                  'assets/images/personagem_luis.png',
                  width: npcSize,
                  height: npcSize,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    width: npcSize,
                    height: npcSize,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6B3F1D),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: npcSize * 0.4,
                      color: const Color(0xFFF8E7B9),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Barra de progresso (canto superior direito, compacta) ────────
          Positioned(
            top: size.height * 0.01,
            right: size.width * 0.04,
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.03,
                  vertical: size.height * 0.008,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF9E8A4A),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Itens encontrados',
                      style: GoogleFonts.cinzel(
                        fontSize: (size.width * 0.025).clamp(10.0, 13.0),
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: size.height * 0.004),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$itensEncontrados',
                          style: GoogleFonts.cinzel(
                            fontSize: (size.width * 0.045).clamp(16.0, 22.0),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFF8E7B9),
                          ),
                        ),
                        Text(
                          ' / $itensTotais',
                          style: GoogleFonts.cinzel(
                            fontSize: (size.width * 0.033).clamp(12.0, 15.0),
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.004),
                    SizedBox(
                      width: size.width * 0.22,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: itensEncontrados / itensTotais,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFF8E7B9),
                          ),
                          minHeight: 5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Imagem do item encontrado (centralizada) ─────────────────────
          if (imagemItemEncontrado != null)
            Center(
              child: Container(
                padding: EdgeInsets.all(size.width * 0.045),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.80),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF9E8A4A), width: 2),
                ),
                child: Image.asset(
                  imagemItemEncontrado!,
                  height: (size.height * 0.14).clamp(80.0, 130.0),
                  fit: BoxFit.contain,
                ),
              ),
            ),

          // ── Caixa de diálogo — estrutura idêntica ao MundoMaria ──────────
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
              child: Column(
                children: [
                  const Spacer(),
                  _buildCaixaDialogo(size),
                  SizedBox(height: size.height * 0.03),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Caixa de diálogo (espelho do MundoMaria) ─────────────────────────────
  Widget _buildCaixaDialogo(Size size) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      offset: _mostrarDialogo ? Offset.zero : const Offset(0, 0.3),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 700),
        opacity: _mostrarDialogo ? 1 : 0,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(size.width * 0.045),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBadgeFalante(size),
              SizedBox(height: size.height * 0.01),
              Text(
                textoVisivel,
                style: GoogleFonts.cinzel(
                  fontSize: (size.width * 0.037).clamp(13.0, 16.0),
                  height: 1.65,
                  color: const Color(0xFFF8E7B9),
                ),
              ),
              SizedBox(height: size.height * 0.018),

              // Botão "Pular" enquanto o texto ainda está sendo escrito
              if (!textoCompleto)
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: acelerarTexto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9E8A4A),
                      foregroundColor: const Color(0xFFF8E7B9),
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.06,
                        vertical: size.height * 0.014,
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
                      'Continuar →',
                      style: GoogleFonts.cinzel(
                        fontWeight: FontWeight.bold,
                        fontSize: (size.width * 0.035).clamp(12.0, 15.0),
                      ),
                    ),
                  ),
                ),

              // Opções após texto completo
              if (textoCompleto) ...[
                ...opcoesAtuais.map((opcao) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: size.height * 0.012),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => escolherOpcao(opcao),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B3F1D),
                          foregroundColor: const Color(0xFFF8E7B9),
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.06,
                            vertical: size.height * 0.014,
                          ),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Color(0xFF9E8A4A),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Text(
                          opcao,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cinzel(
                            fontSize: (size.width * 0.033).clamp(12.0, 14.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── Badge do falante (espelho do MundoMaria) ─────────────────────────────
  Widget _buildBadgeFalante(Size size) {
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
        'Luis Gancho-fino',
        style: GoogleFonts.cinzel(
          fontSize: (size.width * 0.025).clamp(10.0, 13.0),
          fontWeight: FontWeight.bold,
          color: const Color(0xFFF8E7B9).withValues(alpha: 0.65),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
