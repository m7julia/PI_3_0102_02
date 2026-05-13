import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rpg_game/features/mundo_maria/screens/mundo_maria.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

// ================= ENUMS E CLASSES AUXILIARES =================
enum _Etapa {
  carregando, bloqueado, chegada1, chegada2, dialogo1, dialogo2, dialogo3, 
  espera, positivo, dialogo5, desafio1, reuniao1, reuniao2, finalHist
}

// A CLASSE _OpcaoBtn AGORA ESTÁ NO LUGAR CERTO (FORA DO ESTADO)
class _OpcaoBtn {
  final String label;
  final VoidCallback onTap;
  final bool secundario;
  const _OpcaoBtn({required this.label, required this.onTap, this.secundario = false});
}

// ================= TELA PRINCIPAL =================
class MundoGianlucaScreen extends StatefulWidget {
  const MundoGianlucaScreen({super.key});

  @override
  State<MundoGianlucaScreen> createState() => _MundoGianlucaScreenState();
}

class _MundoGianlucaScreenState extends State<MundoGianlucaScreen> with TickerProviderStateMixin {
  // ================= ESTADO E VARIÁVEIS =================
  _Etapa _etapa = _Etapa.carregando;
  String _nomeJogador = 'Viajante';
  String? _personagemId;
  String _textoExibido = '';
  bool _textoTerminou = false;
  bool _mostrarNpc = false;
  bool _mostrarDialogo = false;
  bool _somAtivado = true;
  bool _audioLiberado = false;
  bool _tocandoSomLetra = false;

  late AudioPlayer _audioPlayer;
  int _fragmentos = 0;

  Timer? _timerTexto;

  // Animações
  late AnimationController _npcAnimCtrl;
  late AnimationController _dialogoAnimCtrl;
  late Animation<double> _npcScale;
  late Animation<double> _npcRotate;

  // ================= TEXTOS DA HISTÓRIA =================
  String get _textoAtual {
    switch (_etapa) {
      case _Etapa.carregando: return 'Processando frequências harmônicas...';
      case _Etapa.bloqueado: return 'Acesso restrito ao Conservatório.';
      case _Etapa.chegada1: return 'Oh, olá vi"AU"jante, quem é você e o que lhe trás até meu conservatório?';
      case _Etapa.chegada2: return 'Humm, interessante... Terrasen é realmente um lugar de tir"AU"r o fôlego, mas o que lhe trás especificamente até a mim $_nomeJogador?';
      case _Etapa.dialogo1: return 'Ahhh, uma ajuda?! Bom então vamos fazer uma troca, eu te ajudo a ir para o próximo mundo e em troca você me faz um leve f"AU"vorzinho...';
      case _Etapa.dialogo2: return 'Ao tentar tocar o lendário acorde de EM7(9,13)/G#°m4add fui enfeitiç"AU"do pelo elfo da música. Ele me chamou de indisciplin"AU"do!';
      case _Etapa.dialogo3: return 'E me transformou em um cachorro! Para recuperar minha forma humana, preciso ensinar a harmonia natural para alguém. "AU"ceita ser meu aluno?';
      case _Etapa.espera: return 'Bom, nesse caso vamos esperar... Estarei aqui praticando minhas escalas. Me avise se mudar de ideia.';
      case _Etapa.positivo: return 'AU-migo! Fico feliz que decidiu me "AU"xiliar, vamos nessa!';
      case _Etapa.dialogo5: return 'A primeira lição é sentir o ritmo do coração de Terrasen...';
      case _Etapa.desafio1: return 'Qual destas notas deve iniciar a nossa sinfonia de restauração?';
      case _Etapa.reuniao1: return 'Incrível! Os fragmentos musicais ressoam perfeitamente. A partitura está completa.';
      case _Etapa.reuniao2: return 'Coragem. Sabedoria. Coração. Três notas, um único acorde. 🎵';
      case _Etapa.finalHist: return 'O feitiço foi quebrado! Te agradeço por tudo, ótima sorte nessa sua jornada $_nomeJogador.';
      default: return '';
    }
  }

  // ================= INICIALIZAÇÃO =================
  @override
  void initState() {
    super.initState();
    _npcAnimCtrl = AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
    _npcScale = Tween<double>(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _npcAnimCtrl, curve: Curves.elasticOut));
    _npcRotate = Tween<double>(begin: -0.05, end: 0.0).animate(CurvedAnimation(parent: _npcAnimCtrl, curve: Curves.easeOut));
    
    _dialogoAnimCtrl = AnimationController(duration: const Duration(milliseconds: 700), vsync: this,
    );

    _audioPlayer = AudioPlayer();

    _checarAcessoEIniciar();
  }

  @override
  void dispose() {
    _timerTexto?.cancel();
    _npcAnimCtrl.dispose();
    _dialogoAnimCtrl.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ================= LÓGICA DE FIREBASE =================
  Future<void> _checarAcessoEIniciar() async {
  try {

    final prefs = await SharedPreferences.getInstance();

      _personagemId = 'Z4zP83zZeHKjXMv7ALoM';
    
    if (_personagemId == null) {

      debugPrint('[Gianluca] Personagem não encontrado');

      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('personagens')
        .doc(_personagemId)
        .get();

    if (!doc.exists) {

      debugPrint('[Gianluca] Documento inexistente');

      return;
    }

    final data = doc.data()!;

    _nomeJogador = data['nome'] ?? 'Viajante';

    final progressoAnterior =
        data['terrasen'] ?? [];

    bool podeEntrar = false;

    if (progressoAnterior is List &&
        progressoAnterior.isNotEmpty) {

      podeEntrar = progressoAnterior[0] == true;
    }

    if (!podeEntrar) {

      if (mounted) {

        setState(() {
          _etapa = _Etapa.bloqueado;
        });

        await _mostrarPopupBloqueado();
      }

      return;
    }

    await _iniciarCena();

  } catch (e, stack) {

    debugPrint('[Gianluca] ERRO');
    debugPrint(e.toString());
    debugPrint(stack.toString());

    if (mounted) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  Future<void> _salvarProgressoConservatorio() async {

  if (_personagemId == null) return;

  try {

    await FirebaseFirestore.instance
        .collection('personagens')
        .doc(_personagemId)
        .update({

      'conservatorio_diminuto': [
        true,
        Timestamp.now(),

        '[22.83239° S, 47.05127° W]'
      ]
    });

    debugPrint('[Gianluca] Progresso salvo');

  } catch (e) {

    debugPrint('[Gianluca] Erro ao salvar: $e');
  }
}

  Future<void> _iniciarCena() async {

  if (!mounted) return;

  setState(() {
    _etapa = _Etapa.chegada1;
  });

  await Future.delayed(const Duration(milliseconds: 500));

  if (!mounted) return;

  setState(() {
    _mostrarNpc = true;
  });

  _npcAnimCtrl.forward();

  await Future.delayed(const Duration(milliseconds: 600));

  if (!mounted) return;

  setState(() {
    _mostrarDialogo = true;
  });

  _dialogoAnimCtrl.forward();

  _exibirTexto(_textoAtual);
}

  // ================= LÓGICA DE INTERFACE =================
  void _exibirTexto(String texto) {

  _timerTexto?.cancel();

  setState(() {
    _textoExibido = '';
    _textoTerminou = false;
  });

  int i = 0;

  _timerTexto = Timer.periodic(
    const Duration(milliseconds: 30),
    (t) {

      if (!mounted) {
        t.cancel();
        return;
      }

      if (i < texto.length) {

        setState(() {
          _textoExibido += texto[i];
          if (texto[i] != ' ' && i % 2 == 0) {
            _tocarSomLetra();
          }
        });

        i++;

      } else {

        t.cancel();

        setState(() {
          _textoTerminou = true;
        });
      }
    },
  );
}

Future<void> _tocarSomLetra() async {

  if (!_somAtivado ||
      !_audioLiberado ||
      _tocandoSomLetra) return;

  try {

    _tocandoSomLetra = true;

    await _audioPlayer.stop();

    await _audioPlayer.play(
      AssetSource('audio/typewriter_click.mp3'),
    );

  } catch (e) {

    debugPrint('Erro som letra: $e');

  } finally {

    _tocandoSomLetra = false;
  }
}

Future<void> _toggleSom() async {

  if (!_somAtivado) {

    try {

      await _audioPlayer.setVolume(0.01);

      await _audioPlayer.play(
        AssetSource('audio/typewriter_click.mp3'),
      );

      await Future.delayed(
        const Duration(milliseconds: 80),
      );

      await _audioPlayer.stop();

      await _audioPlayer.setVolume(1.0);

      setState(() {

        _somAtivado = true;
        _audioLiberado = true;
      });

    } catch (e) {

      debugPrint('Erro som: $e');
    }

  } else {

    setState(() {

      _somAtivado = false;
    });
  }
}

  void _pularTexto() {

  if (_textoTerminou) return;

  _timerTexto?.cancel();

  setState(() {
    _textoExibido = _textoAtual;
    _textoTerminou = true;
  });
}

  Future<void> _avancarSimples() async {

  if (!_textoTerminou) return;

  switch (_etapa) {

    case _Etapa.chegada1:
      await _mudarEtapa(_Etapa.chegada2);
      break;

    case _Etapa.chegada2:
      await _mudarEtapa(_Etapa.dialogo1);
      break;

    case _Etapa.dialogo1:
      await _mudarEtapa(_Etapa.dialogo2);
      break;

    case _Etapa.dialogo2:
      await _mudarEtapa(_Etapa.dialogo3);
      break;

    case _Etapa.positivo:
      await _mudarEtapa(_Etapa.dialogo5);
      break;

    case _Etapa.dialogo5:
      await _mudarEtapa(_Etapa.desafio1);
      break;

    case _Etapa.reuniao1:
      await _mudarEtapa(_Etapa.reuniao2);
      break;

    case _Etapa.reuniao2:
      await _mudarEtapa(_Etapa.finalHist);
      break;

    case _Etapa.finalHist:
      await _mostrarPopupEscolhaFinal();
      break;

    default:
      break;
  }
}

  Future<void> _mudarEtapa(_Etapa novaEtapa) async {

  if (!mounted) return;

  setState(() {
    _etapa = novaEtapa;
  });

  _exibirTexto(_textoAtual);
}

  // ================= WIDGETS (BUILD) =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conservatório', style: GoogleFonts.cinzel(color: const Color(0xFFF8E7B9), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6B3F1D),
        foregroundColor: const Color(0xFFF8E7B9),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: [
          if (_fragmentos > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Chip(
                backgroundColor: const Color(0xFF9E8A4A).withValues(alpha:0.3),
                label: Text('💎 $_fragmentos/3', style: GoogleFonts.cinzel(color: const Color(0xFFF8E7B9), fontSize: 12, fontWeight: FontWeight.bold)),
                side: const BorderSide(color: Color(0xFF9E8A4A)),
              ),
            ),
          IconButton(
            onPressed: _toggleSom,
            icon: Icon(_somAtivado ? Icons.volume_up : Icons.volume_off, color: const Color(0xFFF8E7B9)),
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox.expand(child: Image.asset('assets/images/IMAGEM_OFICIAL_CONSERVATORIO.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF2D1A0A)))),
          Container(color: Colors.black.withValues(alpha:0.55)),
          
          if (_etapa == _Etapa.carregando) const Center(child: CircularProgressIndicator(color: Color(0xFFF8E7B9))),
          
          if (_etapa != _Etapa.carregando && _etapa != _Etapa.bloqueado) ...[
            _buildNpc(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(children: [
                  const Spacer(),
                  _buildCaixaDialogo(),
                  const SizedBox(height: 28),
                ]),
              ),
            ),
          ],
        ],
      ),
    );
  }

Widget _buildNpc() {
  return Align(
    alignment: Alignment.bottomLeft,
    child: Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 20),
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOut,
        offset: _mostrarNpc ? Offset.zero : const Offset(0, 0.2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 700),
          opacity: _mostrarNpc ? 1 : 0,
          child: ScaleTransition(
            scale: _npcScale,
            child: RotationTransition(
              turns: _npcRotate,
              child: Image.asset(
                'assets/images/cachorroMet.png',
                height: 320,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox(
                  height: 320,
                  child: Icon(
                    Icons.pets,
                    size: 100,
                    color: Color(0xFFF8E7B9),
                  ),
                ),
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
            color: Colors.black.withValues(alpha:0.78),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF9E8A4A), width: 2),
            boxShadow: [BoxShadow(color: const Color(0xFF9E8A4A).withValues(alpha:0.2), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBadgeFalante(),
              const SizedBox(height: 8),
              Text(_textoExibido, style: GoogleFonts.cinzel(fontSize: 15, height: 1.65, color: const Color(0xFFF8E7B9))),
              const SizedBox(height: 16),

              if (!_textoTerminou)
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _pularTexto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B3F1D),
                      foregroundColor: const Color(0xFFF8E7B9),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFF9E8A4A), width: 1.5)),
                    ),
                    child: Text('Continuar →', style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)),
                  ),
                ),

              if (_textoTerminou) _buildAcoes(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAcoes() {
    switch (_etapa) {
      case _Etapa.dialogo3:
      case _Etapa.espera:
        return _buildEscolhas([
          _OpcaoBtn(label: '1. Aceitar ser o aluno 🎵', onTap: () => _mudarEtapa(_Etapa.positivo)),
          _OpcaoBtn(label: '2. Recusar por enquanto', onTap: () => _mudarEtapa(_Etapa.espera), secundario: true),
        ]);
      case _Etapa.desafio1:
        return _buildEscolhas([
          _OpcaoBtn(label: '🎹 Dó Maior', onTap: () {
            setState(() => _fragmentos++);
            _mudarEtapa(_Etapa.reuniao1);
          }),
          _OpcaoBtn(label: '🎸 Sol Menor', onTap: () {
            _mudarEtapa(_Etapa.reuniao1); 
          }, secundario: true),
        ]);
      default:
        return Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _avancarSimples,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B3F1D),
              foregroundColor: const Color(0xFFF8E7B9),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFF9E8A4A), width: 1.5)),
            ),
            child: Text(_etapa == _Etapa.finalHist ? 'Finalizar História' : 'Continuar →', style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)),
          ),
        );
    }
  }

  Widget _buildEscolhas(List<_OpcaoBtn> opcoes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: opcoes.map((o) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ElevatedButton(
          onPressed: o.onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B3F1D),
            foregroundColor: const Color(0xFFF8E7B9),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFF9E8A4A), width: 1.5)),
            elevation: 4,
          ),
          child: Text(o.label, style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      )).toList(),
    );
  }

  Widget _buildBadgeFalante() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF6B3F1D).withValues(alpha:0.25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF8E7B9).withValues(alpha:0.3)),
      ),
      child: Text('Gianluca', style: GoogleFonts.cinzel(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFF8E7B9).withValues(alpha:0.65), letterSpacing: 0.5)),
    );
  }

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
            border: Border.all(
              color: const Color(0xFF9E8A4A),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9E8A4A).withValues(alpha:0.4),
                blurRadius: 25,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Icon(
                Icons.lock,
                size: 70,
                color: Color(0xFFF8E7B9),
              ),

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
                'Você precisa concluir Terrasen antes de acessar o Conservatório.',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  color: const Color(0xFFF8E7B9),
                  fontSize: 15,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(this.context).pop();
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
                  'Voltar',
                  style: GoogleFonts.cinzel(
                    fontWeight: FontWeight.bold,
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

            border: Border.all(
              color: const Color(0xFF9E8A4A),
              width: 2,
            ),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Text(
                'O Portal Musical Foi Aberto 🎵',

                textAlign: TextAlign.center,

                style: GoogleFonts.cinzel(
                  color: const Color(0xFFF8E7B9),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'A harmonia foi restaurada.\n\n'
                'Deseja salvar e sair ou continuar sua jornada?',

                textAlign: TextAlign.center,

                style: GoogleFonts.cinzel(
                  color: const Color(0xFFF8E7B9),
                  fontSize: 15,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: 260,

                child: ElevatedButton(

                  onPressed: () async {

                    await _salvarProgressoConservatorio();

                    if (mounted) {

                      Navigator.of(context).pop();

                      Navigator.of(this.context).pop();
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B3F1D),
                    foregroundColor: const Color(0xFFF8E7B9),
                  ),

                  child: Text(
                    '💾 Salvar e sair',

                    style: GoogleFonts.cinzel(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: 260,

                child: ElevatedButton(

                  onPressed: () async {

                    await _salvarProgressoConservatorio();

                    if (mounted) {

                      Navigator.of(context).pop();

                      Navigator.push(
                        this.context,
                        MaterialPageRoute(
                          builder: (_) => MundoMariaScreen(),
                        ),
                      );
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B3F1D),
                    foregroundColor: const Color(0xFFF8E7B9),
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
      );
    },
  );
}
}