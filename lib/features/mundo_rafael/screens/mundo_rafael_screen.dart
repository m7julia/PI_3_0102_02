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

  // Escolhas interacao com o NPC

  void escolhaPedirAjuda() {
    setState(() {
      _hp = (_hp + curaAjuda).clamp(0, hpInicial);
      _temChave = true;
      _etapa = _Etapa.resolucaoAjuda;
    });
  }

  void escolhaIgnorar() {
    setState(() => _etapa = _Etapa.resolucaoIgnorar);
  }

  void escolhaEnfrentar() {
    setState(() {
      _hp -= danoEnfrentar;
      _etapa = _Etapa.resolucaoEnfrentar;
    });
  }

  // Continuar após interacao com o NPC

  void continuarAposNpc() {
    if (_hp <= 0) {
      setState(() {
        _hp = 0;
        _etapa = _Etapa.derrota;
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

  // Texto exibido em cada etapa

  String get textoAtual {
    switch (_etapa) {
      case _Etapa.inicio:
        return 'Você chega em frente a um estacionamento caótico. '
            'A travessia parece simples, mas algo no ar diz que cada passo conta. '
            'Cinco passos te separam do outro lado. '
            'Sorte e cautela são suas únicas aliadas.';

      case _Etapa.rolarDado:
        return 'Role o dado para tentar avançar.\n\n'
            'Passo ${_movimentos + 1} de $totalMovimentos.';

      case _Etapa.resultadoFalha:
        return 'Você tirou $_ultimoDado. '
            'Tropeçou e perdeu $danoFalha de vida.';

      case _Etapa.resultadoReroll:
        return 'Você tirou 3 — role o dado novamente.';

      case _Etapa.resultadoSucesso:
        final salvouComChave =
            _temChave && _chaveUsada && (_ultimoDado ?? 7) < 3;
        if (salvouComChave) {
          return 'Você tirou $_ultimoDado, mas a chave do motorista te socorre. '
              'O destino te dá uma segunda chance e você avança um passo.';
        }
        return 'Você tirou $_ultimoDado. Avançou um passo no estacionamento.';

      case _Etapa.encontroNpc:
        return 'Um carro freia bruscamente ao seu lado. Um motorista abaixa o vidro e te encara.';

      case _Etapa.resolucaoAjuda:
        return 'O motorista sorri e te entrega a chave do estacionamento. '
            'Te oferece água e um descanso curto: você recupera $curaAjuda de vida. '
            'A chave pode te salvar de uma falha no caminho.';

      case _Etapa.resolucaoIgnorar:
        return 'Você segue em frente sem dizer nada. '
            'O motorista observa em silêncio.';

      case _Etapa.resolucaoEnfrentar:
        return 'Você enfrenta o motorista. A briga é curta mas custosa: '
            '$danoEnfrentar de vida perdidos.';

      case _Etapa.vitoriaComChave:
        return 'Você atravessou o estacionamento e abre o portão com a chave. '
            'Saiu com elegância — o caminho à frente é seu.';

      case _Etapa.vitoriaSemChave:
        return 'Você atravessou o estacionamento e força a passagem pelo portão. '
            'Ao passar encontra a chave necessária, um caminho dificil, mas chegou.';

      case _Etapa.derrota:
        return 'Sua vida acabou no meio da travessia. '
            'O estacionamento te derrotou.';
    }
  }

  // Reiniciar os atributos da fase

  void reiniciar() {
    setState(() {
      _etapa = _Etapa.inicio;
      _hp = hpInicial;
      _movimentos = 0;
      _temChave = false;
      _chaveUsada = false;
      _npcJaApareceu = false;
      _ultimoDado = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('em construção')),
    );
  }
}
