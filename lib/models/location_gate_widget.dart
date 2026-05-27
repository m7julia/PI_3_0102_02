import 'package:flutter/material.dart';
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
  // <-- observa o ciclo de vida do app
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

  /// Roda novamente quando o app volta ao primeiro plano
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _verificarLocalizacao();
    }
  }

  Future<void> _verificarLocalizacao() async {
    setState(() {
      _verificando = true;
      _liberado = false; // reseta antes de verificar
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_off, color: Colors.red),
            SizedBox(width: 8),
            Text('Área bloqueada'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Você precisa estar próximo de "${widget.nomeFase}" para jogar esta fase.',
            ),
            if (distancia != null) ...[
              const SizedBox(height: 12),
              Text(
                'Você está a ${distancia.toStringAsFixed(0)}m do local.\n'
                'Chegue a menos de ${widget.raio.toStringAsFixed(0)}m para entrar.',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // fecha o dialog
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
            child: const Text('Voltar'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _verificarLocalizacao();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_verificando) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Verificando sua localização...'),
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
