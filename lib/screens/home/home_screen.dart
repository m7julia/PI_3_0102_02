import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:rpg_game/features/mundo_maria/screens/mundo_maria.dart';
import 'package:rpg_game/features/mundo_ana/screens/mundo_ana_screen.dart'; // ← novo
import 'package:rpg_game/features/mundo_rafael/screens/mundo_rafael_screen.dart';
import '../game/../game/personagem/criar_personagem_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../game/personagem/criar_personagem_screen.dart';

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

  Future<void> irParaMundoMaria() async {
    await player.stop();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MundoMariaScreen()),
    );
  }

  // ← novo
  Future<void> irParaMundoAna() async {
    await player.stop();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MundoAnaScreen()),
    );
  }

  Future<void> irParaMundoRafa() async {
    await player.stop();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MundoRafaScreen()),
    );
  }
  
  Future<void> irParaPersonagem() async {
    await player.stop();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CriarPersonagemScreen()),
    );
  }

  // ──────────────────────────────────────────────
  // GEOLOCALIZAÇÃO
  // ──────────────────────────────────────────────

  Future<Position?> _solicitarLocalizacao() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        _mostrarSnackBar('O serviço de localização está desativado.');
      }
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          _mostrarSnackBar('Permissão de localização negada.');
        }
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        _mostrarSnackBar(
          'Permissão negada permanentemente. Ative nas configurações.',
        );
      }
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _abrirMapa() async {
    final position = await _solicitarLocalizacao();
    if (position == null || !mounted) return;

    showDialog(
      context: context,
      builder: (_) => _MapaDialog(
        latitude: position.latitude,
        longitude: position.longitude,
      ),
    );
  }

  void _mostrarSnackBar(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensagem,
          style: GoogleFonts.cinzel(color: const Color(0xFFF8E7B9)),
        ),
        backgroundColor: const Color(0xFF3B1E08),
      ),
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
          // Fundo
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
                // Botão de mudo (topo direito)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Tooltip(
                    message: kIsWeb && !_audioIniciado
                        ? 'Clique para ativar o áudio'
                        : estaMutado
                        ? 'Ativar som'
                        : 'Silenciar',
                    child: _rpgIconButton(
                      icon: (kIsWeb && !_audioIniciado) || estaMutado
                          ? Icons.volume_off
                          : Icons.volume_up,
                      dimmed: kIsWeb && !_audioIniciado,
                      onPressed: alternarMute,
                    ),
                  ),
                ),

                // ── BOTÃO DO MAPA (topo esquerdo) ──
                Positioned(
                  top: 16,
                  left: 16,
                  child: Tooltip(
                    message: 'Ver localização no mapa',
                    child: _rpgIconButton(
                      icon: Icons.map_outlined,
                      onPressed: _abrirMapa,
                    ),
                  ),
                ),

                // Conteúdo central
                Center(
                  child: SingleChildScrollView(
                    child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateX(-0.85),
                          child: Text(
                            'MagIAlurA',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cinzelDecorative(
                              fontSize: 45,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFF8E7B9),
                              letterSpacing: 20,
                              shadows: [
                                for (int i = 1; i <= 10; i++)
                                  Shadow(
                                    color: Color.lerp(
                                      const Color.fromARGB(255, 0, 0, 0),
                                      Colors.black,
                                      i / 10,
                                    )!,
                                    offset: Offset(i.toDouble(), i.toDouble()),
                                    blurRadius: 0,
                                  ),
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
                                text: 'Mundo Maria',
                                onPressed: irParaMundoMaria,
                              ),
                              const SizedBox(height: 16),
                              _rpgMenuButton(
                                text: 'Terrasen', 
                                onPressed: irParaMundoAna,
                              ),
                               const SizedBox(height: 16),
                              _rpgMenuButton(
                                text: 'Estacionamento', 
                                onPressed: irParaMundoRafa,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Widget helper: ícone RPG (mudo / mapa) ──
  Widget _rpgIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool dimmed = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: dimmed
              ? const Color(0xFFF8E7B9).withOpacity(0.5)
              : const Color.fromARGB(255, 158, 138, 74),
          width: 2,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: dimmed
              ? const Color(0xFFF8E7B9).withOpacity(0.5)
              : const Color(0xFFF8E7B9),
        ),
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

// ══════════════════════════════════════════════════════════
// DIÁLOGO DO MAPA
// ══════════════════════════════════════════════════════════

class _MapaDialog extends StatelessWidget {
  final double latitude;
  final double longitude;

  const _MapaDialog({required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    final ponto = LatLng(latitude, longitude);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        height: 500,
        decoration: BoxDecoration(
          color: const Color(0xFF1A0E06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color.fromARGB(255, 158, 138, 74),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.7),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            // Cabeçalho
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.my_location,
                    color: Color(0xFFF8E7B9),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Sua Localização',
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF8E7B9),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFFF8E7B9)),
                  ),
                ],
              ),
            ),

            // Mapa
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                child: FlutterMap(
                  options: MapOptions(initialCenter: ponto, initialZoom: 15),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.exemplo.magialura',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: ponto,
                          width: 48,
                          height: 48,
                          child: const Icon(
                            Icons.location_pin,
                            color: Color(0xFFB22222),
                            size: 48,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Coordenadas
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}',
                style: GoogleFonts.cinzel(
                  fontSize: 12,
                  color: const Color(0xFFF8E7B9).withOpacity(0.6),
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
