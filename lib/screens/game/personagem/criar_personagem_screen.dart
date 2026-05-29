import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/personagem_service.dart';
import '../../../models/personagem.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rpg_game/features/mundo_rafael/screens/mundo_rafael_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rpg_game/models/location_gate_widget.dart';

class CriarPersonagemScreen extends StatefulWidget {
  const CriarPersonagemScreen({super.key});

  @override
  State<CriarPersonagemScreen> createState() => _CriarPersonagemScreenState();
}

class _CriarPersonagemScreenState extends State<CriarPersonagemScreen> {
  final TextEditingController nomeController = TextEditingController();

  bool _salvando = false;
  int etapa = 0;
  String nomeJogador = '';

  String textoVisivel = '';
  bool textoCompleto = false;

  Timer? timerTexto;

  bool mostrarConteudo = false;
  bool _mostrarNpc = false;
  bool _mostrarDialogo = false;

  final List<String> falasIniciais = [
    'Ei! Você consegue me ouvir? Eu sou Rowan. Vou te ajudar no que puder.',
    'Que bom. Achei que você fosse dormir para sempre. Você estava no seu laboratório, na frente do computador e cochilou.',
    'Só que enquanto dormia, um portal se abriu e te puxou. Agora você está aqui. Entre mundos. E não, não é sonho.',
    'Existem cinco mundos espalhados por este lugar. Cada um guarda uma chave e você precisa das cinco para abrir o portal de volta ao seu mundo.',
    'Nenhum dos mundos vai ser fácil. Cada um tem seus próprios desafios, suas próprias regras, em que você vai precisar de coragem, raciocínio e talvez um pouco de sorte.',
    'Mas antes de qualquer coisa, preciso saber seu nome. Todo herói precisa de um nome.',
  ];

  String get falaAtual {
    if (etapa == 8) {
      return '$nomeJogador... Bom nome para alguém que atravessou um portal dormindo. Guarde bem esse nome. Os mundos vão aprender a temê-lo.';
    }
    if (etapa == 9) {
      return 'Cinco mundos. Cinco chaves. Um caminho de volta para casa. A jornada começa agora, $nomeJogador.';
    }
    return falasIniciais[etapa];
  }

  @override
  void initState() {
    super.initState();
    _iniciarCena();
  }

  Future<void> _iniciarCena() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      mostrarConteudo = true;
      _mostrarNpc = true;
    });
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _mostrarDialogo = true);
    mostrarTexto(falaAtual);
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

  void avancarDialogo() {
    if (!textoCompleto) return;

    if (etapa < 7) {
      setState(() => etapa++);
      mostrarTexto(falaAtual);
    }
  }

  Future<void> confirmarNome() async {
    final nome = nomeController.text.trim();

    if (nome.isEmpty) {
      _mostrarMensagem('Digite um nome para o personagem');
      return;
    }

    setState(() {
      nomeJogador = nome;
      etapa = 8;
    });

    mostrarTexto(falaAtual);
  }

  Future<void> finalizarCriacao() async {
    setState(() => _salvando = true);

    try {
      final service = PersonagemService();
      final personagem = Personagem(nome: nomeJogador);
      final personagemId = await service.criarPersonagem(personagem);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('personagemAtualId', personagemId);

      _mostrarMensagem('Personagem criado com sucesso!');

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LocationGateWidget(
            key: UniqueKey(),
            localizacaoFase: const GeoPoint(-22.8344, -47.05177),
            nomeFase: 'Estacionamento Caótico',
            child: const MundoRafaelScreen(),
          ),
        ),
      );
    } catch (e) {
      _mostrarMensagem('Erro ao salvar: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
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

  List<String> get opcoesAtuais {
    if (etapa == 7) return ['Confirmar nome'];
    if (etapa == 8) return ['Continuar →'];
    if (etapa == 9) return ['Começar jornada'];
    return ['Continuar'];
  }

  void escolherOpcao(String opcao) {
    if (!textoCompleto || _salvando) return;

    if (opcao == 'Continuar' || opcao == 'Continuar →') {
      if (etapa == 8) {
        setState(() => etapa = 9);
        mostrarTexto(falaAtual);
      } else {
        avancarDialogo();
      }
    } else if (opcao == 'Confirmar nome') {
      confirmarNome();
    } else if (opcao == 'Começar jornada') {
      finalizarCriacao();
    }
  }

  @override
  void dispose() {
    timerTexto?.cancel();
    nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Crie seu personagem',
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
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fundo_tela_inicial.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF2D1A0A)),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.55)),

          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 60),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 700),
                opacity: _mostrarNpc ? 1.0 : 0.0,
                child: Image.asset(
                  'assets/images/personagem_tela_inicial.png',
                  height: 360,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox(height: 320),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Spacer(),
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

  Widget _buildCaixaDialogo() {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      offset: _mostrarDialogo ? Offset.zero : const Offset(0, 0.3),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 700),
        opacity: _mostrarDialogo ? 1.0 : 0.0,
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBadgeFalante(),
              const SizedBox(height: 8),

              Text(
                textoVisivel,
                style: GoogleFonts.cinzel(
                  fontSize: 15,
                  height: 1.65,
                  color: const Color(0xFFF8E7B9),
                ),
              ),

              if (etapa == 7 && textoCompleto) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: nomeController,
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFF8E7B9),
                    fontSize: 15,
                  ),
                  cursorColor: const Color(0xFFF8E7B9),
                  decoration: InputDecoration(
                    hintText: 'Digite o nome do personagem',
                    hintStyle: GoogleFonts.cinzel(
                      color: const Color(0xFFF8E7B9).withValues(alpha: 0.4),
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.35),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF9E8A4A)),
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

              const SizedBox(height: 16),

              if (!textoCompleto)
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: acelerarTexto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B3F1D),
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
                      'Continuar →',
                      style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

              if (textoCompleto)
                ...opcoesAtuais.map(
                  (opcao) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _salvando
                            ? null
                            : () => escolherOpcao(opcao),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B3F1D),
                          foregroundColor: const Color(0xFFF8E7B9),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Color(0xFF9E8A4A),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: _salvando && opcao == 'Começar jornada'
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFF8E7B9),
                                ),
                              )
                            : Text(
                                opcao,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cinzel(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
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
  }

  Widget _buildBadgeFalante() {
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
        'Rowan',
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
