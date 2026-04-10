class Personagem {
  final String nome;
  final int vidaAtual;
  final int vidaMax;

  Personagem({
    required this.nome,
    required this.vidaAtual,
    required this.vidaMax,
  });

  // Map para salvar no fire
  Map<String, dynamic> toMap() {
    return {'nome': nome, 'vidaAtual': vidaAtual, 'vidaMax': vidaMax};
  }

  // Map para objeto, para mostrar na tela
  factory Personagem.fromMap(Map<String, dynamic> map) {
    return Personagem(
      nome: map['nome'] ?? '',
      vidaAtual: map['vidaAtual'] ?? 0,
      vidaMax: map['vidaMax'] ?? 0,
    );
  }
}
