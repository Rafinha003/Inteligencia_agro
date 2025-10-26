import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inteligencia_agro/Controller/Tela-perfil-controller/TelaPerfilController.dart';


class TelaExibirProposta extends StatefulWidget {
  const TelaExibirProposta({Key? key}) : super(key: key);

  @override
  State<TelaExibirProposta> createState() => _TelaExibirPropostaState();
}

class _TelaExibirPropostaState extends State<TelaExibirProposta> {
  final TextEditingController _pesquisaController = TextEditingController();
  final TelaPerfilController _controller = TelaPerfilController();

  List<Map<String, dynamic>> _propostas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarPropostas();
  }

  Future<void> _carregarPropostas() async {
    setState(() => _carregando = true);
    final propostas = await _controller.obterPropostasDoUsuario();
    setState(() {
      _propostas = propostas;
      _carregando = false;
    });
  }

  Future<void> _atualizarStatus(String propostaId, String status) async {
    await _controller.atualizarStatusProposta(propostaId, status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == 'aceito'
              ? 'Proposta aceita com sucesso!'
              : 'Proposta recusada.',
        ),
        backgroundColor:
            status == 'aceito' ? Colors.green.shade700 : Colors.red.shade700,
      ),
    );
    _carregarPropostas(); // atualiza a lista
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          "Visualizar Propostas",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF045006),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCampoPesquisa(),
            const SizedBox(height: 16),
            Expanded(
              child: _carregando
                  ? const Center(child: CircularProgressIndicator())
                  : _propostas.isEmpty
                      ? const Center(
                          child: Text(
                            "Nenhuma proposta encontrada.",
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _propostas.length,
                          itemBuilder: (context, index) {
                            final proposta = _propostas[index];
                            return _buildCardProposta(proposta);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoPesquisa() {
    return TextField(
      controller: _pesquisaController,
      decoration: InputDecoration(
        hintText: "Pesquisar proposta...",
        prefixIcon: const Icon(Icons.search, color: Color(0xFF045006)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (valor) {
        setState(() {
          _propostas = _propostas
              .where((p) => p['nomeProduto']
                  .toString()
                  .toLowerCase()
                  .contains(valor.toLowerCase()))
              .toList();
        });
      },
    );
  }

  Widget _buildCardProposta(Map<String, dynamic> proposta) {
    final imagem = proposta['imagemItem'];
    final nomeProduto = proposta['nomeItem'] ?? 'Produto';
    final nomeComprador = proposta['nomeComprador'] ?? 'Comprador';
    final telefone = proposta['telefoneComprador'] ?? 'Telefone não informado';
    final propostaId = proposta['idProposta'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildImagemProduto(imagem),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nomeProduto,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1C1C))),
                const SizedBox(height: 4),
                Text(nomeComprador,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black87)),
                Text(telefone,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.check_circle, color: Color(0xFF1E8F2F)),
                iconSize: 30,
                onPressed: () =>
                    _atualizarStatus(propostaId, 'aceito'),
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                iconSize: 30,
                onPressed: () =>
                    _atualizarStatus(propostaId, 'recusado'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagemProduto(dynamic imagemData) {
    const double size = 70;

    if (imagemData == null || imagemData.toString().isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF3FAF47),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.image_not_supported,
            color: Colors.white, size: 35),
      );
    }

    if (imagemData.toString().startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child:
            Image.network(imagemData, width: size, height: size, fit: BoxFit.cover),
      );
    }

    try {
      final decodedBytes = base64Decode(imagemData);
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child:
            Image.memory(decodedBytes, width: size, height: size, fit: BoxFit.cover),
      );
    } catch (e) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child:
            const Icon(Icons.broken_image, color: Colors.grey, size: 35),
      );
    }
  }
}
