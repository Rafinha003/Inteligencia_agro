import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inteligencia_agro/Controller/tela-chat/chatController.dart';
import 'package:inteligencia_agro/View/Tela-chat/tela-chat-pessoal/chat-pessoal.dart';

class TelaChat extends StatefulWidget {
  const TelaChat({Key? key}) : super(key: key);

  @override
  State<TelaChat> createState() => _TelaChatState();
}

class _TelaChatState extends State<TelaChat> {
  final TextEditingController _pesquisaController = TextEditingController();
  final ChatController _controller = ChatController();

  String filtro = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          "Chat",
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
                hintText: "Pesquisar conversa...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF045006)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 💬 Lista de conversas
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _controller.obterConversasUsuario(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF045006)),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Erro ao carregar conversas.",
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final conversas = snapshot.data ?? [];

                  final conversasFiltradas = conversas.where((c) {
                    final nome = (c['nome'] ?? '').toString().toLowerCase();
                    return nome.contains(filtro);
                  }).toList();

                  if (conversasFiltradas.isEmpty) {
                    return Center(
                      child: Text(
                        "Nenhuma conversa encontrada.",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: conversasFiltradas.length,
                    itemBuilder: (context, index) {
                      final conversa = conversasFiltradas[index];

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
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: _buildFotoPerfil(conversa['fotoPerfil']),
                          ),
                          title: Text(
                            conversa['nome'] ?? "Usuário",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Color(0xFF1C1C1C),
                            ),
                          ),
                          subtitle: Text(
                            conversa['ultimoTexto'] ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          onTap: () {
                                final uidOutroUsuario = conversa['uidOutroUsuario'];
                                
                                if (uidOutroUsuario != null && uidOutroUsuario.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TelaChatPessoal(uidVendedor: uidOutroUsuario),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Erro ao abrir conversa.")),
                                  );
                                }
                              },
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

  Widget _buildFotoPerfil(dynamic imagemData) {
    const double tamanho = 55;

    if (imagemData == null || imagemData.toString().isEmpty) {
      return Container(
        width: tamanho,
        height: tamanho,
        color: const Color(0xFF3FAF47),
        child: const Icon(Icons.person, color: Colors.white, size: 32),
      );
    }

    if (imagemData.toString().startsWith('http')) {
      return Image.network(imagemData,
          width: tamanho, height: tamanho, fit: BoxFit.cover);
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
        child: const Icon(Icons.person_outline, color: Colors.grey, size: 32),
      );
    }
  }
}
