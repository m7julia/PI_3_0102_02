import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/personagem.dart';

class PersonagemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// cria um novo personagem
  Future<String> criarPersonagem(Personagem personagem) async {
    final docRef = await _firestore.collection('personagens').add({
      ...personagem.toMap(),
      'criadoEm': FieldValue.serverTimestamp(), // data do servidor
    });
    return docRef.id;
  }

  /// busca todos os personagens
  Future<List<Personagem>> buscarPersonagens() async {
    final snapshot = await _firestore.collection('personagens').get();
    return snapshot.docs
        .map((doc) => Personagem.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  /// busca personagem por ID
  Future<Personagem?> buscarPorId(String id) async {
    final doc = await _firestore.collection('personagens').doc(id).get();
    if (doc.exists) {
      return Personagem.fromMap(doc.data()!, id: doc.id);
    }
    return null;
  }

  /// atualiza personagem completo
  Future<void> atualizarPersonagem(String id, Personagem personagem) async {
    await _firestore
        .collection('personagens')
        .doc(id)
        .update(personagem.toMap());
  }

  /// marca um mundo como completo (registra a data/hora atual)
  Future<void> completarMundo(String personagemId, String nomeCampo) async {
    final personagem = await buscarPorId(personagemId);
    if (personagem == null) return;

    Personagem atualizado;
    switch (nomeCampo) {
      case 'bar_pirata':
        atualizado = personagem.copyWith(
            barPirata: personagem.barPirata.completarComDataAtual());
        break;
      case 'conservatorio_diminuto':
        atualizado = personagem.copyWith(
            conservatorioDiminuto: personagem.conservatorioDiminuto.completarComDataAtual());
        break;
      case 'estacionamento_caotico':
        atualizado = personagem.copyWith(
            estacionamentoCaotico: personagem.estacionamentoCaotico.completarComDataAtual());
        break;
      case 'fazenda_vale_dourado':
        atualizado = personagem.copyWith(
            fazendaValeDourado: personagem.fazendaValeDourado.completarComDataAtual());
        break;
      case 'terrasen':
        atualizado = personagem.copyWith(
            terrasen: personagem.terrasen.completarComDataAtual());
        break;
      default:
        throw ArgumentError('Campo de mundo desconhecido: $nomeCampo');
    }

    await atualizarPersonagem(personagemId, atualizado);
  }

  /// deleta personagem
  Future<void> deletarPersonagem(String id) async {
    await _firestore.collection('personagens').doc(id).delete();
  }
}