import 'package:cloud_firestore/cloud_firestore.dart';

class NivelService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _docId = 'XyZ9wPqR3mNvLkA2bC5dE';

  /// Marca o nível Maju como completo no Firestore.
  /// Chamado quando o jogador conclui o Ligue 3 ou o Jogo da Memória.
  static Future<void> completarNivelMaju() async {
    try {
      await _firestore.collection('nivel_maju').doc(_docId).update({
        'complete': true,
        'data_conclusao': FieldValue.serverTimestamp(),
      });
      debugLog('Nível Maju completado com sucesso!');
    } catch (e) {
      debugLog('Erro ao atualizar progresso: $e');
      // Fallback: cria o documento caso não exista
      try {
        await _firestore.collection('nivel_maju').doc(_docId).set({
          'complete': true,
          'data_conclusao': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e2) {
        debugLog('Erro ao criar documento de progresso: $e2');
      }
    }
  }

  /// Verifica se o nível Maju já está completo.
  static Future<bool> nivelMajuCompleto() async {
    try {
      final doc =
          await _firestore.collection('nivel_maju').doc(_docId).get();
      if (doc.exists) {
        return doc.data()?['complete'] == true;
      }
    } catch (e) {
      debugLog('Erro ao verificar progresso: $e');
    }
    return false;
  }
}

// ignore: prefer_function_declarations_over_variables
final void Function(String) debugLog =
    (msg) => print('[NivelService] $msg'); // ignore: avoid_print