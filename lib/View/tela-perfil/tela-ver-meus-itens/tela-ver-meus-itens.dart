import 'package:flutter/material.dart';
import 'package:inteligencia_agro/Controller/Tela-perfil-controller/TelaPerfilController.dart';


class TelaVerMeusItens extends StatefulWidget {
  const TelaVerMeusItens({Key? key}) : super(key: key);

  @override
  State<TelaVerMeusItens> createState() => _TelaVerMeusItensState();
}

class _TelaVerMeusItensState extends State<TelaVerMeusItens> {
  final TelaPerfilController _controller = TelaPerfilController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              decoration: InputDecoration(
                hintText: "Pesquisar item...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF045006)),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF045006)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF045006), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // abrir modal de adicionar item (já existente)
                },
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
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 🔹 Lista de itens (FutureBuilder)
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _controller.obterItensUsuario(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF045006),
                      ),
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

                  if (itens.isEmpty) {
                    return Center(
                      child: Text(
                        "Nenhum item cadastrado ainda.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: itens.length,
                    itemBuilder: (context, index) {
                      final item = itens[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF3FAF47),
                            child: Text(
                              item['nome'][0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            item['nome'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text("Ano: ${item['ano']}"),
                              Text("Tipo: ${item['tipoTransacao']}"),
                              if (item['tipoTransacao'] != 'Troca')
                                Text("Valor: R\$ ${item['valor']}"),
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
}
