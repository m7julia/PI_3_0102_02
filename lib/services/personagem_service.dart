import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/personagem.dart';

class PersonagemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Cria um novo personagem usando o UID do usuário logado como ID do documento
  Future<String> criarPersonagem(Personagem personagem) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não logado');

    await _firestore.collection('personagens').doc(uid).set({
      ...personagem.toMap(),
      'criadoEm': FieldValue.serverTimestamp(),
    });

    return uid;
  }

  /// Busca o personagem do jogador atualmente logado
  Future<Personagem?> buscarPersonagemAtual() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return buscarPorId(uid);
  }

  /// Busca todos os personagens
  Future<List<Personagem>> buscarPersonagens() async {
    final snapshot = await _firestore.collection('personagens').get();
    return snapshot.docs
        .map((doc) => Personagem.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  /// Busca personagem por ID
  Future<Personagem?> buscarPorId(String id) async {
    final doc = await _firestore.collection('personagens').doc(id).get();
    if (doc.exists) {
      return Personagem.fromMap(doc.data()!, id: doc.id);
    }
    return null;
  }

  /// Atualiza personagem completo
  Future<void> atualizarPersonagem(String id, Personagem personagem) async {
    await _firestore
        .collection('personagens')
        .doc(id)
        .update(personagem.toMap());
  }

  /// Marca um mundo como completo (registra a data/hora atual)
  Future<void> completarMundo(String personagemId, String nomeCampo) async {
    final personagem = await buscarPorId(personagemId);
    if (personagem == null) return;

    Personagem atualizado;
    switch (nomeCampo) {
      case 'estacionamento_caotico':
        atualizado = personagem.copyWith(
          estacionamentoCaotico: personagem.estacionamentoCaotico
              .completarComDataAtual(),
        );
        break;
      case 'terrasen':
        atualizado = personagem.copyWith(
          terrasen: personagem.terrasen.completarComDataAtual(),
        );
        break;
      case 'conservatorio_diminuto':
        atualizado = personagem.copyWith(
          conservatorioDiminuto: personagem.conservatorioDiminuto
              .completarComDataAtual(),
        );
        break;
      case 'fazenda_vale_dourado':
        atualizado = personagem.copyWith(
          fazendaValeDourado: personagem.fazendaValeDourado
              .completarComDataAtual(),
        );
        break;
      case 'bar_pirata':
        atualizado = personagem.copyWith(
          barPirata: personagem.barPirata.completarComDataAtual(),
        );
        break;
      default:
        throw ArgumentError('Campo de mundo desconhecido: $nomeCampo');
    }

    await atualizarPersonagem(personagemId, atualizado);
  }

  /// Deleta personagem
  Future<void> deletarPersonagem(String id) async {
    await _firestore.collection('personagens').doc(id).delete();
  }
}
