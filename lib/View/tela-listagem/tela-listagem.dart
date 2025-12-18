import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inteligencia_agro/Controller/tela-listagem/tela-listagem-controller.dart';
import 'package:inteligencia_agro/Model/ListagemModel.dart';
import 'package:inteligencia_agro/View/tela-listagem/tela-listagem-detalhe/tela-listagem-detalhe.dart';
import 'package:inteligencia_agro/Controller/ibge/IbgeController.dart';
import 'package:inteligencia_agro/View/tela-login/tela-login.dart';
import 'package:inteligencia_agro/common/notificacao_tela.dart';

class TelaListagem extends StatefulWidget {
  const TelaListagem({Key? key}) : super(key: key);

  @override
  State<TelaListagem> createState() => _TelaListagemState();
}

class _TelaListagemState extends State<TelaListagem> {
  final TelaListagemController _controller = TelaListagemController();
  final IbgeController _ibgeController = IbgeController();
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
    } catch (_) {
      mostrarNotificacaoTela(
        context: context,
        texto: "Erro ao carregar estados",
        isErro: true,
      );
    }
  }

  Future<void> _carregarCidades(String uf) async {
    try {
      final lista = await _ibgeController.buscarCidades(uf);
      setState(() => cidades = lista);
    } catch (_) {
      mostrarNotificacaoTela(
        context: context,
        texto: "Erro ao carregar cidades",
        isErro: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          _buildHeader(),
          if (_temFiltrosAtivos())
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _buildChipsFiltros(),
              ),
            ),
          Expanded(child: _buildLista()),
        ],
      ),
    );
  }

  // 🔹 HEADER PADRÃO CHAT COM BOTÃO VOLTAR
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 56, bottom: 24),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF045006), Color(0xFF3FAF47)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TelaLogin(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Listagem de Itens",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildPesquisa()),
                const SizedBox(width: 10),
                _buildBotaoFiltro(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔍 PESQUISA
  Widget _buildPesquisa() {
    return TextField(
      controller: _pesquisaController,
      onChanged: (value) =>
          setState(() => filtro = value.toLowerCase()),
      decoration: InputDecoration(
        hintText: "Pesquisar item...",
        prefixIcon: const Icon(Icons.search, color: Color(0xFF045006)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // 🎛 BOTÃO FILTRO
  Widget _buildBotaoFiltro() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _abrirBuscaPersonalizada,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.tune, color: Color(0xFF045006)),
      ),
    );
  }

  // 📋 LISTA
  Widget _buildLista() {
    return FutureBuilder<List<ListagemModel>>(
      future: _controller
          .obterTodosItens()
          .then((l) => l.map(ListagemModel.fromMap).toList()),
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
          return item.nome.toLowerCase().contains(filtro) &&
              (filtroTipo == null ||
                  item.tipoTransacao.toLowerCase() ==
                      filtroTipo!.toLowerCase()) &&
              (filtroAno == null || item.ano == filtroAno) &&
              (filtroValorMax == null ||
                  (item.valor != null &&
                      item.valor! <= filtroValorMax!)) &&
              (filtroEstado == null || item.estado == filtroEstado) &&
              (filtroCidade == null || item.cidade == filtroCidade);
        }).toList();

        if (itensFiltrados.isEmpty) {
          return const Center(
            child: Text(
              "Nenhum item encontrado",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          itemCount: itensFiltrados.length,
          itemBuilder: (_, index) =>
              _buildItem(itensFiltrados[index]),
        );
      },
    );
  }

  // 🧱 CARD ITEM
  Widget _buildItem(ListagemModel item) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TelaListagemDetalhe(itemId: item.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildItemImage(item.imagem),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text("Ano: ${item.ano}",
                      style: const TextStyle(color: Colors.grey)),
                  Text("Tipo: ${item.tipoTransacao}",
                      style: const TextStyle(color: Colors.grey)),
                  if (item.tipoTransacao.toLowerCase() != 'troca')
                    Text(
                      "R\$ ${item.valor?.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Color(0xFF3FAF47),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // 🖼 IMAGEM
  Widget _buildItemImage(String? imagemData) {
    const double size = 70;

    Widget imagem;
    if (imagemData == null || imagemData.isEmpty) {
      imagem = const Icon(Icons.image, color: Colors.white);
    } else if (imagemData.startsWith('http')) {
      imagem = Image.network(imagemData, fit: BoxFit.cover);
    } else {
      try {
        imagem = Image.memory(
          base64Decode(imagemData),
          fit: BoxFit.cover,
        );
      } catch (_) {
        imagem = const Icon(Icons.broken_image, color: Colors.white);
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF3FAF47),
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      clipBehavior: Clip.antiAlias,
      child: imagem,
    );
  }

  bool _temFiltrosAtivos() =>
      filtroAno != null ||
      filtroTipo != null ||
      filtroValorMax != null ||
      filtroEstado != null ||
      filtroCidade != null;

  List<Widget> _buildChipsFiltros() {
    return [
      if (filtroAno != null)
        _chip("Ano", filtroAno!, () => setState(() => filtroAno = null)),
      if (filtroTipo != null)
        _chip("Tipo", filtroTipo!, () => setState(() => filtroTipo = null)),
      if (filtroValorMax != null)
        _chip(
          "Valor",
          "≤ R\$ ${filtroValorMax!.toStringAsFixed(2)}",
          () => setState(() => filtroValorMax = null),
        ),
      if (filtroEstado != null)
        _chip("Estado", filtroEstado!,
            () => setState(() => filtroEstado = null)),
      if (filtroCidade != null)
        _chip("Cidade", filtroCidade!,
            () => setState(() => filtroCidade = null)),
    ];
  }

  Widget _chip(String label, String value, VoidCallback onDelete) {
    return Chip(
      label: Text("$label: $value"),
      deleteIcon: const Icon(Icons.close),
      onDeleted: onDelete,
      backgroundColor: Colors.green.shade50,
      deleteIconColor: Colors.red,
    );
  }

  // 🔽 MODAL FILTROS
  void _abrirBuscaPersonalizada() {
    String? anoTemp = filtroAno;
    String? tipoTemp = filtroTipo;
    double? valorTemp = filtroValorMax;
    String? estadoTemp = filtroEstado;
    String? cidadeTemp = filtroCidade;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      "Filtros personalizados",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Ano",
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: anoTemp),
                      onChanged: (v) => anoTemp = v,
                    ),

                    const SizedBox(height: 20),

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
                      onChanged: (v) => setModal(() => tipoTemp = v),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Valor máximo",
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                          text: valorTemp?.toString()),
                      onChanged: (v) =>
                          valorTemp = double.tryParse(v),
                    ),

                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Estado",
                        border: OutlineInputBorder(),
                      ),
                      value: estadoTemp,
                      items: estados
                          .map(
                            (e) => DropdownMenuItem(
                              value: e['sigla'] as String,
                              child: Text(e['nome']),
                            ),
                          )
                          .toList(),
                      onChanged: (v) async {
                        setModal(() {
                          estadoTemp = v;
                          cidadeTemp = null;
                          cidades.clear();
                        });
                        if (v != null) {
                          await _carregarCidades(v);
                          setModal(() {});
                        }
                      },
                    ),

                    const SizedBox(height: 20),

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
                      onChanged: cidades.isEmpty
                          ? null
                          : (v) => setModal(() => cidadeTemp = v),
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
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Aplicar filtros",
                          style:
                              TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
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
}
