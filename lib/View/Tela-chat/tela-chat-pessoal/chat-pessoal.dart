import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inteligencia_agro/Controller/tela-chat/chatController.dart';

class TelaChatPessoal extends StatefulWidget {
  final String uidVendedor;

  const TelaChatPessoal({Key? key, required this.uidVendedor})
      : super(key: key);

  @override
  State<TelaChatPessoal> createState() => _TelaChatPessoalState();
}

class _TelaChatPessoalState extends State<TelaChatPessoal> {
  final ChatController _controller = ChatController();
  final TextEditingController _mensagemController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic>? vendedorData;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDadosVendedor();
  }

  Future<void> _carregarDadosVendedor() async {
    final dados = await _controller.obterDadosVendedor(widget.uidVendedor);
    if (mounted) {
      setState(() {
        vendedorData = dados;
        carregando = false;
      });
    }
  }

  Future<void> _enviarMensagem() async {
    final texto = _mensagemController.text.trim();
    if (texto.isEmpty) return;

    try {
      await _controller.enviarMensagem(
        uidVendedor: widget.uidVendedor,
        texto: texto,
      );
      _mensagemController.clear();
      Future.delayed(const Duration(milliseconds: 200), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao enviar mensagem.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF045006)),
        ),
      );
    }

    final nomeVendedor = vendedorData?['nome'] ?? 'Vendedor';
    final fotoPerfilBase64 = vendedorData?['fotoPerfil'] ?? '';
    final fotoWidget = _buildFotoPerfil(fotoPerfilBase64);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF045006), Color(0xFF097C0D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Row(
            children: [
              CircleAvatar(radius: 22, backgroundImage: fotoWidget),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  nomeVendedor,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FFF8), Color(0xFFE9F2E9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _controller.obterMensagens(widget.uidVendedor),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF045006)),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "Nenhuma mensagem ainda",
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    );
                  }

                  final mensagens = snapshot.data!.docs;

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    itemCount: mensagens.length,
                    itemBuilder: (context, index) {
                      final msg = mensagens[index];
                      final texto = msg['texto'] ?? '';
                      final remetenteId = msg['remetenteId'];
                      final uidAtual = _controller.obterUidUsuarioAtual();
                      final bool souEu = remetenteId == uidAtual;

                      return Align(
                        alignment: souEu
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: souEu
                                ? const Color(0xFF045006)
                                : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: souEu
                                  ? const Radius.circular(16)
                                  : const Radius.circular(0),
                              bottomRight: souEu
                                  ? const Radius.circular(0)
                                  : const Radius.circular(16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(1, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            texto,
                            style: TextStyle(
                              color: souEu ? Colors.white : Colors.black87,
                              fontSize: 16,
                              height: 1.3,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            _buildCampoMensagem(),
          ],
        ),
      ),
    );
  }

  ImageProvider _buildFotoPerfil(String? base64Data) {
    try {
      if (base64Data != null && base64Data.isNotEmpty) {
        final decoded = base64Decode(base64Data);
        return MemoryImage(decoded);
      }
    } catch (e) {
      debugPrint("Erro ao decodificar imagem de perfil: $e");
    }
    return const AssetImage('assets/images/user_placeholder.png');
  }

  Widget _buildCampoMensagem() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _mensagemController,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.chat_bubble_outline_rounded,
                      color: Color(0xFF045006)),
                  hintText: "Digite sua mensagem...",
                  hintStyle: const TextStyle(color: Colors.black45),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide:
                        const BorderSide(color: Color(0xFF045006), width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide:
                        const BorderSide(color: Color(0xFF045006), width: 1.8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _enviarMensagem,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF045006),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
