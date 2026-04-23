import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/nivel_service.dart';

class Ligue3Game extends StatefulWidget {
  const Ligue3Game({super.key});

  @override
  State<Ligue3Game> createState() => _Ligue3GameState();
}

class _Ligue3GameState extends State<Ligue3Game> {
  // ── constantes ────────────────────────────────────────────────────────────
  static const int gridSize = 5;
  static const int metaPorElemento = 6;

  static const List<Map<String, dynamic>> cultivos = [
    {
      'asset': 'assets/images/icons/girassol_icon.png',
      'nome': 'Girassol',
      'cor': Color(0xFFF9A825),
      'emoji': '🌻' // fallback
    },
    {
      'asset': 'assets/images/icons/milho_icon.png',
      'nome': 'Milho',
      'cor': Color(0xFF558B2F),
      'emoji': '🌽'
    },
    {
      'asset': 'assets/images/icons/trigo_icon.png',
      'nome': 'Trigo',
      'cor': Color(0xFFBF8C00),
      'emoji': '🌾'
    },
    {
      'asset': 'assets/images/icons/abobora_icon.png',
      'nome': 'Abóbora',
      'cor': Color(0xFFE64A19),
      'emoji': '🎃'
    },
  ];

  // ── estado ────────────────────────────────────────────────────────────────
  late List<List<String>> matriz; // armazena caminhos dos assets
  List<List<int>> selecionados = [];
  Map<String, int> colhidos = {}; // chave = asset path
  int pontuacao = 0;
  String mensagem = '';
  bool mensagemErro = false;
  bool faseConcluida = false;
  List<int>? dragOrigem;
  
  // Cache de imagens
  Map<String, Widget> _imageCache = {};

  // ── ciclo de vida ─────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _precarregarImagens();
    iniciarJogo();
  }

  Future<void> _precarregarImagens() async {
    for (var cultivo in cultivos) {
      await precacheImage(AssetImage(cultivo['asset']), context);
    }
  }

  // ── inicialização ─────────────────────────────────────────────────────────
  void iniciarJogo() {
    matriz = _gerarMatrizSemTrios();
    selecionados = [];
    colhidos = {
      for (var cultivo in cultivos) cultivo['asset'] as String: 0
    };
    pontuacao = 0;
    mensagem = '';
    mensagemErro = false;
    faseConcluida = false;
  }

  List<List<String>> _gerarMatrizSemTrios() {
    final rng = Random();
    // pool: 6 de cada cultivo = 24 células; 1 posição restante → escolha aleatória
    List<String> pool = [];
    for (var cultivo in cultivos) {
      for (int k = 0; k < metaPorElemento; k++) {
        pool.add(cultivo['asset'] as String);
      }
    }
    // 25 - 24 = 1 extra
    pool.add(cultivos[rng.nextInt(cultivos.length)]['asset'] as String);

    List<List<String>> board;
    int tentativas = 0;
    do {
      pool.shuffle(rng);
      board = List.generate(
        gridSize,
        (r) => List.generate(gridSize, (c) => pool[r * gridSize + c]),
      );
      tentativas++;
      if (tentativas > 10000) break;
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

  // ── helpers para assets ───────────────────────────────────────────────────
  String _getEmojiForAsset(String assetPath) {
    final cultivo = cultivos.firstWhere(
      (c) => c['asset'] == assetPath,
      orElse: () => cultivos[0],
    );
    return cultivo['emoji'] as String;
  }

  Color _getCorForAsset(String assetPath) {
    final cultivo = cultivos.firstWhere(
      (c) => c['asset'] == assetPath,
      orElse: () => cultivos[0],
    );
    return cultivo['cor'] as Color;
  }

  Widget _buildImageWidget(String assetPath, {double size = 32}) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback para emoji
        return Text(
          _getEmojiForAsset(assetPath),
          style: TextStyle(fontSize: size),
        );
      },
    );
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

      final assetAtual = matriz[linha][coluna];

      if (selecionados.isNotEmpty &&
          matriz[selecionados[0][0]][selecionados[0][1]] != assetAtual) {
        selecionados = [pos];
        return;
      }

      if (selecionados.length < 3) {
        selecionados.add(pos);
      }

      if (selecionados.length == 3) {
        _tentarCombinar();
      }
    });
  }

  void _tentarCombinar() {
    final asset = matriz[selecionados[0][0]][selecionados[0][1]];
    final todosIguais = selecionados.every((s) => matriz[s[0]][s[1]] == asset);

    if (!todosIguais) {
      selecionados = [];
      return;
    }

    colhidos[asset] = (colhidos[asset] ?? 0) + 3;
    pontuacao += 10;

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

  void _aplicarGravidade() {
    final rng = Random();
    for (int c = 0; c < gridSize; c++) {
      List<String> coluna = [];
      for (int r = gridSize - 1; r >= 0; r--) {
        if (matriz[r][c].isNotEmpty) coluna.add(matriz[r][c]);
      }
      while (coluna.length < gridSize) {
        coluna.add(cultivos[rng.nextInt(cultivos.length)]['asset'] as String);
      }
      for (int r = gridSize - 1; r >= 0; r--) {
        matriz[r][c] = coluna[gridSize - 1 - r];
      }
    }
    _corrigirTrios();
  }

  void _corrigirTrios() {
    bool houveCorrecao = true;
    int tentativas = 0;
    final rng = Random();
    while (houveCorrecao && tentativas < 100) {
      houveCorrecao = false;
      tentativas++;
      
      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c <= gridSize - 3; c++) {
          if (matriz[r][c] == matriz[r][c + 1] &&
              matriz[r][c] == matriz[r][c + 2]) {
            final assetsDisponiveis = cultivos
                .map((e) => e['asset'] as String)
                .where((e) => e != matriz[r][c])
                .toList();
            matriz[r][c + 2] = assetsDisponiveis[rng.nextInt(assetsDisponiveis.length)];
            houveCorrecao = true;
          }
        }
      }
      
      for (int c = 0; c < gridSize; c++) {
        for (int r = 0; r <= gridSize - 3; r++) {
          if (matriz[r][c] == matriz[r + 1][c] &&
              matriz[r][c] == matriz[r + 2][c]) {
            final assetsDisponiveis = cultivos
                .map((e) => e['asset'] as String)
                .where((e) => e != matriz[r][c])
                .toList();
            matriz[r + 2][c] = assetsDisponiveis[rng.nextInt(assetsDisponiveis.length)];
            houveCorrecao = true;
          }
        }
      }
    }
  }

  void _verificarFaseConcluida() {
    if (cultivos.every(
        (cultivo) => (colhidos[cultivo['asset'] as String] ?? 0) >= metaPorElemento)) {
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
      final tmp = matriz[lo][co];
      matriz[lo][co] = matriz[linhaDestino][colunaDestino];
      matriz[linhaDestino][colunaDestino] = tmp;
      selecionados = [];
      _verificarCombinacaoAutomatica();
    });
  }

  void _verificarCombinacaoAutomatica() {
    bool houveMatch = true;
    while (houveMatch) {
      houveMatch = false;
      
      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c <= gridSize - 3; c++) {
          if (matriz[r][c].isNotEmpty &&
              matriz[r][c] == matriz[r][c + 1] &&
              matriz[r][c] == matriz[r][c + 2]) {
            final asset = matriz[r][c];
            colhidos[asset] = (colhidos[asset] ?? 0) + 3;
            pontuacao += 10;
            matriz[r][c] = matriz[r][c + 1] = matriz[r][c + 2] = '';
            houveMatch = true;
          }
        }
      }
      
      for (int c = 0; c < gridSize; c++) {
        for (int r = 0; r <= gridSize - 3; r++) {
          if (matriz[r][c].isNotEmpty &&
              matriz[r][c] == matriz[r + 1][c] &&
              matriz[r][c] == matriz[r + 2][c]) {
            final asset = matriz[r][c];
            colhidos[asset] = (colhidos[asset] ?? 0) + 3;
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

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ligue 3',
          style: GoogleFonts.cinzel(color: const Color(0xFFF8E7B9)),
        ),
        backgroundColor: const Color(0xFF6B3F1D),
        foregroundColor: const Color(0xFFF8E7B9),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Color(0xFFF8E7B9)),
                const SizedBox(width: 6),
                Text(
                  '$pontuacao',
                  style: GoogleFonts.cinzel(
                    fontSize: 18,
                    color: const Color(0xFFF8E7B9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fundo_fazenda.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: const Color(0xFF6B3F1D));
              },
            ),
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.6),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildDescricaoMeta(),
                _buildContadores(),
                if (mensagem.isNotEmpty) _buildMensagem(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Toque 3 iguais ou arraste para mover',
                    style: GoogleFonts.cinzel(
                      fontSize: 12,
                      color: const Color(0xFFF8E7B9).withValues(alpha: 0.75),
                    ),
                  ),
                ),
                Expanded(child: _buildGrade()),
                Padding(
                  padding: const EdgeInsets.all(12),
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
                    child: Text(
                      'Novo Jogo',
                      style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
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
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF6B3F1D).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF8E7B9).withValues(alpha: 0.6),
          width: 1,
        ),
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
              color: const Color(0xFFF8E7B9).withValues(alpha: 0.85),
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
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF8E7B9).withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: cultivos.map((cultivo) {
          final asset = cultivo['asset'] as String;
          final cor = cultivo['cor'] as Color;
          final atual = colhidos[asset] ?? 0;
          final progresso = (atual / metaPorElemento).clamp(0.0, 1.0);
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
                      _buildImageWidget(asset, size: 36),
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
                            child: const Icon(Icons.check, size: 9, color: Colors.black),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progresso,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFF8E7B9).withValues(alpha: 0.2),
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
                      fontWeight: completo ? FontWeight.bold : FontWeight.normal,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: mensagemErro ? Colors.red.shade700 : Colors.green.shade700,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          mensagem,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
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
              final asset = matriz[linha][coluna];
              final selecionado = selecionados.any((s) => s[0] == linha && s[1] == coluna);

              return DragTarget<List<int>>(
                onWillAcceptWithDetails: (details) => true,
                onAcceptWithDetails: (details) => _finalizarDrop(linha, coluna),
                builder: (context, candidateData, rejectedData) {
                  final highlight = candidateData.isNotEmpty;
                  return Draggable<List<int>>(
                    data: [linha, coluna],
                    onDragStarted: () => _iniciarDrag(linha, coluna),
                    feedback: Material(
                      color: Colors.transparent,
                      child: _buildImageWidget(asset, size: 40),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: _buildCelula(asset, false, false),
                    ),
                    child: GestureDetector(
                      onTap: () => _tocarCelula(linha, coluna),
                      child: _buildCelula(asset, selecionado, highlight),
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

  Widget _buildCelula(String asset, bool selecionado, bool highlight) {
    final cor = _getCorForAsset(asset);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        border: Border.all(
          color: selecionado
              ? Colors.greenAccent
              : highlight
                  ? Colors.white
                  : const Color(0xFFF8E7B9).withValues(alpha: 0.7),
          width: selecionado || highlight ? 3 : 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
        color: selecionado
            ? cor.withValues(alpha: 0.4)
            : const Color(0xFF6B3F1D).withValues(alpha: 0.88),
        boxShadow: selecionado
            ? [
                BoxShadow(
                  color: cor.withValues(alpha: 0.55),
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
            _buildImageWidget(asset, size: 48),
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
      color: Colors.black.withValues(alpha: 0.75),
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
                  color: const Color(0xFFF8E7B9).withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() => iniciarJogo()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8E7B9),
                  foregroundColor: const Color(0xFF6B3F1D),
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Jogar Novamente',
                  style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}