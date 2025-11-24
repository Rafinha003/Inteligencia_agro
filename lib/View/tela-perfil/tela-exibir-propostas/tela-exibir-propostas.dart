import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inteligencia_agro/Controller/Tela-perfil-controller/TelaPerfilController.dart';

class TelaExibirProposta extends StatefulWidget {
  const TelaExibirProposta({Key? key}) : super(key: key);

  @override
  State<TelaExibirProposta> createState() => _TelaExibirPropostaState();
}

class _TelaExibirPropostaState extends State<TelaExibirProposta> {
  final TelaPerfilController _controller = TelaPerfilController();

  List<Map<String, dynamic>> _propostasRecebidas = [];
  List<Map<String, dynamic>> _propostasEnviadas = [];

  bool _carregandoRecebidas = true;
  bool _carregandoEnviadas = true;

  @override
  void initState() {
    super.initState();
    _carregarPropostasRecebidas();
    _carregarPropostasEnviadas();
  }

  // ---------- RECEBIDAS ----------
  Future<void> _carregarPropostasRecebidas() async {
    setState(() => _carregandoRecebidas = true);

    final propostas = await _controller.obterPropostasDoUsuario();

    setState(() {
      _propostasRecebidas = propostas;
      _carregandoRecebidas = false;
    });
  }

  // ---------- ENVIADAS ----------
  Future<void> _carregarPropostasEnviadas() async {
    setState(() => _carregandoEnviadas = true);

    final propostas = await _controller.obterPropostasEnviadas();

    setState(() {
      _propostasEnviadas = propostas;
      _carregandoEnviadas = false;
    });
  }

  // ---------- ATUALIZAR STATUS (SOMENTE RECEBIDAS) ----------
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

    _carregarPropostasRecebidas();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          title: const Text(
            "Propostas",
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF045006),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Recebidas"),
              Tab(text: "Enviadas"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPropostasRecebidas(),
            _buildPropostasEnviadas(),
          ],
        ),
      ),
    );
  }

  // ---------- UI: RECEBIDAS ----------
  Widget _buildPropostasRecebidas() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _carregandoRecebidas
          ? const Center(child: CircularProgressIndicator())
          : _propostasRecebidas.isEmpty
              ? const Center(child: Text("Nenhuma proposta recebida."))
              : ListView.builder(
                  itemCount: _propostasRecebidas.length,
                  itemBuilder: (context, index) {
                    return _buildCardProposta(_propostasRecebidas[index]);
                  },
                ),
    );
  }

  // ---------- UI: ENVIADAS ----------
  Widget _buildPropostasEnviadas() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _carregandoEnviadas
          ? const Center(child: CircularProgressIndicator())
          : _propostasEnviadas.isEmpty
              ? const Center(child: Text("Nenhuma proposta enviada."))
              : ListView.builder(
                  itemCount: _propostasEnviadas.length,
                  itemBuilder: (context, index) {
                    return _buildCardPropostaEnviada(_propostasEnviadas[index]);
                  },
                ),
    );
  }

  // ---------- CARD: RECEBIDAS ----------
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
                    style: const TextStyle(fontSize: 14, color: Colors.black87)),
                Text(telefone,
                    style: const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.check_circle, color: Color(0xFF1E8F2F)),
                iconSize: 30,
                onPressed: () => _atualizarStatus(propostaId, 'aceito'),
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                iconSize: 30,
                onPressed: () => _atualizarStatus(propostaId, 'recusado'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- CARD: ENVIADAS ----------
  Widget _buildCardPropostaEnviada(Map<String, dynamic> proposta) {
    final imagem = proposta['imagemItem'];
    final nomeProduto = proposta['nomeItem'] ?? 'Produto';
    final status = proposta['status'] ?? 'pendente';

    Color cor;
    if (status == 'aceito') {
      cor = Colors.green;
    } else if (status == 'recusado') {
      cor = Colors.red;
    } else {
      cor = Colors.orange;
    }

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
                const SizedBox(height: 6),
                Text(
                  "Status: $status",
                  style: TextStyle(fontSize: 14, color: cor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- COMPONENTE IMAGEM ----------
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
        child:
            const Icon(Icons.image_not_supported, color: Colors.white, size: 35),
      );
    }

    if (imagemData.toString().startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(imagemData,
            width: size, height: size, fit: BoxFit.cover),
      );
    }

    try {
      final decodedBytes = base64Decode(imagemData);
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(decodedBytes,
            width: size, height: size, fit: BoxFit.cover),
      );
    } catch (e) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.broken_image, color: Colors.grey, size: 35),
      );
    }
  }
}
