import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:inteligencia_agro/Controller/Tela-perfil-controller/TelaPerfilController.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;


class TelaPerfil extends StatefulWidget {
  const TelaPerfil({Key? key}) : super(key: key);

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  final TelaPerfilController _controller = TelaPerfilController();
  final TextEditingController _descricaoController = TextEditingController();

  String nomeUsuario = "";
  String cidade = "";
  String estado = "";
  String? fotoPerfilBase64;

  bool _mostrarBotaoSalvar = false;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    var dados = await _controller.obterUsuario();
    if (dados != null) {
      setState(() {
        nomeUsuario = dados['nome'] ?? '';
        if (dados['endereco'] != null && (dados['endereco'] as List).isNotEmpty) {
          cidade = dados['endereco'][0]['cidade'] ?? '';
          estado = dados['endereco'][0]['estado'] ?? '';
        }
        _descricaoController.text = dados['descricao'] ?? '';
        fotoPerfilBase64 = dados['fotoPerfil']; // se existir
      });
    }
  }

  void _salvarDescricao() async {
    await _controller.atualizarDescricao(_descricaoController.text);
    setState(() {
      _mostrarBotaoSalvar = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Descrição salva com sucesso!'),
        backgroundColor: Color(0xFF3FAF47),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _selecionarFoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagemSelecionada = await picker.pickImage(source: ImageSource.gallery);

    if (imagemSelecionada != null) {
      Uint8List bytes = await imagemSelecionada.readAsBytes();

      // Redimensiona a imagem para <= 1MB
      img.Image? imagemDecode = img.decodeImage(bytes);
      if (imagemDecode != null) {
        // Mantém proporção e redimensiona para 300px de largura (ou altura equivalente)
        img.Image imagemRedimensionada = img.copyResize(imagemDecode, width: 300);
        Uint8List bytesRedimensionados = Uint8List.fromList(img.encodeJpg(imagemRedimensionada, quality: 85));

        String base64Image = base64Encode(bytesRedimensionados);

        // Salva no Firestore usando o controller
        await _controller.atualizarFotoPerfil(base64Image);

        setState(() {
          fotoPerfilBase64 = base64Image;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Perfil",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF045006),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Perfil com foto, nome e cidade
            Row(
              children: [
                GestureDetector(
                  onTap: _selecionarFoto,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: fotoPerfilBase64 != null
                        ? MemoryImage(base64Decode(fotoPerfilBase64!))
                        : null,
                    child: fotoPerfilBase64 == null
                        ? const Icon(Icons.person, size: 50, color: Colors.green)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nomeUsuario,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF045006),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$cidade, $estado",
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 🔹 Descrição
            TextFormField(
              controller: _descricaoController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Descrição do perfil",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _mostrarBotaoSalvar = true; // mostra botão ao digitar
                });
              },
            ),

            // 🔹 Botão Salvar
            if (_mostrarBotaoSalvar) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvarDescricao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6CCF77),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Salvar",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // 🔹 Botões de ação
            Column(
              children: [
                _botaoAcao("Upgrade de Plano", true, () {
                  Navigator.pushNamed(context, '/tela-escolha-plano');
                }),
                const SizedBox(height: 12),
                _botaoAcao("Ver meus itens", false, () {}),
                const SizedBox(height: 12),
                _botaoAcao("Ver propostas", false, () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _botaoAcao(String texto, bool isBranco, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: isBranco ? Colors.white : const Color(0xFF3FAF47),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: isBranco ? const BorderSide(color: Color(0xFF045006), width: 1.5) : null,
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 16,
          color: isBranco ? const Color(0xFF045006) : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
