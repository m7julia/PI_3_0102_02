import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NivelService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Resolve o ID do personagem ──────────────────────────────────────────

  /// Retorna o ID do personagem atual.
  /// Prioriza o valor salvo em SharedPreferences; se não existir, busca o
  /// personagem mais recente da coleção.
  static Future<String?> _resolverPersonagemId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idSalvo = prefs.getString('personagemAtualId');

      if (idSalvo != null) {
        final doc = await _firestore
            .collection('personagens')
            .doc(idSalvo)
            .get();
        if (doc.exists) return idSalvo;
      }

      // Fallback: personagem mais recente
      final snapshot = await _firestore
          .collection('personagens')
          .orderBy('criadoEm', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) return snapshot.docs.first.id;
    } catch (e) {
      _log('Erro ao resolver personagem: $e');
    }
    return null;
  }

  // ─── Completar nível ─────────────────────────────────────────────────────

  /// Marca a Fazenda Vale-Dourado como concluída no documento do personagem.
  /// Atualiza o array [true, Timestamp, GeoPoint] no padrão do projeto.
  static Future<void> completarNivelMaju() async {
    final personagemId = await _resolverPersonagemId();

    if (personagemId == null) {
      _log('Nenhum personagem encontrado — progresso não salvo.');
      return;
    }

    try {
      await _firestore
          .collection('personagens')
          .doc(personagemId)
          .update({
        'fazenda_vale_dourado': [
          true,
          Timestamp.now(),
          const GeoPoint(-22.83319, -47.05261),
        ],
      });
      _log('Fazenda Vale-Dourado completada! (personagem: $personagemId)');
    } catch (e) {
      _log('Erro ao atualizar progresso: $e');
    }
  }

  // ─── Verificar conclusão ─────────────────────────────────────────────────

  /// Retorna true se a Fazenda Vale-Dourado já foi concluída.
  static Future<bool> nivelMajuCompleto() async {
    final personagemId = await _resolverPersonagemId();

    if (personagemId == null) return false;

    try {
      final doc = await _firestore
          .collection('personagens')
          .doc(personagemId)
          .get();

      if (doc.exists) {
        final fazenda = doc.data()?['fazenda_vale_dourado'];
        if (fazenda is List && fazenda.isNotEmpty) {
          return fazenda[0] == true;
        }
      }
    } catch (e) {
      _log('Erro ao verificar progresso: $e');
    }
    return false;
  }

  // ─── Log ─────────────────────────────────────────────────────────────────

  static void _log(String msg) => debugPrint('[NivelService] $msg');
}