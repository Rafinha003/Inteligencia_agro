import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inteligencia_agro/Controller/tela-historico-transacao/historico_transacao_controller.dart';

class TelaHistoricoTransacao extends StatefulWidget {
  const TelaHistoricoTransacao({Key? key}) : super(key: key);

  @override
  State<TelaHistoricoTransacao> createState() => _TelaHistoricoTransacaoState();
}

class _TelaHistoricoTransacaoState extends State<TelaHistoricoTransacao> {
  final HistoricoTransacaoController _controller = HistoricoTransacaoController();

  List<Map<String, dynamic>> _historico = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    setState(() => _carregando = true);
    final historico = await _controller.obterHistoricoTransacoes();
    setState(() {
      _historico = historico;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 Cálculo dos totais (ganho/gasto)
    double valorGanho = 0;
    double valorGasto = 0;

    for (var item in _historico) {
      final valorStr = item['valor']?.replaceAll(RegExp(r'[^0-9,]'), '') ?? '';
      final valorNum = double.tryParse(valorStr.replaceAll(',', '.')) ?? 0;

      if (item['tipoValor'] == 'ganho') {
        valorGanho += valorNum;
      } else if (item['tipoValor'] == 'gasto') {
        valorGasto += valorNum;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          "Histórico Transação",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // 🔹 Remove botão de voltar
        backgroundColor: const Color(0xFF045006),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _carregando
            ? const Center(child: CircularProgressIndicator())
            : _historico.isEmpty
                ? const Center(
                    child: Text(
                      "Nenhuma transação encontrada.",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildResumoValores(valorGanho, valorGasto),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _historico.length,
                          itemBuilder: (context, index) {
                            final item = _historico[index];
                            return _buildCardItem(item);
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildResumoValores(double valorGanho, double valorGasto) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            const Text("Valor Ganho",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              "R\$ ${valorGanho.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        Column(
          children: [
            const Text("Valor Gasto",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              "R\$ ${valorGasto.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardItem(Map<String, dynamic> item) {
    final imagem = item['imagem'];
    final nomeItem = item['nomeItem'] ?? 'Sem nome';
    final tipoTransacao = item['tipoTransacao'] ?? 'Transação';
    final valor = item['valor'];
    final quantidadeDias = item['quantidadeDias'];
    final tipoValor = item['tipoValor']; // ganho ou gasto

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImagemItem(imagem),
          const SizedBox(height: 8),
          Text(
            nomeItem,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 4),
          Text("Transação: $tipoTransacao",
              style: const TextStyle(fontSize: 14, color: Colors.black87)),
          if (valor != null)
            Text("Valor: $valor",
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
          if (quantidadeDias != null)
            Text("Período: $quantidadeDias",
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(
            tipoValor == 'ganho' ? "Ganho" : "Gasto",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: tipoValor == 'ganho' ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagemItem(dynamic imagemData) {
    const double size = 180;

    if (imagemData == null || imagemData.toString().isEmpty) {
      return Container(
        width: double.infinity,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF3FAF47),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.image_not_supported,
            color: Colors.white, size: 60),
      );
    }

    if (imagemData.toString().startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imagemData,
          width: double.infinity,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    try {
      final decodedBytes = base64Decode(imagemData);
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          decodedBytes,
          width: double.infinity,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } catch (e) {
      return Container(
        width: double.infinity,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
      );
    }
  }
}
