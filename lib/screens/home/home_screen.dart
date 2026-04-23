import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../game/../game/personagem/criar_personagem_screen.dart';

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
      setState(() => estaMutado = true);
    } else {
      tocarMusica();
    }
  }

  Future<void> tocarMusica() async {
    await player.setReleaseMode(ReleaseMode.loop);
    await player.setVolume(0.5);
    await player.play(AssetSource('audio/music/menu.mp3'));
  }

  Future<void> alternarMute() async {
    if (kIsWeb && !_audioIniciado) {
      await tocarMusica();
      setState(() {
        estaMutado = false;
        _audioIniciado = true;
      });
      return;
    }
    setState(() => estaMutado = !estaMutado);
    await player.setVolume(estaMutado ? 0.0 : 0.5);
  }


  

  Future<void> irParaPersonagem() async {
    await player.stop();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CriarPersonagemScreen()),
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

                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // título com perspectiva 3D
                        Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateX(-0.85),
                          child: Text(
                            'MagIAlurA',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cinzelDecorative(
                              fontSize: 115,
                              fontWeight: FontWeight.bold,
                              color: const Color(
                                0xFFF8E7B9,
                              ), // cor da frente - amarelo claro
                              letterSpacing: 20,
                              shadows: [
                                // camadas que criam a "profundidade" 3D
                                for (int i = 1; i <= 10; i++)
                                  Shadow(
                                    color: Color.lerp(
                                      const Color.fromARGB(
                                        255,
                                        0,
                                        0,
                                        0,
                                      ), // dourado escuro
                                      Colors.black,
                                      i / 10,
                                    )!,
                                    offset: Offset(i.toDouble(), i.toDouble()),
                                    blurRadius: 0, // efeito 3D
                                  ),
                                // sombra de profundidade final
                                const Shadow(
                                  color: Colors.black,
                                  offset: Offset(10, 10),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 115),

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
                                onPressed: irParaPersonagem,
                              ),
                              const SizedBox(height: 16),
                              _rpgMenuButton(
                                text: 'Continuar',
                                onPressed: () {},
                              ),
                              const SizedBox(height: 16),
                              _rpgMenuButton(
                                text: 'Configurações',
                                onPressed: () {},
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