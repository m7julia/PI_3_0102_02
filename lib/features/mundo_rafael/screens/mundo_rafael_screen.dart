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

  bool get _ehResultadoDado => _etapa == _Etapa.resultadoFalha || _etapa == _Etapa.resultadoReroll || _etapa == _Etapa.resultadoSucesso;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.35),
        elevation: 0,
        foregroundColor: Colors.amber.shade200,
        title: Text(
          'Estacionamento',
          style: TextStyle(
            color: Colors.amber.shade200,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          _hudChip(
            icon: Icons.favorite,
            label: '$_hp',
            cor: Colors.redAccent,
          ),
          _hudChip(
            icon: Icons.directions_walk,
            label: '$_movimentos/$totalMovimentos',
            cor: Colors.lightBlueAccent,
          ),
          if (_temChave)
            _hudChip(
              icon: _chaveUsada ? Icons.lock_open : Icons.vpn_key,
              label: _chaveUsada ? 'usada' : 'ok',
              cor: Colors.amber,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fundo_estacionamento.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  Container(color: const Color(0xFF1A1A1A)),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.55)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Spacer(),
                  _caixaDialogo(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hudChip({
    required IconData icon,
    required String label,
    required Color cor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cor.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: cor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: cor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _caixaDialogo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber.shade300.withValues(alpha: 0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_ehResultadoDado && _ultimoDado != null) _badgeDado(_ultimoDado!),
          Text(
            textoAtual,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 18),
          _botoesAcao(),
        ],
      ),
    );
  }

  Widget _badgeDado(int valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.casino, size: 16, color: Colors.amber),
            const SizedBox(width: 6),
            Text(
              'Dado: $valor',
              style: TextStyle(
                color: Colors.amber.shade200,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botoesAcao() {
    switch (_etapa) {
      case _Etapa.inicio:
        return _botaoPrimario(
          label: 'Começar a travessia',
          icone: Icons.play_arrow,
          onTap: () => setState(() => _etapa = _Etapa.rolarDado),
        );

      case _Etapa.rolarDado:
        return _botaoPrimario(
          label: 'Rolar o dado',
          icone: Icons.casino,
          onTap: rolarDado,
        );

      case _Etapa.resultadoFalha:
      case _Etapa.resultadoReroll:
      case _Etapa.resultadoSucesso:
        return _botaoPrimario(
          label: 'Continuar',
          icone: Icons.arrow_forward,
          onTap: continuarAposResultado,
        );

      case _Etapa.encontroNpc:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _botaoEscolha(
              label: 'Pedir ajuda',
              icone: Icons.handshake,
              onTap: escolhaPedirAjuda,
            ),
            const SizedBox(height: 8),
            _botaoEscolha(
              label: 'Ignorar e seguir',
              icone: Icons.directions_walk,
              onTap: escolhaIgnorar,
              secundario: true,
            ),
            const SizedBox(height: 8),
            _botaoEscolha(
              label: 'Enfrentar',
              icone: Icons.sports_kabaddi,
              onTap: escolhaEnfrentar,
              secundario: true,
            ),
          ],
        );

      case _Etapa.resolucaoAjuda:
      case _Etapa.resolucaoIgnorar:
      case _Etapa.resolucaoEnfrentar:
        return _botaoPrimario(
          label: 'Continuar',
          icone: Icons.arrow_forward,
          onTap: continuarAposNpc,
        );

      case _Etapa.vitoriaComChave:
      case _Etapa.vitoriaSemChave:
      case _Etapa.derrota:
        return Row(
          children: [
            Expanded(
              child: _botaoEscolha(
                label: 'Jogar de novo',
                icone: Icons.refresh,
                onTap: reiniciar,
                secundario: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _botaoEscolha(
                label: 'Voltar',
                icone: Icons.exit_to_app,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        );
    }
  }

  Widget _botaoPrimario({
    required String label,
    required IconData icone,
    required VoidCallback onTap,
  }) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icone, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber.shade700,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.amber, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _botaoEscolha({
    required String label,
    required IconData icone,
    required VoidCallback onTap,
    bool secundario = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icone, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            secundario ? Colors.transparent : Colors.amber.shade700,
        foregroundColor: secundario ? Colors.amber.shade200 : Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: secundario
                ? Colors.amber.shade300.withValues(alpha: 0.6)
                : Colors.amber,
            width: 1.5,
          ),
        ),
        elevation: secundario ? 0 : 4,
      ),
    );
  }
}