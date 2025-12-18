import 'package:flutter/material.dart';

class TelaConfiguracoes extends StatelessWidget {
  const TelaConfiguracoes({Key? key}) : super(key: key);

  static const Color _corPrimaria = Color(0xFF045006);
  static const Color _corDestaque = Color(0xFF3FAF47);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildConteudo()),
        ],
      ),
    );
  }

  // 🔹 HEADER PADRÃO (igual Chat/Listagem)
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 56, bottom: 24),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_corPrimaria, _corDestaque],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(36),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            const Text(
              "Configurações",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 CONTEÚDO
  Widget _buildConteudo() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle("Aparência"),
        _buildCard(
          child: Column(
            children: [
              _buildOpcaoTema(
                icon: Icons.light_mode,
                titulo: "Modo Claro",
                selecionado: true, // apenas visual
                onTap: () {},
              ),
              const Divider(height: 1),
              _buildOpcaoTema(
                icon: Icons.dark_mode,
                titulo: "Modo Escuro",
                selecionado: false, // apenas visual
                onTap: () {},
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        _buildSectionTitle("Sobre"),
        _buildCard(
          child: ListTile(
            leading: const Icon(Icons.info_outline, color: _corPrimaria),
            title: const Text("Versão do aplicativo"),
            subtitle: const Text("1.0.0"),
          ),
        ),
      ],
    );
  }

  // 🔹 TÍTULO DE SEÇÃO
  Widget _buildSectionTitle(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _corPrimaria,
        ),
      ),
    );
  }

  // 🔹 CARD PADRÃO
  Widget _buildCard({required Widget child}) {
    return Container(
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
      child: child,
    );
  }

  // 🔹 OPÇÃO DE TEMA (UI ONLY)
  Widget _buildOpcaoTema({
    required IconData icon,
    required String titulo,
    required bool selecionado,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: selecionado ? _corPrimaria : Colors.grey,
      ),
      title: Text(
        titulo,
        style: TextStyle(
          fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: selecionado
          ? const Icon(Icons.check_circle, color: _corPrimaria)
          : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
    );
  }
}
