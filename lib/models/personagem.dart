import 'package:cloud_firestore/cloud_firestore.dart';

class MundoProgresso {
  final bool completado;
  final DateTime? dataEvento;  // null até completar a fase (em branco)
  final GeoPoint localizacao;  // localização FIXA

  MundoProgresso({
    this.completado = false,
    this.dataEvento,
    required this.localizacao,
  });

  /// converte para o array de 3 elementos do firestore
  List<dynamic> toArray() {
    return [
      completado,
      dataEvento != null ? Timestamp.fromDate(dataEvento!) : null,
      localizacao,
    ];
  }

  /// lê o array do firestore
  factory MundoProgresso.fromArray(List<dynamic> array, {required GeoPoint localizacaoPadrao}) {
    return MundoProgresso(
      completado: array.isNotEmpty ? (array[0] as bool? ?? false) : false,
      dataEvento: array.length > 1 && array[1] != null
          ? (array[1] as Timestamp).toDate()
          : null,
      localizacao: array.length > 2 && array[2] != null
          ? array[2] as GeoPoint
          : localizacaoPadrao,
    );
  }

  /// progresso inicial (não completado, data em branco, localização fixa)
  factory MundoProgresso.inicial({
    required GeoPoint localizacao,
  }) {
    return MundoProgresso(
      completado: false,
      dataEvento: null,
      localizacao: localizacao,
    );
  }

  /// marca como completo com a data atual
  MundoProgresso completarComDataAtual() {
    return MundoProgresso(
      completado: true,
      dataEvento: DateTime.now(),
      localizacao: this.localizacao,
    );
  }
}


class Personagem {
  final String? id;
  final String nome;
  final DateTime? criadoEm;

  // progresso de cada mundo
  final MundoProgresso barPirata;
  final MundoProgresso conservatorioDiminuto;
  final MundoProgresso estacionamentoCaotico;
  final MundoProgresso fazendaValeDourado;
  final MundoProgresso terrasen;

  Personagem({
    this.id,
    required this.nome,
    this.criadoEm,
    MundoProgresso? barPirata,
    MundoProgresso? conservatorioDiminuto,
    MundoProgresso? estacionamentoCaotico,
    MundoProgresso? fazendaValeDourado,
    MundoProgresso? terrasen,
  })  : barPirata = barPirata ?? _progressoInicialBarPirata(),
        conservatorioDiminuto = conservatorioDiminuto ?? _progressoInicialConservatorio(),
        estacionamentoCaotico = estacionamentoCaotico ?? _progressoInicialEstacionamento(),
        fazendaValeDourado = fazendaValeDourado ?? _progressoInicialFazendaValeDourado(),
        terrasen = terrasen ?? _progressoInicialTerrasen();

  // LOCALIZAÇÕES FIXAS de cada mundo
  static const GeoPoint _localBarPirata = GeoPoint(-22.83347, -47.04992);
  static const GeoPoint _localConservatorio = GeoPoint(-22.83239, -47.05127);
  static const GeoPoint _localEstacionamento = GeoPoint(-22.8344, -47.05177);
  static const GeoPoint _localFazenda = GeoPoint(-22.83319, -47.05261);
  static const GeoPoint _localTerrasen = GeoPoint(-22.83365, -47.05197);

  static MundoProgresso _progressoInicialBarPirata() => MundoProgresso.inicial(
        localizacao: _localBarPirata,
      );

  static MundoProgresso _progressoInicialConservatorio() => MundoProgresso.inicial(
        localizacao: _localConservatorio,
      );

  static MundoProgresso _progressoInicialEstacionamento() => MundoProgresso.inicial(
        localizacao: _localEstacionamento,
      );

  static MundoProgresso _progressoInicialFazendaValeDourado() => MundoProgresso.inicial(
        localizacao: _localFazenda,
      );

  static MundoProgresso _progressoInicialTerrasen() => MundoProgresso.inicial(
        localizacao: _localTerrasen,
      );

  /// converte para map para salvar no firestore
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'bar_pirata': barPirata.toArray(),
      'conservatorio_diminuto': conservatorioDiminuto.toArray(),
      'estacionamento_caotico': estacionamentoCaotico.toArray(),
      'fazenda_vale_dourado': fazendaValeDourado.toArray(),
      'terrasen': terrasen.toArray(),
    };
  }

  /// reconstrói um personagem a partir de um documento do Firestore
  factory Personagem.fromMap(Map<String, dynamic> map, {String? id}) {
    List<dynamic> _arr(String key) =>
        (map[key] as List<dynamic>?) ?? [false, null, null];

    return Personagem(
      id: id,
      nome: map['nome'] as String? ?? '',
      criadoEm: map['criadoEm'] != null
          ? (map['criadoEm'] as Timestamp).toDate()
          : null,
      barPirata: MundoProgresso.fromArray(
        _arr('bar_pirata'),
        localizacaoPadrao: _localBarPirata,
      ),
      conservatorioDiminuto: MundoProgresso.fromArray(
        _arr('conservatorio_diminuto'),
        localizacaoPadrao: _localConservatorio,
      ),
      estacionamentoCaotico: MundoProgresso.fromArray(
        _arr('estacionamento_caotico'),
        localizacaoPadrao: _localEstacionamento,
      ),
      fazendaValeDourado: MundoProgresso.fromArray(
        _arr('fazenda_vale_dourado'),
        localizacaoPadrao: _localFazenda,
      ),
      terrasen: MundoProgresso.fromArray(
        _arr('terrasen'),
        localizacaoPadrao: _localTerrasen,
      ),
    );
  }

  /// cria uma cópia com campos substituídos
  Personagem copyWith({
    String? id,
    String? nome,
    DateTime? criadoEm,
    MundoProgresso? barPirata,
    MundoProgresso? conservatorioDiminuto,
    MundoProgresso? estacionamentoCaotico,
    MundoProgresso? fazendaValeDourado,
    MundoProgresso? terrasen,
  }) {
    return Personagem(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      criadoEm: criadoEm ?? this.criadoEm,
      barPirata: barPirata ?? this.barPirata,
      conservatorioDiminuto: conservatorioDiminuto ?? this.conservatorioDiminuto,
      estacionamentoCaotico: estacionamentoCaotico ?? this.estacionamentoCaotico,
      fazendaValeDourado: fazendaValeDourado ?? this.fazendaValeDourado,
      terrasen: terrasen ?? this.terrasen,
    );
  }
}