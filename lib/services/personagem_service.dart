import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/personagem.dart';

class PersonagemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // criar o  personagem
  Future<void> criarPersonagem(Personagem personagem) async {
    await _firestore.collection('personagens').add({
      ...personagem.toMap(),
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  // busca por todos os personagens
  Future<List<Personagem>> buscarPersonagens() async {
    final snapshot = await _firestore.collection('personagens').get();

    return snapshot.docs.map((doc) => Personagem.fromMap(doc.data())).toList();
  }

  // busca por id (colocar uma busca por id futuramente)
  Future<Personagem?> buscarPorId(String id) async {
    final doc = await _firestore.collection('personagens').doc(id).get();

    if (doc.exists) {
      return Personagem.fromMap(doc.data()!);
    }

    return null;
  }

  // atualiza o personagem
  Future<void> atualizarPersonagem(String id, Personagem personagem) async {
    await _firestore
        .collection('personagens')
        .doc(id)
        .update(personagem.toMap());
  }

  // deleta caso necessario
  Future<void> deletarPersonagem(String id) async {
    await _firestore.collection('personagens').doc(id).delete();
  }
}
