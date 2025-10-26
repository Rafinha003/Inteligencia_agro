import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inteligencia_agro/Controller/tela-listagem/TelaListagemController.dart';

class TelaListagemDetalhe extends StatefulWidget {
  final String itemId; // ID do item clicado

  const TelaListagemDetalhe({Key? key, required this.itemId}) : super(key: key);

  @override
  State<TelaListagemDetalhe> createState() => _TelaListagemDetalheState();
}

class _TelaListagemDetalheState extends State<TelaListagemDetalhe> {
  final TelaListagemController _controller = TelaListagemController();

  Map<String, dynamic>? itemData;
  Map<String, dynamic>? usuarioData;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final resultado = await _controller.obterItemComUsuario(widget.itemId);
    if (mounted) {
      setState(() {
        itemData = resultado?['item'];
        usuarioData = resultado?['usuario'];
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF045006)),
        ),
      );
    }

    if (itemData == null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(
          child: Text("Item não encontrado."),
        ),
      );
    }

    final nome = itemData!['nome'] ?? 'Sem nome';
    final descricao = itemData!['descricao'] ?? 'Sem descrição';
    final valor = itemData!['valor'];
    final ano = itemData!['ano'] ?? '-';
    final tipo = itemData!['tipoTransacao'] ?? '-';
    final qtdDias = itemData!['quantidadeDias'];
    final imagemData = itemData!['imagem'];

    final nomeUsuario = usuarioData?['nome'] ?? 'Usuário não informado';
    final telefoneUsuario = usuarioData?['telefone'] ?? 'Telefone não informado';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 📸 Imagem do produto
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildItemImage(imagemData),
            ),
            const SizedBox(height: 20),

            // 🏷️ Nome do item
            Text(
              nome,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C1C1C),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // 🧾 Descrição
            Text(
              descricao,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // 📋 Informações adicionais
            _infoTile("Ano", ano.toString()),
            _infoTile("Tipo de Transação", tipo.toString()),

            if (valor != null && valor.toString().isNotEmpty)
              _infoTile("Valor", "R\$ $valor"),

            if (qtdDias != null && qtdDias.toString().isNotEmpty)
              _infoTile("Quantidade de dias", qtdDias.toString()),

            const SizedBox(height: 30),
            const Divider(thickness: 1.5),
            const SizedBox(height: 10),

            // 👤 Informações do dono do item
            const Text(
              "Informações do anunciante",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF045006),
              ),
            ),
            const SizedBox(height: 10),
            _infoTile("Nome", nomeUsuario),
            _infoTile("Telefone", telefoneUsuario),

            const SizedBox(height: 30),

            // 🟩 Botões de ação
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  /// 🧱 AppBar padrão
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        "Detalhes do Item",
        style: TextStyle(color: Colors.white, fontSize: 22),
      ),
      centerTitle: true,
      backgroundColor: const Color(0xFF045006),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  /// 🖼️ Exibe imagem a partir de URL, Base64 ou ícone padrão
  Widget _buildItemImage(dynamic imagemData) {
    const double altura = 220;

    if (imagemData == null || imagemData.toString().isEmpty) {
      return Container(
        width: double.infinity,
        height: altura,
        color: const Color(0xFF3FAF47),
        child: const Icon(Icons.image_not_supported, color: Colors.white, size: 60),
      );
    }

    if (imagemData.toString().startsWith('http')) {
      return Image.network(imagemData, width: double.infinity, height: altura, fit: BoxFit.cover);
    }

    try {
      final decodedBytes = base64Decode(imagemData);
      return Image.memory(decodedBytes, width: double.infinity, height: altura, fit: BoxFit.cover);
    } catch (e) {
      return Container(
        width: double.infinity,
        height: altura,
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, color: Colors.grey, size: 60),
      );
    }
  }

  /// 🔹 Widget auxiliar para exibir informações
  Widget _infoTile(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }

  /// 🟩 Botões de ação (sem funcionalidade por enquanto)
  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // futuramente: enviar proposta
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF045006),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              "Enviar Proposta",
              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // futuramente: abrir chat
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF045006), width: 2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
