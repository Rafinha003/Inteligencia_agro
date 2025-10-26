import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inteligencia_agro/Controller/Tela-perfil-controller/TelaPerfilController.dart';

class TelaVerMeusItens extends StatefulWidget {
  const TelaVerMeusItens({Key? key}) : super(key: key);

  @override
  State<TelaVerMeusItens> createState() => _TelaVerMeusItensState();
}

class _TelaVerMeusItensState extends State<TelaVerMeusItens> {
  final TelaPerfilController _controller = TelaPerfilController();
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
            const SizedBox(height: 16),

            // ➕ Botão adicionar item
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

            // 📋 Lista de itens
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
                      child: Text("Erro ao carregar itens.", style: TextStyle(color: Colors.red)),
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

                      return Container(
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
                                      item['nome'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: Color(0xFF1C1C1C),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text("Ano: ${item['ano']}"),
                                    Text("Tipo: ${item['tipoTransacao']}"),
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

  // 🖼️ Função auxiliar para imagem
  Widget _buildItemImage(dynamic imagemData) {
    const double tamanho = 90; // imagem maior

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

Future<void> _abrirModalAdicionarItem(BuildContext context) async {
  final nomeController = TextEditingController();
  final anoController = TextEditingController();
  final descricaoController = TextEditingController();
  final valorController = TextEditingController();
  final diasController = TextEditingController();
  String tipoSelecionado = "Venda";
  Uint8List? imagemSelecionada;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final mediaQuery = MediaQuery.of(context);
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: mediaQuery.viewInsets.bottom + 16, // evita o teclado sobrepor
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Indicador superior
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const Center(
                    child: Text(
                      "Adicionar Item",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF045006),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🖼️ Selecionar imagem
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final XFile? imagem =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (imagem != null) {
                        final bytes = await imagem.readAsBytes();
                        setModalState(() => imagemSelecionada = bytes);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[100],
                        image: imagemSelecionada != null
                            ? DecorationImage(
                                image: MemoryImage(imagemSelecionada!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: imagemSelecionada == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add_a_photo,
                                    size: 40, color: Color(0xFF3FAF47)),
                                SizedBox(height: 8),
                                Text(
                                  "Adicionar imagem",
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            )
                          : Stack(
                              children: [
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () =>
                                        setModalState(() => imagemSelecionada = null),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 📝 Campos de texto
                  TextField(
                    controller: nomeController,
                    decoration: InputDecoration(
                      labelText: "Nome do item",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: anoController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Ano",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: descricaoController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: "Descrição",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 🔄 Tipo de transação
                  DropdownButtonFormField<String>(
                    value: tipoSelecionado,
                    decoration: InputDecoration(
                      labelText: "Tipo de Transação",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: "Venda", child: Text("Venda")),
                      DropdownMenuItem(value: "Troca", child: Text("Troca")),
                      DropdownMenuItem(value: "Aluga", child: Text("Aluga")),
                    ],
                    onChanged: (value) =>
                        setModalState(() => tipoSelecionado = value!),
                  ),
                  const SizedBox(height: 12),

                  // 💰 Campo de valor (opcional)
                  if (tipoSelecionado != "Troca")
                    TextField(
                      controller: valorController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Valor",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  if (tipoSelecionado != "Troca") const SizedBox(height: 12),

                  // 📅 Campo de dias (somente se for aluguel)
                  if (tipoSelecionado == "Aluga")
                    TextField(
                      controller: diasController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Quantidade de dias",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  if (tipoSelecionado == "Aluga") const SizedBox(height: 12),

                  // 🔘 Botões
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Cancelar"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final imagemBase64 = imagemSelecionada != null
                                ? base64Encode(imagemSelecionada!)
                                : null;

                            try {
                              await _controller.salvarItem(
                                nome: nomeController.text.trim(),
                                ano: anoController.text.trim(),
                                descricao: descricaoController.text.trim(),
                                tipoTransacao: tipoSelecionado,
                                valor: valorController.text.trim().isEmpty
                                    ? null
                                    : valorController.text.trim(),
                                dias: diasController.text.trim().isEmpty
                                    ? null
                                    : diasController.text.trim(),
                                base64Image: imagemBase64,
                              );

                              Navigator.pop(context);
                              setState(() {}); // atualiza a lista
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Erro ao salvar item: $e")),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3FAF47),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Salvar",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
}
