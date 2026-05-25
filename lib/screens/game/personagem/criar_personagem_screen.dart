import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/personagem_service.dart';
import '../../../models/personagem.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rpg_game/features/mundo_rafael/screens/mundo_rafael_screen.dart';

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

  final List<String> falasIniciais = [
    'Saudações, viajante...',
    'Há muito tempo aguardávamos sua chegada.',
    'Antes de começar sua jornada, diga-me: qual é o seu nome?',
  ];

  String get falaAtual {
    if (etapa == 3) {
      return 'Muito bem... então você será conhecido como $nomeJogador.\nSua jornada está prestes a começar.';
    }
    return falasIniciais[etapa];
  }

  @override
  void initState() {
    super.initState();
    _iniciarCena();
  }

  Future<void> _iniciarCena() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => mostrarConteudo = true);
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

    if (etapa < 2) {
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
      etapa = 3;
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
        MaterialPageRoute(builder: (_) => const MundoRafaelScreen()),
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
    if (etapa == 2) return ['Confirmar nome'];
    if (etapa == 3) return ['Começar jornada'];
    return ['Continuar'];
  }

  void escolherOpcao(String opcao) {
    if (!textoCompleto || _salvando) return;

    if (opcao == 'Continuar') {
      avancarDialogo();
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
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 600;

    // Tamanhos responsivos
    final titleFontSize = (size.width * 0.08).clamp(22.0, 38.0);
    final subtitleFontSize = (size.width * 0.045).clamp(14.0, 22.0);
    final personagemHeight = (size.height * 0.38).clamp(180.0, 340.0);
    final dialogMargin = size.width * 0.04;
    final dialogPadding = size.width * 0.045;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          SizedBox.expand(
            child: Image.asset(
              'assets/images/criar_personagem.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          Container(color: Colors.black.withValues(alpha: 0.6)),

          // Personagem (canto inferior esquerdo)
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: size.width * 0.02,
                bottom: size.height * 0.28,
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 700),
                opacity: mostrarConteudo ? 1.0 : 0.0,
                child: Image.asset(
                  'assets/images/personagem_rafa.png',
                  height: personagemHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Botão voltar
          Positioned(
            top: 50,
            left: 16,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF9E8A4A),
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
            ),
          ),

          // Título e subtítulo
          Positioned(
            top: isSmall ? 40 : 70,
            left: 80,
            right: 24,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 700),
              opacity: mostrarConteudo ? 1.0 : 0.0,
              child: Column(
                children: [
                  Text(
                    'Nova Jornada',
                    style: GoogleFonts.cinzel(
                      fontSize: titleFontSize,
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
                  const SizedBox(height: 6),
                  Text(
                    'Motorista Suspeito',
                    style: GoogleFonts.cinzel(
                      fontSize: subtitleFontSize,
                      color: Colors.white70,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Caixa de diálogo inferior
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 700),
              opacity: mostrarConteudo ? 1.0 : 0.0,
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(dialogMargin),
                  padding: EdgeInsets.all(dialogPadding),
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
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tag de quem fala
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF6B3F1D,
                          ).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(
                              0xFFF8E7B9,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          'Motorista Suspeito',
                          style: GoogleFonts.cinzel(
                            fontSize: (size.width * 0.025).clamp(10.0, 13.0),
                            fontWeight: FontWeight.bold,
                            color: const Color(
                              0xFFF8E7B9,
                            ).withValues(alpha: 0.65),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Texto animado
                      Text(
                        textoVisivel,
                        style: GoogleFonts.cinzel(
                          fontSize: (size.width * 0.037).clamp(13.0, 16.0),
                          height: 1.65,
                          color: const Color(0xFFF8E7B9),
                        ),
                        textAlign: TextAlign.left,
                      ),

                      // Campo de nome (etapa 2)
                      if (etapa == 2 && textoCompleto) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: nomeController,
                          style: GoogleFonts.cinzel(
                            color: const Color(0xFFF8E7B9),
                            fontSize: (size.width * 0.037).clamp(13.0, 16.0),
                          ),
                          cursorColor: const Color(0xFFF8E7B9),
                          decoration: InputDecoration(
                            hintText: 'Digite o nome do personagem',
                            hintStyle: GoogleFonts.cinzel(
                              color: const Color(
                                0xFFF8E7B9,
                              ).withValues(alpha: 0.4),
                              fontSize: (size.width * 0.035).clamp(12.0, 15.0),
                            ),
                            filled: true,
                            fillColor: Colors.black.withValues(alpha: 0.35),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: size.height * 0.014,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF9E8A4A),
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

                      SizedBox(height: size.height * 0.02),

                      // Botão acelerar texto
                      if (!textoCompleto)
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: acelerarTexto,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B3F1D),
                              foregroundColor: const Color(0xFFF8E7B9),
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.05,
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
                                fontSize: (size.width * 0.035).clamp(
                                  12.0,
                                  15.0,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Botões de ação
                      if (textoCompleto) ...[
                        SizedBox(height: size.height * 0.01),
                        ...opcoesAtuais.map((opcao) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _salvando
                                    ? null
                                    : () => escolherOpcao(opcao),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6B3F1D),
                                  foregroundColor: const Color(0xFFF8E7B9),
                                  padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.016,
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
                                          fontSize: (size.width * 0.035).clamp(
                                            12.0,
                                            15.0,
                                          ),
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
            ),
          ),
        ],
      ),
    );
  }
}
