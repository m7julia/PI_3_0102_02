import 'package:cloud_firestore/cloud_firestore.dart';

class NivelService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Atualizar o campo complete do nivel_maju para true
  static Future<void> completarNivelMaju() async {
    try {
      // Você pode ajustar o documento ID conforme sua estrutura
      // Exemplo: nivel_maju/{userId} ou nivel_maju/{userId}/progresso
      // Vou assumir que existe um documento com ID 'usuario_atual'
      await _firestore.collection('nivel_maju').doc('usuario_atual').update({
        'complete': true,
        'data_conclusao': FieldValue.serverTimestamp(),
      });
      print('Nível Maju completado com sucesso!');
    } catch (e) {
      print('Erro ao salvar progresso: $e');
      // Se o documento não existir, criar um novo
      try {
        await _firestore.collection('nivel_maju').doc('usuario_atual').set({
          'complete': true,
          'data_conclusao': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Erro ao criar documento: $e');
      }
    }
  }
}