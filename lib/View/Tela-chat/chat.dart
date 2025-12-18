import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inteligencia_agro/Controller/tela-chat/tela-chat-controller.dart';
import 'package:inteligencia_agro/Model/ChatModel.dart';
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
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildListaConversas()),
        ],
      ),
    );
  }

  // 🔹 HEADER MODERNO
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
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Conversas",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPesquisa(),
          ],
        ),
      ),
    );
  }

  // 🔍 PESQUISA MODERNA
  Widget _buildPesquisa() {
    return TextField(
      controller: _pesquisaController,
      onChanged: (value) {
        setState(() => filtro = value.toLowerCase());
      },
      decoration: InputDecoration(
        hintText: "Pesquisar conversa...",
        prefixIcon: const Icon(Icons.search, color: Color(0xFF045006)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // 💬 LISTA DE CONVERSAS
  Widget _buildListaConversas() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _controller.obterConversasUsuario(),
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
              "Erro ao carregar conversas.",
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        final conversasMap = snapshot.data ?? [];

        final conversas = conversasMap
            .map((c) => ChatModel.fromMap(c))
            .toList();

        final conversasFiltradas = conversas.where((c) {
          return c.nome.toLowerCase().contains(filtro);
        }).toList();

        if (conversasFiltradas.isEmpty) {
          return Center(
            child: Text(
              "Nenhuma conversa encontrada",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          itemCount: conversasFiltradas.length,
          itemBuilder: (_, index) {
            final conversa = conversasFiltradas[index];
            return _buildChatItem(conversa);
          },
        );
      },
    );
  }

  // 🧑‍💬 ITEM DE CHAT MODERNO
  Widget _buildChatItem(ChatModel conversa) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        if (conversa.uidOutroUsuario.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TelaChatPessoal(
                uidVendedor: conversa.uidOutroUsuario,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Erro ao abrir conversa."),
            ),
          );
        }
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
            _buildAvatar(conversa.fotoPerfil),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversa.nome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversa.ultimoTexto ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // 👤 AVATAR
  Widget _buildAvatar(String? imagemData) {
    const double size = 54;

    Widget imagem;

    if (imagemData == null || imagemData.isEmpty) {
      imagem = const Icon(Icons.person, color: Colors.white, size: 28);
    } else if (imagemData.startsWith('http')) {
      imagem = Image.network(
        imagemData,
        fit: BoxFit.cover,
      );
    } else {
      try {
        imagem = Image.memory(
          base64Decode(imagemData),
          fit: BoxFit.cover,
        );
      } catch (_) {
        imagem = const Icon(Icons.person_outline,
            color: Colors.white, size: 28);
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF3FAF47),
      ),
      clipBehavior: Clip.antiAlias,
      child: imagem,
    );
  }
}
