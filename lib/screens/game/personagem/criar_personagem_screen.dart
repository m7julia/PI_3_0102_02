import 'package:flutter/material.dart';
import '../../../services/personagem_service.dart';
import '../../../models/personagem.dart';

class CriarPersonagemScreen extends StatefulWidget {
  const CriarPersonagemScreen({super.key});

  @override
  State<CriarPersonagemScreen> createState() => _CriarPersonagemScreenState();
}

class _CriarPersonagemScreenState extends State<CriarPersonagemScreen> {
  final TextEditingController nomeController = TextEditingController();

  Future<void> salvarPersonagem() async {
    final nome = nomeController.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um nome para o personagem')),
      );
      return;
    }

    try {
      final service = PersonagemService();

      final personagem = Personagem(nome: nome, vidaAtual: 100, vidaMax: 100);

      await service.criarPersonagem(personagem);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personagem criado com sucesso!')),
      );

      nomeController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Personagem')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Crie seu personagem',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do personagem',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: salvarPersonagem,
              child: const Text('Criar personagem'),
            ),
          ],
        ),
      ),
    );
  }
}
