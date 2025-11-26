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

  Future<void> _abrirModalAdicionarItem(BuildContext context, {Map<String, dynamic>? item}) async {
  final nomeController = TextEditingController(text: item?['nome'] ?? '');
  final anoController = TextEditingController(text: item?['ano'] ?? '');
  final descricaoController = TextEditingController(text: item?['descricao'] ?? '');
  final valorController = TextEditingController(text: item?['valor'] ?? '');
  final diasController = TextEditingController(text: item?['quantidadeDias'] ?? '');
  String tipoSelecionado = item?['tipoTransacao'] ?? "Venda";
  String tipoProdutoSelecionado = item?['tipoProduto'] ?? "Máquina";
  String? estadoSelecionado = item?['estado'];
  String? cidadeSelecionada = item?['cidade'];
  List<Map<String, dynamic>> estados = [];
  List<String> cidades = [];
  Uint8List? imagemSelecionada = item?['imagem'] != null && item?['imagem'] != ''
      ? base64Decode(item!['imagem'])
      : null;

  String mensagemErro = ""; // Mensagem de erro dentro da modal

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
          Future<void> carregarEstados() async {
            estados = await _ibgeController.buscarEstados();
            setModalState(() {});
          }

          Future<void> carregarCidades(String uf) async {
            cidades = await _ibgeController.buscarCidades(uf);
            setModalState(() {});
          }

          if (estados.isEmpty) carregarEstados();

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
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
                  Text(item == null ? "Adicionar Item" : "Editar Item",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF045006))),
                  const SizedBox(height: 20),

                  // Mensagem de erro dentro da modal
                  if (mensagemErro.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        mensagemErro,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),

                  // IMAGEM
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);
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
                                Icon(Icons.add_a_photo, size: 40, color: Color(0xFF3FAF47)),
                                SizedBox(height: 8),
                                Text("Adicionar imagem", style: TextStyle(color: Colors.black54)),
                              ],
                            )
                          : Stack(
                              children: [
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => setModalState(() => imagemSelecionada = null),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(Icons.close,
                                          color: Colors.white, size: 18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Campos de texto
                  _buildTextField("Nome do item", nomeController),
                  const SizedBox(height: 12),
                  _buildTextField("Ano", anoController, keyboard: TextInputType.number),
                  const SizedBox(height: 12),
                  _buildTextField("Descrição", descricaoController, maxLines: 2),
                  const SizedBox(height: 12),

                  // Dropdown ESTADO
                  DropdownButtonFormField<String>(
                    value: estadoSelecionado,
                    decoration: _dropdownDecoration("Estado"),
                    items: estados
                        .map((e) => DropdownMenuItem(
                              value: e['sigla'] as String,
                              child: Text(e['nome'] as String),
                            ))
                        .toList(),
                    onChanged: (value) async {
                      estadoSelecionado = value;
                      cidadeSelecionada = null;
                      cidades.clear();
                      await carregarCidades(value!);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 12),

                  // Dropdown CIDADE
                  DropdownButtonFormField<String>(
                    value: cidadeSelecionada,
                    decoration: _dropdownDecoration("Cidade"),
                    items: cidades
                        .map((cidade) => DropdownMenuItem(
                              value: cidade,
                              child: Text(cidade),
                            ))
                        .toList(),
                    onChanged: (value) => setModalState(() => cidadeSelecionada = value),
                  ),
                  const SizedBox(height: 12),

                  // Dropdown Tipo de Transação
                  DropdownButtonFormField<String>(
                    value: tipoSelecionado,
                    decoration: _dropdownDecoration("Tipo de Transação"),
                    items: const [
                      DropdownMenuItem(value: "Venda", child: Text("Venda")),
                      DropdownMenuItem(value: "Troca", child: Text("Troca")),
                      DropdownMenuItem(value: "Aluga", child: Text("Aluga")),
                    ],
                    onChanged: (value) => setModalState(() => tipoSelecionado = value!),
                  ),
                  const SizedBox(height: 12),

                  // Dropdown Tipo de Produto
                  DropdownButtonFormField<String>(
                    value: tipoProdutoSelecionado,
                    decoration: _dropdownDecoration("Tipo de Produto"),
                    items: const [
                      DropdownMenuItem(value: "Máquina", child: Text("Máquina")),
                      DropdownMenuItem(value: "Insumo", child: Text("Insumo")),
                      DropdownMenuItem(value: "Equipamento", child: Text("Equipamento")),
                    ],
                    onChanged: (value) => setModalState(() => tipoProdutoSelecionado = value!),
                  ),
                  const SizedBox(height: 12),

                  // Valor e Dias
                  if (tipoSelecionado != "Troca")
                    _buildTextField("Valor", valorController, keyboard: TextInputType.number),
                  if (tipoSelecionado == "Aluga") const SizedBox(height: 12),
                  if (tipoSelecionado == "Aluga")
                    _buildTextField("Quantidade de dias", diasController,
                        keyboard: TextInputType.number),
                  const SizedBox(height: 20),

                  // Botão SALVAR
                  ElevatedButton(
                    onPressed: () async {
                      if (nomeController.text.trim().isEmpty ||
                          anoController.text.trim().isEmpty ||
                          descricaoController.text.trim().isEmpty ||
                          tipoSelecionado.isEmpty ||
                          tipoProdutoSelecionado.isEmpty ||
                          imagemSelecionada == null ||
                          estadoSelecionado == null ||
                          cidadeSelecionada == null ||
                          (tipoSelecionado != "Troca" &&
                              valorController.text.trim().isEmpty) ||
                          (tipoSelecionado == "Aluga" &&
                              diasController.text.trim().isEmpty)) {
                        setModalState(() => mensagemErro = "Todos os campos devem ser preenchidos.");
                        return;
                      }

                      try {
                        final imagemBase64 = base64Encode(imagemSelecionada!);

                        await _controller.salvarItem(
                          nome: nomeController.text.trim(),
                          ano: anoController.text.trim(),
                          descricao: descricaoController.text.trim(),
                          tipoTransacao: tipoSelecionado,
                          tipoProduto: tipoProdutoSelecionado,
                          valor: valorController.text.trim(),
                          dias: diasController.text.trim(),
                          base64Image: imagemBase64,
                          estado: estadoSelecionado,
                          cidade: cidadeSelecionada,
                          itemId: item?['id'],
                        );

                        Navigator.pop(context);
                        setState(() {});
                      } catch (e) {
                        setModalState(() => mensagemErro = e.toString());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3FAF47),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Salvar", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
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
