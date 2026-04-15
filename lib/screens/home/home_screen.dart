import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../intro/intro_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer player = AudioPlayer();
  bool estaMutado = false;
  bool _audioIniciado = false;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      // Na web, começa mutado e aguarda interação do usuário
      // para evitar bloqueio de autoplay do browser
      setState(() => estaMutado = true);
    } else {
      // Mobile/Desktop: toca automaticamente
      tocarMusica();
    }
  }

  Future<void> tocarMusica() async {
    await player.setReleaseMode(ReleaseMode.loop);
    await player.setVolume(0.5);
    await player.play(AssetSource('audio/music/menu.mp3'));
  }

  Future<void> alternarMute() async {
    // Na web, se o áudio ainda não foi iniciado, inicia na primeira interação
    if (kIsWeb && !_audioIniciado) {
      await tocarMusica();
      setState(() {
        estaMutado = false;
        _audioIniciado = true;
      });
      return;
    }

    // Comportamento padrão de toggle mute
    setState(() => estaMutado = !estaMutado);
    await player.setVolume(estaMutado ? 0.0 : 0.5);
  }

  Future<void> irParaIntro() async {
    await player.stop();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const IntroScreen()),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo com imagem e overlay escuro
          SizedBox.expand(
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/background.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),

          SafeArea(
            child: Stack(
              children: [
                // Botão de mute/unmute com tooltip explicativo na web
                Positioned(
                  top: 16,
                  right: 16,
                  child: Tooltip(
                    message: kIsWeb && !_audioIniciado
                        ? 'Clique para ativar o áudio'
                        : estaMutado
                            ? 'Ativar som'
                            : 'Silenciar',
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: kIsWeb && !_audioIniciado
                              ? const Color(0xFFF8E7B9).withOpacity(0.5)
                              : const Color.fromARGB(255, 158, 138, 74),
                          width: 2,
                        ),
                      ),
                      child: IconButton(
                        onPressed: alternarMute,
                        icon: Icon(
                          // Na web antes de iniciar: mostra volume_off
                          // Após iniciar: alterna entre volume_up e volume_off
                          (kIsWeb && !_audioIniciado) || estaMutado
                              ? Icons.volume_off
                              : Icons.volume_up,
                          color: kIsWeb && !_audioIniciado
                              ? const Color(0xFFF8E7B9).withOpacity(0.5)
                              : const Color(0xFFF8E7B9),
                        ),
                      ),
                    ),
                  ),
                ),

                // Conteúdo central
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'MAGIALURA',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cinzelDecorative(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFF8E7B9),
                            letterSpacing: 1.5,
                            shadows: const [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 10,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        Container(
                          width: 300,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color.fromARGB(255, 158, 138, 74),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _rpgMenuButton(
                                text: 'Iniciar',
                                onPressed: irParaIntro,
                              ),
                              const SizedBox(height: 16),
                              _rpgMenuButton(
                                text: 'Continuar',
                                onPressed: () {
                                  print('Continuar jogo');
                                },
                              ),
                              const SizedBox(height: 16),
                              _rpgMenuButton(
                                text: 'Configurações',
                                onPressed: () {
                                  print('Configurações');
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _rpgMenuButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B3F1D),
          foregroundColor: const Color(0xFFF8E7B9),
          elevation: 6,
          shadowColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(
              color: Color.fromARGB(255, 0, 0, 0),
              width: 2,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          text,
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}