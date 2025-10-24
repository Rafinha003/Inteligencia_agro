import 'package:flutter/material.dart';
import 'package:inteligencia_agro/Controller/Escolha-plano/EscolhaPlanoController.dart';


class TelaEscolhaPlano extends StatefulWidget {
  const TelaEscolhaPlano({Key? key}) : super(key: key);

  @override
  State<TelaEscolhaPlano> createState() => _TelaEscolhaPlanoState();
}

class _TelaEscolhaPlanoState extends State<TelaEscolhaPlano> {
  final EscolhaPlanoController _planoController = EscolhaPlanoController();

  Future<void> _selecionarPlano(String plano) async {
    String? erro = await _planoController.salvarPlanoEscolhido(plano);

    if (erro == null) {
      Navigator.pushReplacementNamed(context, '/tela-login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Escolha seu plano",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Escolha o seu plano para utilizar o nosso aplicativo.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),

              _buildPlanoCard(
                titulo: "Gratuito",
                cor: Colors.green,
                preco: "R\$ 0,00 / mês",
                descricao: [
                  "Cadastro de até 5 itens por mês",
                  "Acesso às funcionalidades básicas (compra, venda, troca e aluguel)",
                  "Suporte limitado",
                ],
                onSelecionar: () => _selecionarPlano("Gratuito"),
              ),

              const SizedBox(height: 20),

              _buildPlanoCard(
                titulo: "Básico",
                cor: Colors.green,
                preco: "R\$ 29,90 / mês",
                descricao: [
                  "Cadastro de até 15 itens por mês",
                  "Acesso às funcionalidades básicas (compra, venda, troca e aluguel)",
                  "Histórico de transações",
                  "Acesso ao suporte básico",
                ],
                onSelecionar: () => _selecionarPlano("Básico"),
              ),

              const SizedBox(height: 20),

              _buildPlanoCard(
                titulo: "Premium",
                cor: Colors.green,
                preco: "R\$ 39,90 / mês",
                descricao: [
                  "Cadastro ilimitado de itens",
                  "Funcionalidades básicas (compra, venda, troca e aluguel)",
                  "Histórico de transações",
                  "Busca personalizada",
                ],
                onSelecionar: () => _selecionarPlano("Premium"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanoCard({
    required String titulo,
    required Color cor,
    required String preco,
    required List<String> descricao,
    required VoidCallback onSelecionar,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            Text(
              titulo,
              style: TextStyle(
                color: cor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              preco,
              style: TextStyle(
                color: cor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...descricao.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, color: Colors.green, size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onSelecionar,
              style: ElevatedButton.styleFrom(
                backgroundColor: cor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text(
                "Selecionar",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
