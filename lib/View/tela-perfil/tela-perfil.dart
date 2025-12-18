import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import 'package:inteligencia_agro/Controller/Tela-perfil-controller/TelaPerfilController.dart';
import 'package:inteligencia_agro/View/tela-configuracao/tela-configuracao.dart';
import 'package:inteligencia_agro/View/tela-perfil/tela-exibir-propostas/tela-exibir-propostas.dart';
import 'package:inteligencia_agro/View/tela-perfil/tela-ver-meus-itens/tela-ver-meus-itens.dart';


class TelaPerfil extends StatefulWidget {
  const TelaPerfil({Key? key}) : super(key: key);

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  final TelaPerfilController _controller = TelaPerfilController();

  String nomeUsuario = "";
  String cidade = "";
  String estado = "";
  String? fotoPerfilBase64;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    final dados = await _controller.obterUsuario();
    if (dados != null) {
      setState(() {
        nomeUsuario = dados['nome'] ?? '';
        if (dados['endereco'] != null &&
            (dados['endereco'] as List).isNotEmpty) {
          cidade = dados['endereco'][0]['cidade'] ?? '';
          estado = dados['endereco'][0]['estado'] ?? '';
        }
        fotoPerfilBase64 = dados['fotoPerfil'];
      });
    }
  }

  Future<void> _selecionarFoto() async {
    final picker = ImagePicker();
    final XFile? imagemSelecionada =
        await picker.pickImage(source: ImageSource.gallery);

    if (imagemSelecionada != null) {
      Uint8List bytes = await imagemSelecionada.readAsBytes();
      img.Image? imagemDecode = img.decodeImage(bytes);

      if (imagemDecode != null) {
        img.Image imagemRedimensionada =
            img.copyResize(imagemDecode, width: 400);

        Uint8List bytesFinal = Uint8List.fromList(
          img.encodeJpg(imagemRedimensionada, quality: 85),
        );

        final base64Image = base64Encode(bytesFinal);
        await _controller.atualizarFotoPerfil(base64Image);

        setState(() {
          fotoPerfilBase64 = base64Image;
        });
      }
    }
  }

  Route _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          /// HEADER MODERNO
          Container(
            height: 240,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF045006), Color(0xFF3FAF47)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(40),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 60,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _selecionarFoto,
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 44,
                            backgroundImage: fotoPerfilBase64 != null
                                ? MemoryImage(
                                    base64Decode(fotoPerfilBase64!))
                                : null,
                            backgroundColor: Colors.grey[300],
                            child: fotoPerfilBase64 == null
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.green,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        nomeUsuario,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$cidade • $estado",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// AÇÕES MODERNAS
          _itemMenu(
            icon: Icons.inventory_2_outlined,
            titulo: "Meus Itens",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TelaVerMeusItens()),
              );
            },
          ),
          _itemMenu(
            icon: Icons.handshake_outlined,
            titulo: "Propostas",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TelaExibirProposta()),
              );
            },
          ),
          _itemMenu(
            icon: Icons.settings_outlined,
            titulo: "Configurações",
            onTap: () {
              Navigator.of(context)
                  .push(_slideRoute(const TelaConfiguracoes()));
            },
          ),
        ],
      ),
    );
  }

  Widget _itemMenu({
    required IconData icon,
    required String titulo,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3FAF47).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF045006)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
