import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inteligencia_agro/Controller/tela-listagem/TelaListagemController.dart';
import 'package:inteligencia_agro/View/tela-listagem/tela-listagem-detalhe/tela-listagem-detalhe.dart';


class TelaListagem extends StatefulWidget {
  const TelaListagem({Key? key}) : super(key: key);

  @override
  State<TelaListagem> createState() => _TelaListagemState();
}

class _TelaListagemState extends State<TelaListagem> {
  final TelaListagemController _controller = TelaListagemController();
  final TextEditingController _pesquisaController = TextEditingController();
  String filtro = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          "Listagem de Itens",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF045006),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Campo de pesquisa
            TextField(
              controller: _pesquisaController,
              onChanged: (value) {
                setState(() {
                  filtro = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Pesquisar item...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF045006)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 📋 Lista de itens
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _controller.obterTodosItens(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF045006)),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Erro ao carregar itens.",
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final itens = snapshot.data ?? [];

                  final itensFiltrados = itens.where((item) {
                    final nome = (item['nome'] ?? '').toString().toLowerCase();
                    return nome.contains(filtro);
                  }).toList();

                  if (itensFiltrados.isEmpty) {
                    return Center(
                      child: Text(
                        "Nenhum item encontrado.",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: itensFiltrados.length,
                    itemBuilder: (context, index) {
                      final item = itensFiltrados[index];

                      return GestureDetector(
                    onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TelaListagemDetalhe(itemId: item['id']),
                                  ),
                                );
                              },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: _buildItemImage(item['imagem']),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['nome'] ?? "Sem nome",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          color: Color(0xFF1C1C1C),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text("Ano: ${item['ano'] ?? '-'}"),
                                      Text("Tipo: ${item['tipoTransacao'] ?? '-'}"),
                                      if (item['tipoTransacao'] != 'Troca')
                                        Text(
                                          "Valor: R\$ ${item['valor'] ?? '-'}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF3FAF47),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🖼️ Exibe imagem (URL, Base64 ou ícone padrão)
  Widget _buildItemImage(dynamic imagemData) {
    const double tamanho = 90;

    if (imagemData == null || imagemData.toString().isEmpty) {
      return Container(
        width: tamanho,
        height: tamanho,
        color: const Color(0xFF3FAF47),
        child: const Icon(Icons.image_not_supported, color: Colors.white),
      );
    }

    if (imagemData.toString().startsWith('http')) {
      return Image.network(imagemData, width: tamanho, height: tamanho, fit: BoxFit.cover);
    }

    try {
      final decodedBytes = base64Decode(imagemData);
      return Image.memory(decodedBytes, width: tamanho, height: tamanho, fit: BoxFit.cover);
    } catch (e) {
      return Container(
        width: tamanho,
        height: tamanho,
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, color: Colors.grey),
      );
    }
  }
}
