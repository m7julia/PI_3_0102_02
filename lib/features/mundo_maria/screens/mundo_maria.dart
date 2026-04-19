// screens/mundo_maria/mundo_maria_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MundoMariaScreen extends StatelessWidget {
  const MundoMariaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mundo da Maria',
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
              'assets/images/fundo_fazenda.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFF8E7B9),
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 66,
                        backgroundColor: Color(0xFF6B3F1D),
                        child: Icon(
                          Icons.agriculture,
                          size: 70,
                          color: Color(0xFFF8E7B9),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Maria Fazendeira',
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF8E7B9),
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 6,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8E7B9).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: const Color(0xFFF8E7B9),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '🐮 Fazendeira 🐔',
                        style: GoogleFonts.cinzel(
                          fontSize: 18,
                          color: const Color(0xFFF8E7B9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildGameCard(
                      context: context,
                      title: 'Ligue 3',
                      description: 'Combine 6 de cada colheita na fazenda!',
                      icon: Icons.grid_3x3,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const Ligue3Game(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildGameCard(
                      context: context,
                      title: 'Jogo da Memória',
                      description: 'Encontre os pares na matriz',
                      icon: Icons.memory,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const JogoMemoriaGame(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: Color(0xFFF8E7B9),
          width: 1.5,
        ),
      ),
      color: const Color(0xFF6B3F1D).withOpacity(0.9),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8E7B9).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: const Color(0xFFF8E7B9),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cinzel(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF8E7B9),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: GoogleFonts.cinzel(
                        fontSize: 14,
                        color: const Color(0xFFF8E7B9).withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                color: Color(0xFFF8E7B9),
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ligue 3 — Meta: colher 6 unidades de cada elemento (girassol, milho, trigo,
// abóbora). Elementos são móveis (drag & drop). O tabuleiro inicial nunca
// contém 3 iguais alinhados horizontal ou verticalmente.
// ---------------------------------------------------------------------------

class Ligue3Game extends StatefulWidget {
  const Ligue3Game({super.key});

  @override
  State<Ligue3Game> createState() => _Ligue3GameState();
}

class _Ligue3GameState extends State<Ligue3Game> {
  // ── constantes ────────────────────────────────────────────────────────────
  static const int gridSize = 5;
  static const int metaPorElemento = 6;

  static const List<Map<String, dynamic>> icones = [
    {'emoji': '🌻', 'nome': 'Girassol', 'cor': Color(0xFFF9A825)},
    {'emoji': '🌽', 'nome': 'Milho',    'cor': Color(0xFF558B2F)},
    {'emoji': '🌾', 'nome': 'Trigo',    'cor': Color(0xFFBF8C00)},
    {'emoji': '🎃', 'nome': 'Abóbora',  'cor': Color(0xFFE64A19)},
  ];

  // ── estado ────────────────────────────────────────────────────────────────
  late List<List<String>> matriz;
  List<List<int>> selecionados = []; // lista de [linha, coluna]
  Map<String, int> colhidos = {};
  int pontuacao = 0;
  String mensagem = '';
  bool mensagemErro = false;
  bool faseConcluida = false;

  // drag
  List<int>? dragOrigem; // [linha, coluna]

  // ── ciclo de vida ─────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    iniciarJogo();
  }

  // ── inicialização ─────────────────────────────────────────────────────────

  /// Gera um tabuleiro 5×5 com exatamente 6 cópias de cada emoji,
  /// garantindo que nenhuma linha/coluna inicie com 3+ iguais consecutivos.
  void iniciarJogo() {
    matriz = _gerarMatrizSemTrios();
    selecionados = [];
    colhidos = {for (var i in icones) i['emoji'] as String: 0};
    pontuacao = 0;
    mensagem = '';
    mensagemErro = false;
    faseConcluida = false;
  }

  List<List<String>> _gerarMatrizSemTrios() {
    final rng = Random();
    // pool: 6 de cada emoji = 24 células; 1 posição restante → escolha aleatória
    List<String> pool = [];
    for (var ic in icones) {
      for (int k = 0; k < metaPorElemento; k++) {
        pool.add(ic['emoji'] as String);
      }
    }
    // 25 - 24 = 1 extra
    pool.add((icones[rng.nextInt(icones.length)]['emoji']) as String);

    List<List<String>> board;
    int tentativas = 0;
    do {
      pool.shuffle(rng);
      board = List.generate(
        gridSize,
        (r) => List.generate(gridSize, (c) => pool[r * gridSize + c]),
      );
      tentativas++;
      if (tentativas > 10000) break; // segurança
    } while (_temTrioInicial(board));

    return board;
  }

  bool _temTrioInicial(List<List<String>> b) {
    // horizontal
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c <= gridSize - 3; c++) {
        if (b[r][c] == b[r][c + 1] && b[r][c] == b[r][c + 2]) return true;
      }
    }
    // vertical
    for (int c = 0; c < gridSize; c++) {
      for (int r = 0; r <= gridSize - 3; r++) {
        if (b[r][c] == b[r + 1][c] && b[r][c] == b[r + 2][c]) return true;
      }
    }
    return false;
  }

  // ── lógica de seleção e combinação ────────────────────────────────────────

  void _tocarCelula(int linha, int coluna) {
    final pos = [linha, coluna];
    final jaSelected = selecionados.any((s) => s[0] == linha && s[1] == coluna);

    setState(() {
      if (jaSelected) {
        selecionados.removeWhere((s) => s[0] == linha && s[1] == coluna);
        return;
      }

      final emojiAtual = matriz[linha][coluna];

      // Se já há selecionados de outro tipo → limpa e começa do zero
      if (selecionados.isNotEmpty &&
          matriz[selecionados[0][0]][selecionados[0][1]] != emojiAtual) {
        selecionados = [pos];
        return;
      }

      // Máximo 3 do mesmo tipo
      if (selecionados.length < 3) {
        selecionados.add(pos);
      }

      if (selecionados.length == 3) {
        _tentarCombinar();
      }
    });
  }

  void _tentarCombinar() {
    final emoji = matriz[selecionados[0][0]][selecionados[0][1]];
    final todosIguais =
        selecionados.every((s) => matriz[s[0]][s[1]] == emoji);

    if (!todosIguais) {
      selecionados = [];
      return;
    }

    // Registra colheita
    colhidos[emoji] = (colhidos[emoji] ?? 0) + 3;
    pontuacao += 10;

    // Remove as 3 células selecionadas e faz as peças acima caírem
    for (final pos in selecionados) {
      matriz[pos[0]][pos[1]] = '';
    }
    selecionados = [];

    _aplicarGravidade();
    _verificarFaseConcluida();

    mensagem = '+10 pontos colhidos!';
    mensagemErro = false;
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => mensagem = '');
    });
  }

  /// Faz os elementos "caírem" para preencher os espaços vazios por coluna,
  /// depois reabastece o topo com novos elementos aleatórios sem criar trios.
  void _aplicarGravidade() {
    final rng = Random();
    for (int c = 0; c < gridSize; c++) {
      // coleta elementos não-vazios de baixo para cima
      List<String> coluna = [];
      for (int r = gridSize - 1; r >= 0; r--) {
        if (matriz[r][c].isNotEmpty) coluna.add(matriz[r][c]);
      }
      // preenche o topo com novos elementos
      while (coluna.length < gridSize) {
        coluna.add(
            (icones[rng.nextInt(icones.length)]['emoji']) as String);
      }
      // coluna[0] = bottom, coluna[last] = top
      for (int r = gridSize - 1; r >= 0; r--) {
        matriz[r][c] = coluna[gridSize - 1 - r];
      }
    }
    // Corrige eventuais trios criados pelo reabastecimento
    _corrigirTrios();
  }

  void _corrigirTrios() {
    bool houveCorrecao = true;
    int tentativas = 0;
    final rng = Random();
    while (houveCorrecao && tentativas < 100) {
      houveCorrecao = false;
      tentativas++;
      // horizontal
      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c <= gridSize - 3; c++) {
          if (matriz[r][c] == matriz[r][c + 1] &&
              matriz[r][c] == matriz[r][c + 2]) {
            final emojisDisponiveis = icones
                .map((e) => e['emoji'] as String)
                .where((e) => e != matriz[r][c])
                .toList();
            matriz[r][c + 2] =
                emojisDisponiveis[rng.nextInt(emojisDisponiveis.length)];
            houveCorrecao = true;
          }
        }
      }
      // vertical
      for (int c = 0; c < gridSize; c++) {
        for (int r = 0; r <= gridSize - 3; r++) {
          if (matriz[r][c] == matriz[r + 1][c] &&
              matriz[r][c] == matriz[r + 2][c]) {
            final emojisDisponiveis = icones
                .map((e) => e['emoji'] as String)
                .where((e) => e != matriz[r][c])
                .toList();
            matriz[r + 2][c] =
                emojisDisponiveis[rng.nextInt(emojisDisponiveis.length)];
            houveCorrecao = true;
          }
        }
      }
    }
  }

  void _verificarFaseConcluida() {
    if (icones.every(
        (ic) => (colhidos[ic['emoji'] as String] ?? 0) >= metaPorElemento)) {
      faseConcluida = true;
    }
  }

  // ── drag & drop ───────────────────────────────────────────────────────────

  void _iniciarDrag(int linha, int coluna) {
    dragOrigem = [linha, coluna];
  }

  void _finalizarDrop(int linhaDestino, int colunaDestino) {
    if (dragOrigem == null) return;
    final lo = dragOrigem![0], co = dragOrigem![1];
    dragOrigem = null;

    if (lo == linhaDestino && co == colunaDestino) return;

    setState(() {
      // Troca as posições
      final tmp = matriz[lo][co];
      matriz[lo][co] = matriz[linhaDestino][colunaDestino];
      matriz[linhaDestino][colunaDestino] = tmp;
      selecionados = [];

      // Verifica se a troca criou combinações automáticas
      _verificarCombinacaoAutomatica();
    });
  }

  void _verificarCombinacaoAutomatica() {
    bool houveMatch = true;
    while (houveMatch) {
      houveMatch = false;
      // horizontal
      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c <= gridSize - 3; c++) {
          if (matriz[r][c].isNotEmpty &&
              matriz[r][c] == matriz[r][c + 1] &&
              matriz[r][c] == matriz[r][c + 2]) {
            final emoji = matriz[r][c];
            colhidos[emoji] = (colhidos[emoji] ?? 0) + 3;
            pontuacao += 10;
            matriz[r][c] = matriz[r][c + 1] = matriz[r][c + 2] = '';
            houveMatch = true;
          }
        }
      }
      // vertical
      for (int c = 0; c < gridSize; c++) {
        for (int r = 0; r <= gridSize - 3; r++) {
          if (matriz[r][c].isNotEmpty &&
              matriz[r][c] == matriz[r + 1][c] &&
              matriz[r][c] == matriz[r + 2][c]) {
            final emoji = matriz[r][c];
            colhidos[emoji] = (colhidos[emoji] ?? 0) + 3;
            pontuacao += 10;
            matriz[r][c] = matriz[r + 1][c] = matriz[r + 2][c] = '';
            houveMatch = true;
          }
        }
      }
      if (houveMatch) _aplicarGravidade();
    }
    _verificarFaseConcluida();
  }

  // ── helpers visuais ───────────────────────────────────────────────────────

  Color _corDoEmoji(String emoji) {
    final ic = icones.firstWhere(
      (e) => e['emoji'] == emoji,
      orElse: () => {'cor': Colors.grey},
    );
    return ic['cor'] as Color;
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ligue 3',
            style: GoogleFonts.cinzel(color: const Color(0xFFF8E7B9))),
        backgroundColor: const Color(0xFF6B3F1D),
        foregroundColor: const Color(0xFFF8E7B9),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Color(0xFFF8E7B9)),
                const SizedBox(width: 6),
                Text('$pontuacao',
                    style: GoogleFonts.cinzel(
                        fontSize: 18, color: const Color(0xFFF8E7B9))),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // fundo
          SizedBox.expand(
            child: Image.asset('assets/images/fundo_fazenda.jpeg',
                fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withOpacity(0.6)),

          // conteúdo
          SafeArea(
            child: Column(
              children: [
                // ── descrição da meta ──────────────────────────────────────
                _buildDescricaoMeta(),

                // ── contadores ────────────────────────────────────────────
                _buildContadores(),

                // ── mensagem de feedback ──────────────────────────────────
                if (mensagem.isNotEmpty) _buildMensagem(),

                // ── instrução ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Toque 3 iguais ou arraste para mover',
                    style: GoogleFonts.cinzel(
                      fontSize: 12,
                      color: const Color(0xFFF8E7B9).withOpacity(0.75),
                    ),
                  ),
                ),

                // ── grade ─────────────────────────────────────────────────
                Expanded(child: _buildGrade()),

                // ── botão novo jogo ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: ElevatedButton(
                    onPressed: () => setState(() => iniciarJogo()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B3F1D),
                      foregroundColor: const Color(0xFFF8E7B9),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                            color: Color(0xFFF8E7B9), width: 1),
                      ),
                    ),
                    child: Text('Novo Jogo',
                        style: GoogleFonts.cinzel(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          // ── overlay de fase concluída ──────────────────────────────────
          if (faseConcluida) _buildFaseConcluida(),
        ],
      ),
    );
  }

  // ── widgets auxiliares ────────────────────────────────────────────────────

  Widget _buildDescricaoMeta() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF6B3F1D).withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFF8E7B9).withOpacity(0.6), width: 1),
      ),
      child: Column(
        children: [
          Text(
            '🌾 Meta da Fase 🌾',
            style: GoogleFonts.cinzel(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFF8E7B9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Combine grupos de 3 para colher 6 unidades\nde cada elemento da fazenda!',
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              fontSize: 11,
              color: const Color(0xFFF8E7B9).withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContadores() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFF8E7B9).withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: icones.map((ic) {
          final emoji = ic['emoji'] as String;
          final cor = ic['cor'] as Color;
          final atual = colhidos[emoji] ?? 0;
          final progresso =
              (atual / metaPorElemento).clamp(0.0, 1.0);
          final completo = atual >= metaPorElemento;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 24)),
                      if (completo)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check,
                                size: 9, color: Colors.black),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // barra de progresso
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progresso,
                      minHeight: 6,
                      backgroundColor:
                          const Color(0xFFF8E7B9).withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          completo ? Colors.greenAccent : cor),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$atual/$metaPorElemento',
                    style: GoogleFonts.cinzel(
                      fontSize: 10,
                      color: completo
                          ? Colors.greenAccent
                          : const Color(0xFFF8E7B9),
                      fontWeight: completo
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMensagem() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(mensagem),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: mensagemErro ? Colors.red.shade700 : Colors.green.shade700,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          mensagem,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildGrade() {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridSize,
              crossAxisSpacing: 7,
              mainAxisSpacing: 7,
            ),
            itemCount: gridSize * gridSize,
            itemBuilder: (context, index) {
              final linha = index ~/ gridSize;
              final coluna = index % gridSize;
              final emoji = matriz[linha][coluna];
              final selecionado = selecionados
                  .any((s) => s[0] == linha && s[1] == coluna);

              return DragTarget<List<int>>(
                onWillAcceptWithDetails: (details) => true,
                onAcceptWithDetails: (details) =>
                    _finalizarDrop(linha, coluna),
                builder: (context, candidateData, rejectedData) {
                  final highlight = candidateData.isNotEmpty;
                  return Draggable<List<int>>(
                    data: [linha, coluna],
                    onDragStarted: () => _iniciarDrag(linha, coluna),
                    feedback: Material(
                      color: Colors.transparent,
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 40)),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: _buildCelula(
                          emoji, false, false, linha, coluna),
                    ),
                    child: GestureDetector(
                      onTap: () => _tocarCelula(linha, coluna),
                      child: _buildCelula(
                          emoji, selecionado, highlight, linha, coluna),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCelula(String emoji, bool selecionado, bool highlight,
      int linha, int coluna) {
    final cor = _corDoEmoji(emoji);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        border: Border.all(
          color: selecionado
              ? Colors.greenAccent
              : highlight
                  ? Colors.white
                  : const Color(0xFFF8E7B9).withOpacity(0.7),
          width: selecionado || highlight ? 3 : 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
        color: selecionado
            ? cor.withOpacity(0.4)
            : const Color(0xFF6B3F1D).withOpacity(0.88),
        boxShadow: selecionado
            ? [
                BoxShadow(
                  color: cor.withOpacity(0.55),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 3),
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaseConcluida() {
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF6B3F1D),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF8E7B9), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🌟 Fase Concluída! 🌟',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzelDecorative(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF8E7B9),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Você colheu tudo!\nPontuação final: $pontuacao pontos',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  fontSize: 16,
                  color: const Color(0xFFF8E7B9).withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() => iniciarJogo()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8E7B9),
                  foregroundColor: const Color(0xFF6B3F1D),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 36, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Jogar Novamente',
                    style: GoogleFonts.cinzel(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Jogo da Memória
//
// Regras:
//  • 9 cartas: 4 pares de cultivos (🌻🌽🌾🎃) + 1 ferradura 🐴 (única)
//  • Apenas 2 cartas por vez podem estar viradas pelo jogador
//  • Par encontrado → cartas ficam com ícone à mostra permanentemente
//  • A ferradura NÃO pode ser tocada pelo jogador
//  • Quando o último par de cultivos é achado → ferradura vira sozinha
//    com um pequeno delay e exibe overlay "Nível Concluído"
// ---------------------------------------------------------------------------

class JogoMemoriaGame extends StatefulWidget {
  const JogoMemoriaGame({super.key});

  @override
  State<JogoMemoriaGame> createState() => _JogoMemoriaGameState();
}

class _JogoMemoriaGameState extends State<JogoMemoriaGame> {
  // ── constantes ────────────────────────────────────────────────────────────
  static const String _ferradura = '🐴';
  static const List<String> _emojisPares = ['🌻', '🌽', '🌾', '🎃'];
  static const int _totalPares = 4; // número de pares de cultivos

  // ── estado ────────────────────────────────────────────────────────────────
  late List<String> cartas;     // emoji em cada posição (índice 0–8)
  late List<bool> combinadas;   // carta faz parte de um par já encontrado
  late List<bool> reveladas;    // virada temporariamente nesta tentativa

  int? primeiroIndex;           // índice da 1ª carta virada na tentativa atual
  bool bloqueado = false;       // bloqueia novos toques enquanto anima erro

  int pontuacao = 0;
  int paresEncontrados = 0;     // pares de cultivos acertados (máx 4)
  bool faseConcluida = false;

  @override
  void initState() {
    super.initState();
    iniciarJogo();
  }

  // ── inicialização ─────────────────────────────────────────────────────────

  void iniciarJogo() {
    // 4 pares de cultivos (8 cartas) + 1 ferradura = 9 cartas
    final baralho = [..._emojisPares, ..._emojisPares, _ferradura]
      ..shuffle(Random());

    cartas        = baralho;
    combinadas    = List.generate(9, (_) => false);
    reveladas     = List.generate(9, (_) => false);
    primeiroIndex = null;
    bloqueado     = false;
    pontuacao     = 0;
    paresEncontrados = 0;
    faseConcluida = false;
  }

  // ── lógica principal ──────────────────────────────────────────────────────

  void _tocarCarta(int index) {
    // ignora ferradura (só vira automaticamente), cartas já combinadas,
    // cartas já reveladas nesta tentativa e cliques enquanto animando erro
    if (bloqueado) return;
    if (combinadas[index]) return;
    if (reveladas[index]) return;
    if (cartas[index] == _ferradura) return;

    setState(() => reveladas[index] = true);

    if (primeiroIndex == null) {
      // ── primeira carta da tentativa ───────────────────────────────────
      primeiroIndex = index;
      return;
    }

    // ── segunda carta — avalia o par ──────────────────────────────────
    final primeiro = primeiroIndex!;
    primeiroIndex = null;

    if (cartas[primeiro] == cartas[index]) {
      // PAR ENCONTRADO
      setState(() {
        combinadas[primeiro] = true;
        combinadas[index]    = true;
        pontuacao += 10;
        paresEncontrados++;
      });

      // todos os pares de cultivos achados → ferradura vira sozinha
      if (paresEncontrados == _totalPares) {
        _revelarFerraduraEConcluir();
      }
    } else {
      // NÃO FORMOU PAR — vira as duas cartas de volta após 900 ms
      bloqueado = true;
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() {
          reveladas[primeiro] = false;
          reveladas[index]    = false;
          bloqueado = false;
        });
      });
    }
  }

  void _revelarFerraduraEConcluir() {
    // delay antes de virar a ferradura para o jogador ver o último par
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      final idx = cartas.indexOf(_ferradura);
      setState(() {
        reveladas[idx]  = true;
        combinadas[idx] = true;
      });

      // delay antes do overlay de conclusão
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() => faseConcluida = true);
      });
    });
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jogo da Memória',
            style: GoogleFonts.cinzel(color: const Color(0xFFF8E7B9))),
        backgroundColor: const Color(0xFF6B3F1D),
        foregroundColor: const Color(0xFFF8E7B9),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Color(0xFFF8E7B9)),
                const SizedBox(width: 8),
                Text('$pontuacao',
                    style: GoogleFonts.cinzel(fontSize: 18, color: const Color(0xFFF8E7B9))),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('assets/images/fundo_fazenda.jpeg', fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withOpacity(0.6)),

          SafeArea(
            child: Column(
              children: [
                _buildDescricaoMeta(),
                _buildContadorPares(),
                Expanded(child: _buildGrade()),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () => setState(() => iniciarJogo()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B3F1D),
                      foregroundColor: const Color(0xFFF8E7B9),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0xFFF8E7B9), width: 1),
                      ),
                    ),
                    child: Text('Novo Jogo',
                        style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          if (faseConcluida) _buildFaseConcluida(),
        ],
      ),
    );
  }

  // ── widgets auxiliares ────────────────────────────────────────────────────

  Widget _buildDescricaoMeta() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF6B3F1D).withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF8E7B9).withOpacity(0.6), width: 1),
      ),
      child: Column(
        children: [
          Text('🧠 Jogo da Memória 🧠',
              style: GoogleFonts.cinzel(
                  fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFF8E7B9))),
          const SizedBox(height: 4),
          Text(
            'Vire 2 cartas por vez e encontre os pares.\nAche todos os 4 pares para revelar a ferradura!',
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
                fontSize: 11, color: const Color(0xFFF8E7B9).withOpacity(0.85)),
          ),
        ],
      ),
    );
  }

  Widget _buildContadorPares() {
    final ferraduraIdx = cartas.indexOf(_ferradura);
    final ferraduraRevelada = combinadas[ferraduraIdx];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF8E7B9).withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // um indicador por par de cultivos
          ..._emojisPares.map((emoji) {
            final idx1 = cartas.indexOf(emoji);
            final idx2 = cartas.lastIndexOf(emoji);
            final encontrado = idx1 >= 0 && idx2 >= 0 && combinadas[idx1] && combinadas[idx2];
            return _buildIconeContador(
              emoji: emoji,
              encontrado: encontrado,
              label: encontrado ? 'Par!' : '?/?',
              corLabel: encontrado ? Colors.greenAccent : const Color(0xFFF8E7B9).withOpacity(0.5),
            );
          }),

          // ferradura (revelada automaticamente ao final)
          _buildIconeContador(
            emoji: _ferradura,
            encontrado: ferraduraRevelada,
            label: ferraduraRevelada ? 'Única!' : '🔒',
            corLabel: ferraduraRevelada ? Colors.amberAccent : const Color(0xFFF8E7B9).withOpacity(0.5),
            corCheck: Colors.amberAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildIconeContador({
    required String emoji,
    required bool encontrado,
    required String label,
    required Color corLabel,
    Color corCheck = Colors.greenAccent,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Text(
              emoji,
              style: TextStyle(
                fontSize: 22,
                color: encontrado ? Colors.white : Colors.white.withOpacity(0.3),
              ),
            ),
            if (encontrado)
              Positioned(
                right: 0, top: 0,
                child: Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(color: corCheck, shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 9, color: Colors.black),
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.cinzel(
                fontSize: 10, color: corLabel, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGrade() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 9,
            itemBuilder: (context, index) => _buildCarta(index),
          ),
        ),
      ),
    );
  }

  Widget _buildCarta(int index) {
    final bool visivel   = reveladas[index] || combinadas[index];
    final bool combinada = combinadas[index];
    final bool ehFerr    = cartas[index] == _ferradura;

    // borda e glow variam conforme o estado da carta
    Color borderColor = const Color(0xFFF8E7B9);
    double borderWidth = 2;
    Color bgColor = const Color(0xFF8B5A2B).withOpacity(0.9);
    List<BoxShadow> sombras = [
      BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 5, offset: const Offset(2, 2)),
    ];

    if (combinada && ehFerr) {
      borderColor = Colors.amberAccent;
      borderWidth = 3;
      bgColor = Colors.amber.withOpacity(0.25);
      sombras = [BoxShadow(color: Colors.amberAccent.withOpacity(0.5), blurRadius: 12, spreadRadius: 3)];
    } else if (combinada) {
      borderColor = Colors.greenAccent;
      borderWidth = 3;
      bgColor = Colors.green.withOpacity(0.2);
      sombras = [BoxShadow(color: Colors.greenAccent.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)];
    } else if (reveladas[index]) {
      borderColor = Colors.white;
      borderWidth = 2.5;
      bgColor = const Color(0xFF6B3F1D).withOpacity(0.9);
    }

    return GestureDetector(
      onTap: () => _tocarCarta(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: BorderRadius.circular(16),
          color: visivel ? bgColor : const Color(0xFF8B5A2B).withOpacity(0.9),
          boxShadow: sombras,
        ),
        child: visivel
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cartas[index], style: const TextStyle(fontSize: 48)),
                    if (ehFerr)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Única!',
                          style: GoogleFonts.cinzel(
                              fontSize: 12,
                              color: Colors.amberAccent,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              )
            : Center(
                child: Icon(
                  Icons.question_mark_rounded,
                  size: 48,
                  color: const Color(0xFFF8E7B9).withOpacity(0.8),
                ),
              ),
      ),
    );
  }

  Widget _buildFaseConcluida() {
    return Container(
      color: Colors.black.withOpacity(0.78),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF6B3F1D),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF8E7B9), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🌟 Nível Concluído! 🌟',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzelDecorative(
                    fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFFF8E7B9)),
              ),
              const SizedBox(height: 8),
              Text(
                '🐴 A ferradura trouxe sorte! 🐴',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                    fontSize: 15,
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Todos os pares foram encontrados!\nPontuação: $pontuacao pontos',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                    fontSize: 14, color: const Color(0xFFF8E7B9).withOpacity(0.9)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() => iniciarJogo()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8E7B9),
                  foregroundColor: const Color(0xFF6B3F1D),
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Jogar Novamente',
                    style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
