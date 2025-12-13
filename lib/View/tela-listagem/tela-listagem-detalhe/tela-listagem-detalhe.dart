import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inteligencia_agro/Controller/tela-listagem/tela-listagem-detalhe-controller.dart';
import 'package:inteligencia_agro/View/Tela-chat/tela-chat-pessoal/chat-pessoal.dart';
import 'package:inteligencia_agro/common/notificacao_tela.dart';

class TelaListagemDetalhe extends StatefulWidget {
  final String itemId;

  const TelaListagemDetalhe({Key? key, required this.itemId}) : super(key: key);

  @override
  State<TelaListagemDetalhe> createState() => _TelaListagemDetalheState();
}

class _TelaListagemDetalheState extends State<TelaListagemDetalhe> {
  final TelaListagemDetalheController _controller = TelaListagemDetalheController();
  bool enviando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: _buildAppBar(),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _controller.carregarDados(widget.itemId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF045006)),
            );
          }

          if (!snapshot.hasData || snapshot.data == null || snapshot.data!['item'] == null) {
            return const Center(child: Text("Item não encontrado."));
          }

          final itemData = snapshot.data!['item'];
          final usuarioData = snapshot.data!['usuario'];

          final nome = itemData['nome'] ?? 'Sem nome';
          final descricao = itemData['descricao'] ?? 'Sem descrição';
          final valor = itemData['valor'];
          final ano = itemData['ano'] ?? '-';
          final tipo = itemData['tipoTransacao'] ?? '-';
          final qtdDias = itemData['quantidadeDias'];
          final imagemData = itemData['imagem'];

          final nomeUsuario = usuarioData?['nome'] ?? 'Usuário não informado';
          final telefoneUsuario = usuarioData?['telefone'] ?? 'Telefone não informado';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildItemImage(imagemData),
                ),
                const SizedBox(height: 20),
                Text(nome, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1C)), textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Text(descricao, style: const TextStyle(fontSize: 16, color: Colors.black87), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                _infoTile("Ano", ano.toString()),
                _infoTile("Tipo de Transação", tipo.toString()),
                if (valor != null && valor.toString().isNotEmpty) _infoTile("Valor", "R\$ $valor"),
                if (qtdDias != null && qtdDias.toString().isNotEmpty) _infoTile("Quantidade de dias", qtdDias.toString()),
                const SizedBox(height: 30),
                const Divider(thickness: 1.5),
                const SizedBox(height: 10),
                const Text("Informações do anunciante", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF045006))),
                const SizedBox(height: 10),
                _infoTile("Nome", nomeUsuario),
                _infoTile("Telefone", telefoneUsuario),
                const SizedBox(height: 30),
                _buildActionButtons(itemData, usuarioData),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("Detalhes do Item", style: TextStyle(color: Colors.white, fontSize: 22)),
      centerTitle: true,
      backgroundColor: const Color(0xFF045006),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Widget _buildItemImage(dynamic imagemData) {
    const double altura = 220;
    if (imagemData == null || imagemData.toString().isEmpty) {
      return Container(width: double.infinity, height: altura, color: const Color(0xFF3FAF47), child: const Icon(Icons.image_not_supported, color: Colors.white, size: 60));
    }
    if (imagemData.toString().startsWith('http')) {
      return Image.network(imagemData, width: double.infinity, height: altura, fit: BoxFit.cover);
    }
    try {
      final decodedBytes = base64Decode(imagemData);
      return Image.memory(decodedBytes, width: double.infinity, height: altura, fit: BoxFit.cover);
    } catch (_) {
      return Container(width: double.infinity, height: altura, color: Colors.grey[300], child: const Icon(Icons.broken_image, color: Colors.grey, size: 60));
    }
  }

  Widget _infoTile(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87))]),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> itemData, Map<String, dynamic>? usuarioData) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: enviando
                ? null
                : () async {
                    setState(() => enviando = true);
                    try {
                      await _controller.enviarProposta(
                        uidItem: widget.itemId,
                        uidVendedor: itemData['uidUsuario'],
                      );
                      if (mounted) {
                        mostrarNotificacaoTela(context: context, texto: "Proposta enviada com sucesso!", isErro: false);
                      }
                    } catch (_) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Erro ao enviar proposta.")),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => enviando = false);
                    }
                  },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF045006), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(enviando ? "Enviando..." : "Enviar Proposta", style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              _controller.abrirChat(context, itemData, usuarioData);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF045006), width: 2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Entrar em Contato via Chat",
              style: TextStyle(fontSize: 18, color: Color(0xFF045006), fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
