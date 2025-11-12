import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inteligencia_agro/Controller/tela-listagem/TelaListagemController.dart';
import 'package:inteligencia_agro/View/tela-listagem/tela-listagem-detalhe/tela-listagem-detalhe.dart';
import 'package:inteligencia_agro/Controller/ibge/IbgeController.dart'; // 👈 Import do controller IBGE

class TelaListagem extends StatefulWidget {
  const TelaListagem({Key? key}) : super(key: key);

  @override
  State<TelaListagem> createState() => _TelaListagemState();
}

class _TelaListagemState extends State<TelaListagem> {
  final TelaListagemController _controller = TelaListagemController();
  final IbgeController _ibgeController = IbgeController(); // 👈 Instância IBGE
  final TextEditingController _pesquisaController = TextEditingController();

  String filtro = "";
  String? filtroTipo;
  String? filtroAno;
  double? filtroValorMax;
  String? filtroEstado;
  String? filtroCidade;

  List<Map<String, dynamic>> estados = [];
  List<String> cidades = [];

  @override
  void initState() {
    super.initState();
    _carregarEstados();
  }

  Future<void> _carregarEstados() async {
    try {
      final lista = await _ibgeController.buscarEstados();
      setState(() => estados = lista);
    } catch (e) {
      debugPrint("Erro ao carregar estados: $e");
    }
  }

  Future<void> _carregarCidades(String uf) async {
    try {
      final lista = await _ibgeController.buscarCidades(uf);
      setState(() => cidades = lista);
    } catch (e) {
      debugPrint("Erro ao carregar cidades: $e");
    }
  }

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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
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
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _abrirBuscaPersonalizada,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF045006),
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.tune, color: Colors.white),
                ),
              ],
            ),

            // 🏷️ Chips de filtros ativos
            if (filtroAno != null ||
                filtroTipo != null ||
                filtroValorMax != null ||
                filtroEstado != null ||
                filtroCidade != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (filtroAno?.isNotEmpty ?? false)
                      Chip(
                        label: Text("Ano: $filtroAno"),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () => setState(() => filtroAno = null),
                      ),
                    if (filtroTipo?.isNotEmpty ?? false)
                      Chip(
                        label: Text("Tipo: $filtroTipo"),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () => setState(() => filtroTipo = null),
                      ),
                    if (filtroValorMax != null)
                      Chip(
                        label: Text("Valor ≤ R\$ ${filtroValorMax!.toStringAsFixed(2)}"),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () => setState(() => filtroValorMax = null),
                      ),
                    if (filtroEstado?.isNotEmpty ?? false)
                      Chip(
                        label: Text("Estado: $filtroEstado"),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () => setState(() {
                          filtroEstado = null;
                          filtroCidade = null;
                        }),
                      ),
                    if (filtroCidade?.isNotEmpty ?? false)
                      Chip(
                        label: Text("Cidade: $filtroCidade"),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () => setState(() => filtroCidade = null),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

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
                      child: Text("Erro ao carregar itens.", style: TextStyle(color: Colors.red)),
                    );
                  }

                  final itens = snapshot.data ?? [];

                  final itensFiltrados = itens.where((item) {
                    final nome = (item['nome'] ?? '').toString().toLowerCase();
                    final tipo = (item['tipoTransacao'] ?? '').toString().toLowerCase();
                    final ano = (item['ano'] ?? '').toString();
                    final estado = (item['estado'] ?? '').toString();
                    final cidade = (item['cidade'] ?? '').toString();

                    final valorString = item['valor']?.toString();
                    final valor = valorString != null && valorString.isNotEmpty
                        ? double.tryParse(valorString)
                        : null;

                    bool correspondePesquisa = nome.contains(filtro);
                    bool correspondeTipo = filtroTipo == null || filtroTipo!.isEmpty || tipo == filtroTipo!.toLowerCase();
                    bool correspondeAno = filtroAno == null || filtroAno!.isEmpty || ano == filtroAno;
                    bool correspondeValor = filtroValorMax == null ? true : (valor != null && valor <= filtroValorMax!);
                    bool correspondeEstado = filtroEstado == null || filtroEstado!.isEmpty || estado == filtroEstado;
                    bool correspondeCidade = filtroCidade == null || filtroCidade!.isEmpty || cidade == filtroCidade;

                    return correspondePesquisa &&
                        correspondeTipo &&
                        correspondeAno &&
                        correspondeValor &&
                        correspondeEstado &&
                        correspondeCidade;
                  }).toList();

                  if (itensFiltrados.isEmpty) {
                    return const Center(
                      child: Text(
                        "Nenhum item encontrado.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
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
                              builder: (context) =>
                                  TelaListagemDetalhe(itemId: item['id']),
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

  // 🧩 Modal de busca personalizada
  void _abrirBuscaPersonalizada() {
    String? anoTemp = filtroAno;
    String? tipoTemp = filtroTipo;
    double? valorTemp = filtroValorMax;
    String? estadoTemp = filtroEstado;
    String? cidadeTemp = filtroCidade;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Filtros personalizados",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Ano
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Ano",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => anoTemp = v,
                  controller: TextEditingController(text: anoTemp),
                ),
                const SizedBox(height: 20),

                // Tipo
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Tipo de Transação",
                    border: OutlineInputBorder(),
                  ),
                  value: tipoTemp,
                  items: const [
                    DropdownMenuItem(value: "venda", child: Text("Venda")),
                    DropdownMenuItem(value: "aluga", child: Text("Aluga")),
                    DropdownMenuItem(value: "troca", child: Text("Troca")),
                  ],
                  onChanged: (v) => tipoTemp = v,
                ),
                const SizedBox(height: 20),

                // Valor máximo
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Valor máximo (R\$)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => valorTemp = double.tryParse(v),
                  controller: TextEditingController(
                      text: valorTemp != null ? valorTemp.toString() : ""),
                ),
                const SizedBox(height: 20),

                // Estado
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Estado",
                    border: OutlineInputBorder(),
                  ),
                  value: estadoTemp,
                  items: estados
                      .map((e) => DropdownMenuItem(
                            value: e['sigla'] as String,
                            child: Text(e['nome']),
                          ))
                      .toList(),
                  onChanged: (v) async {
                    estadoTemp = v;
                    cidadeTemp = null;
                    if (v != null) {
                      await _carregarCidades(v);
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Cidade
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Cidade",
                    border: OutlineInputBorder(),
                  ),
                  value: cidadeTemp,
                  items: cidades
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ))
                      .toList(),
                  onChanged: (v) => cidadeTemp = v,
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        filtroAno = anoTemp;
                        filtroTipo = tipoTemp;
                        filtroValorMax = valorTemp;
                        filtroEstado = estadoTemp;
                        filtroCidade = cidadeTemp;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF045006),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Aplicar filtros",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
