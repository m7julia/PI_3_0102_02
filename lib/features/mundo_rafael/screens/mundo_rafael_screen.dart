import 'dart:math';
import 'package:flutter/material.dart';

enum _Etapa {
  inicio,
  rolarDado,
  resultadoFalha,
  resultadoReroll,
  resultadoSucesso,
  encontroNpc,
  resolucaoAjuda,
  resolucaoIgnorar,
  resolucaoEnfrentar,
  vitoriaComChave,
  vitoriaSemChave,
  derrota,
}

class MundoRafaelScreen extends StatefulWidget {
  const MundoRafaelScreen({super.key});

  @override
  State<MundoRafaelScreen> createState() => _MundoRafaelScreenState();
}

class _MundoRafaelScreenState extends State<MundoRafaelScreen> {
  static const int hpInicial = 100;
  static const int danoFalha = 15;
  static const int danoEnfrentar = 25;
  static const int curaAjuda = 20;
  static const int totalMovimentos = 5;

  final Random _rng = Random();

  _Etapa _etapa = _Etapa.inicio;
  int _hp = hpInicial;
  int _movimentos = 0;
  bool _temChave = false;
  bool _chaveUsada = false;
  bool _npcJaApareceu = false;
  int? _ultimoDado;

  // Lógica do dado

  void rolarDado() {
    final resultado = _rng.nextInt(6) + 1;

    if (resultado == 3) {
      setState(() {
        _ultimoDado = resultado;
        _etapa = _Etapa.resultadoReroll;
      });
      return;
    }

    if (resultado < 3) {
      if (_temChave && !_chaveUsada) {
        setState(() {
          _ultimoDado = resultado;
          _chaveUsada = true;
          _movimentos++;
          _etapa = _Etapa.resultadoSucesso;
        });
        return;
      }
      setState(() {
        _ultimoDado = resultado;
        _hp -= danoFalha;
        _etapa = _Etapa.resultadoFalha;
      });
      return;
    }

    setState(() {
      _ultimoDado = resultado;
      _movimentos++;
      _etapa = _Etapa.resultadoSucesso;
    });
  }

  // Lógica de resultado do dado

  void continuarAposResultado() {
    if (_etapa == _Etapa.resultadoFalha) {
      if (_hp <= 0) {
        setState(() {
          _hp = 0;
          _etapa = _Etapa.derrota;
        });
        return;
      }
      setState(() => _etapa = _Etapa.rolarDado);
      return;
    }

    if (_etapa == _Etapa.resultadoReroll) {
      setState(() => _etapa = _Etapa.rolarDado);
      return;
    }

    if (_etapa == _Etapa.resultadoSucesso) {
      if (!_npcJaApareceu) {
        setState(() {
          _npcJaApareceu = true;
          _etapa = _Etapa.encontroNpc;
        });
        return;
      }
      if (_movimentos >= totalMovimentos) {
        setState(() => _etapa =
            _temChave ? _Etapa.vitoriaComChave : _Etapa.vitoriaSemChave);
        return;
      }
      setState(() => _etapa = _Etapa.rolarDado);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('em construção')),
    );
  }
}
