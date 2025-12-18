import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inteligencia_agro/Controller/tela-historico-transacao/historico_transacao_controller.dart';
import 'package:inteligencia_agro/Model/HistoricoTransacaoModel.dart';

class TelaHistoricoTransacao extends StatefulWidget {
  const TelaHistoricoTransacao({Key? key}) : super(key: key);

  @override
  State<TelaHistoricoTransacao> createState() =>
      _TelaHistoricoTransacaoState();
}

class _TelaHistoricoTransacaoState extends State<TelaHistoricoTransacao> {
  final HistoricoTransacaoController _controller =
      HistoricoTransacaoController();

  List<HistoricoTransacaoModel> _historico = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    setState(() => _carregando = true);

    final resultado = await _controller.obterHistoricoTransacoes();

    setState(() {
      _historico =
          resultado.map((e) => HistoricoTransacaoModel.fromMap(e)).toList();
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double valorGanho = 0;
    double valorGasto = 0;

    for (var item in _historico) {
      final valorStr =
          item.valor?.replaceAll(RegExp(r'[^0-9,]'), '') ?? '';
      final valorNum = double.tryParse(valorStr.replaceAll(',', '.')) ?? 0;

      if (item.tipoValor == 'ganho') {
        valorGanho += valorNum;
      } else if (item.tipoValor == 'gasto') {
        valorGasto += valorNum;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(valorGanho, valorGasto),
                Expanded(
                  child: _historico.isEmpty
                      ? const Center(
                          child: Text(
                            "Nenhuma transação encontrada",
                            style: TextStyle(
                                fontSize: 16, color: Colors.black54),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _historico.length,
                          itemBuilder: (_, index) =>
                              _buildTransacaoCard(_historico[index]),
                        ),
                ),
              ],
            ),
    );
  }

  // 🔹 HEADER MODERNO
  Widget _buildHeader(double ganho, double gasto) {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 28),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF045006), Color(0xFF3FAF47)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Column(
        children: [
          const Text(
            "Histórico transação",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _resumoCard(
                  titulo: "Ganhos",
                  valor: ganho,
                  cor: Colors.greenAccent,
                  icone: Icons.arrow_upward,
                ),
                const SizedBox(width: 12),
                _resumoCard(
                  titulo: "Gastos",
                  valor: gasto,
                  cor: Colors.redAccent,
                  icone: Icons.arrow_downward,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumoCard({
    required String titulo,
    required double valor,
    required Color cor,
    required IconData icone,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, color: cor),
                const SizedBox(width: 6),
                Text(
                  titulo,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "R\$ ${valor.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 CARD MODERNO DE TRANSAÇÃO
  Widget _buildTransacaoCard(HistoricoTransacaoModel item) {
    final bool isGanho = item.tipoValor == 'ganho';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImagemItem(item.imagem),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.nomeItem ?? 'Item',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _badge(isGanho),
                  ],
                ),
                const SizedBox(height: 6),
                _infoLinha("Transação", item.tipoTransacao),
                _infoLinha("Valor", item.valor),
                _infoLinha("Período", item.quantidadeDias),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoLinha(String titulo, String? valor) {
    if (valor == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        "$titulo: $valor",
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }

  Widget _badge(bool isGanho) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isGanho
            ? Colors.green.withOpacity(0.15)
            : Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isGanho ? "Ganho" : "Gasto",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: isGanho ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  // 🔹 IMAGEM (mantido)
  Widget _buildImagemItem(dynamic imagemData) {
    const double size = 180;

    if (imagemData == null || imagemData.toString().isEmpty) {
      return Container(
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFF3FAF47),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Center(
          child: Icon(Icons.image_not_supported,
              color: Colors.white, size: 60),
        ),
      );
    }

    if (imagemData.toString().startsWith('http')) {
      return ClipRRect(
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
        child: Image.network(
          imagemData,
          height: size,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    try {
      final decodedBytes = base64Decode(imagemData);
      return ClipRRect(
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
        child: Image.memory(
          decodedBytes,
          height: size,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } catch (_) {
      return Container(
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Center(
          child:
              Icon(Icons.broken_image, size: 50, color: Colors.grey),
        ),
      );
    }
  }
}
