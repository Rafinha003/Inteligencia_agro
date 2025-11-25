import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inteligencia_agro/Controller/Ibge/ibgeController.dart';
import 'package:inteligencia_agro/Controller/Tela-perfil-controller/TelaPerfilController.dart';

class TelaVerMeusItens extends StatefulWidget {
  const TelaVerMeusItens({Key? key}) : super(key: key);

  @override
  State<TelaVerMeusItens> createState() => _TelaVerMeusItensState();
}

class _TelaVerMeusItensState extends State<TelaVerMeusItens> {
  final TelaPerfilController _controller = TelaPerfilController();
  final IbgeController _ibgeController = IbgeController();
  final TextEditingController _pesquisaController = TextEditingController();
  String filtro = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          "Meus Itens",
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
            TextField(
              controller: _pesquisaController,
              onChanged: (value) => setState(() => filtro = value.toLowerCase()),
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
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _abrirModalAdicionarItem(context),
                icon: const Icon(Icons.add, color: Colors.white, size: 22),
                label: const Text(
                  "Adicionar Item",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3FAF47),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _controller.obterItensUsuario(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF045006)),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("Erro ao carregar itens.",
                          style: TextStyle(color: Colors.red)),
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
                        onTap: () => _abrirModalAdicionarItem(context, item: item),
                        child: Stack(
                          children: [
                            Container(
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['nome'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              color: Color(0xFF1C1C1C),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text("Ano: ${item['ano']}"),
                                          Text("Estado: ${item['estado'] ?? '-'}"),
                                          Text("Cidade: ${item['cidade'] ?? '-'}"),
                                          Text("Tipo Transação: ${item['tipoTransacao']}"),
                                          Text("Tipo Produto: ${item['tipoProduto']}"),
                                          if (item['tipoTransacao'] != 'Troca')
                                            Text(
                                              "Valor: R\$ ${item['valor']}",
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

                            /// 🔴 BOTÃO DE EXCLUIR (X)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () async {
                                  final confirmar = await showDialog(
                                    context: context,
                                    builder: (ctx) {
                                      return AlertDialog(
                                        title: const Text("Excluir Item"),
                                        content: const Text(
                                            "Tem certeza que deseja excluir este item?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text("Cancelar"),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text(
                                              "Excluir",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirmar == true) {
                                    await _controller.excluirItem(item['id']);
                                    setState(() {});
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.85),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            )
                          ],
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

    try {
      final decodedBytes = base64Decode(imagemData);
      return Image.memory(decodedBytes,
          width: tamanho, height: tamanho, fit: BoxFit.cover);
    } catch (e) {
      return Container(
        width: tamanho,
        height: tamanho,
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, color: Colors.grey),
      );
    }
  }

  // 🔽 mantém seu modal igual — não alterei nada
  Future<void> _abrirModalAdicionarItem(BuildContext context,
      {Map<String, dynamic>? item}) async {
    // (todo o código do modal permanece igual)
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
