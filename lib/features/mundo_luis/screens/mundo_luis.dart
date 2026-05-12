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

  // POPUP: mundo bloqueado
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
                  'Você ainda não possui a chave necessária para acessar o Bar Pirata.\n\n'
                  'Conclua primeiro o mundo "Fazenda Vale Dourado" e obtenha sua chave antes de prosseguir.',
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

    // Após fechar o popup, volta para a tela anterior
    if (mounted) Navigator.of(context).pop();
  }

  // POPUP: conclusão (chave obtida)
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
                  'assets/images/icons_bar/moeda_ouro.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Text(
                  'Chave do Bar Pirata Obtida',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFF8E7B9),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Muito bem, $nomeJogador.\n\n'
                  'Você concluiu a jornada pelo Bar Pirata e encontrou a Moeda de Ouro.\n\n'
                  'A chave deste mundo agora pertence a você.',
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
                    'Abrir portal',
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

  // POPUP: escolha final (salvar e sair / continuar)
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
                  'Sua jornada no Bar Pirata foi registrada.\n\n'
                  'Deseja encerrar sua aventura agora ou continuar explorando os mundos?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFF8E7B9),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 28),

                // Botão: salvar e sair
                Center(
                  child: SizedBox(
                    width: 260,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _salvarProgressoBarPirata();
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
                        style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Botão: salvar e continuar para o mundo final
                Center(
                  child: SizedBox(
                    width: 260,
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
                        style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
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

  // FIRESTORE — salva progresso do Bar Pirata
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

  // Carrega o personagem salvo
  Future<void> carregarNomeJogador() async {
    try {
      // 1. Tenta pegar o id salvo no SharedPreferences
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

      // 2. Fallback: busca o último personagem criado
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

      // 3. Verifica se concluiu a Fazenda Vale Dourado
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

      // 4. Tudo certo — inicia a cena normalmente
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
    textoVisivel = '';
    textoCompleto = false;

    int index = 0;

    timerTexto = Timer.periodic(const Duration(milliseconds: 35), (timer) {
      if (index < texto.length) {
        setState(() {
          textoVisivel += texto[index];
        });
        index++;
      } else {
        timer.cancel();
        setState(() {
          textoCompleto = true;
        });
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

      // Aguarda o texto ser exibido antes de mostrar o popup
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
        opcoesAtuais = novasOpcoes!;
      }
    });

    if (novaFala != null) {
      atualizarFala(novaFala!);
    }
  }

  Widget _buildBarraProgresso() {
    return Positioned(
      top: 50,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFF8E7B9), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Itens encontrados',
              style: GoogleFonts.cinzel(
                fontSize: 11,
                color: Colors.white70,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$itensEncontrados',
                  style: GoogleFonts.cinzel(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF8E7B9),
                  ),
                ),
                Text(
                  ' / $itensTotais',
                  style: GoogleFonts.cinzel(
                    fontSize: 16,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: itensEncontrados / itensTotais,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFF8E7B9),
                  ),
                  minHeight: 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/bar_pirata.png',
              fit: BoxFit.cover,
            ),
          ),

          Container(color: Colors.black.withValues(alpha: 0.6)),

          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 20),
              child: Image.asset(
                'assets/images/personagem_luis.png',
                height: 320,
                fit: BoxFit.contain,
              ),
            ),
          ),

          Positioned(
            top: 50,
            left: 16,
            child: SafeArea(
              child: IconButton(
                onPressed: _toggleSom,
                icon: Icon(
                  _somAtivado ? Icons.volume_up : Icons.volume_off,
                  color: const Color(0xFFF8E7B9),
                  size: 28,
                ),
              ),
            ),
          ),

          Positioned(
            top: 70,
            left: 24,
            right: 130,
            child: Column(
              children: [
                Text(
                  'Bar Pirata',
                  style: GoogleFonts.cinzel(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF8E7B9),
                    letterSpacing: 2,
                    shadows: const [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 10,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'A moeda de ouro perdida',
                  style: GoogleFonts.cinzel(
                    fontSize: 20,
                    color: Colors.white70,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          _buildBarraProgresso(),

          if (imagemItemEncontrado != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.80),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF8E7B9), width: 2),
                ),
                child: Image.asset(
                  imagemItemEncontrado!,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
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
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF8E7B9).withValues(alpha: 0.65),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    textoVisivel,
                    style: GoogleFonts.cinzel(
                      fontSize: 15,
                      height: 1.65,
                      color: const Color(0xFFF8E7B9),
                    ),
                    textAlign: TextAlign.left,
                  ),

                  const SizedBox(height: 18),

                  if (!textoCompleto)
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: acelerarTexto,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B3F1D),
                          foregroundColor: const Color(0xFFF8E7B9),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
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
                          'Continuar →',
                          style: GoogleFonts.cinzel(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  if (textoCompleto) ...[
                    const SizedBox(height: 8),
                    ...opcoesAtuais.map((opcao) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => escolherOpcao(opcao),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B3F1D),
                              foregroundColor: const Color(0xFFF8E7B9),
                              padding: const EdgeInsets.symmetric(vertical: 14),
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
                                fontSize: 13,
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
        ],
      ),
    );
  }
}
