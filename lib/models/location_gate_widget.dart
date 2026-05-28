import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'location_gate.dart';
import 'package:rpg_game/screens/home/home_screen.dart';

class LocationGateWidget extends StatefulWidget {
  final Widget child;
  final GeoPoint localizacaoFase;
  final String nomeFase;
  final double raio;

  const LocationGateWidget({
    super.key,
    required this.child,
    required this.localizacaoFase,
    required this.nomeFase,
    this.raio = LocationGate.raioPermitidoMetros,
  });

  @override
  State<LocationGateWidget> createState() => _LocationGateWidgetState();
}

class _LocationGateWidgetState extends State<LocationGateWidget>
    with WidgetsBindingObserver {
  bool _verificando = true;
  bool _liberado = false;
  double? _distanciaAtual;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _verificarLocalizacao();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _verificarLocalizacao();
    }
  }

  Future<void> _verificarLocalizacao() async {
    setState(() {
      _verificando = true;
      _liberado = false;
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final distancia = LocationGate.distanciaMetros(
        posicaoAtual: position,
        localizacaoFase: widget.localizacaoFase,
      );

      setState(() {
        _distanciaAtual = distancia;
        _liberado = distancia <= widget.raio;
        _verificando = false;
      });

      if (!_liberado && mounted) {
        _mostrarPopupBloqueio();
      }
    } catch (e) {
      setState(() => _verificando = false);
    }
  }

  void _mostrarPopupBloqueio() {
    final distancia = _distanciaAtual;
    final size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: size.width * 0.06,
          vertical: size.height * 0.12,
        ),
        child: Container(
          width: double.infinity,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_off,
                size: (size.width * 0.13).clamp(40.0, 58.0),
                color: const Color(0xFFF8E7B9),
              ),
              SizedBox(height: size.height * 0.018),
              Text(
                'Área Bloqueada',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  color: const Color(0xFFF8E7B9),
                  fontSize: (size.width * 0.050).clamp(16.0, 22.0),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.016),
              Text(
                'Você precisa estar próximo de "${widget.nomeFase}" para jogar esta fase.',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  color: const Color(0xFFF8E7B9),
                  fontSize: (size.width * 0.034).clamp(12.0, 15.0),
                  height: 1.55,
                ),
              ),
              if (distancia != null) ...[
                SizedBox(height: size.height * 0.012),
                Text(
                  'Você está a ${distancia.toStringAsFixed(0)}m do local.\n'
                  'Chegue a menos de ${widget.raio.toStringAsFixed(0)}m para entrar.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFF8E7B9).withValues(alpha: 0.55),
                    fontSize: (size.width * 0.028).clamp(10.0, 13.0),
                    height: 1.55,
                  ),
                ),
              ],
              SizedBox(height: size.height * 0.024),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _verificarLocalizacao();
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(
                    'Tentar novamente',
                    style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B3F1D),
                    foregroundColor: const Color(0xFFF8E7B9),
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.014,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(
                        color: Color(0xFF9E8A4A),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.012),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFFF8E7B9),
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.014,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: const Color(0xFF9E8A4A).withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Text(
                    'Voltar',
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (_verificando) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1208),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFFF8E7B9)),
              SizedBox(height: size.height * 0.025),
              Text(
                'Verificando sua localização...',
                style: GoogleFonts.cinzel(
                  color: const Color(0xFFF8E7B9),
                  fontSize: (size.width * 0.037).clamp(13.0, 16.0),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_liberado) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return widget.child;
  }
}
