import 'package:flutter/material.dart';
import 'package:inteligencia_agro/Controller/autenticacao/tela-cadastro-controller.dart';
import 'package:inteligencia_agro/Model/CadastroModel.dart';
import 'package:inteligencia_agro/common/notificacao_tela.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();

  final CadastroController _controller = CadastroController();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _cpfCnpjController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();
  final TextEditingController _cepController = TextEditingController();

  List<Map<String, dynamic>> _estados = [];
  List<String> _cidades = [];
  String? _estadoSelecionado;
  String? _cidadeSelecionada;

  @override
  void initState() {
    super.initState();
    carregarEstados();
  }

  Future<void> carregarEstados() async {
    try {
      final dados = await _controller.buscarEstados();
      setState(() => _estados = dados);
    } catch (_) {
      mostrarNotificacaoTela(
          context: context, texto: "Erro ao carregar estados");
    }
  }

  Future<void> carregarCidades(String uf) async {
    try {
      final dados = await _controller.buscarCidades(uf);
      setState(() {
        _cidades = dados;
        _cidadeSelecionada = null;
      });
    } catch (_) {
      mostrarNotificacaoTela(
          context: context, texto: "Erro ao carregar cidades");
    }
  }


  Future<void> cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_controller.isCpfInvalido(_cpfCnpjController.text)) {
      mostrarNotificacaoTela(context: context, texto: "CPF inválido");
      return;
    }

    final cadastro = CadastroModel(
      nome: _nomeController.text,
      email: _emailController.text,
      telefone: _telefoneController.text,
      cpfCnpj: _cpfCnpjController.text,
      senha: _senhaController.text,
      confirmarSenha: _confirmarSenhaController.text,
      cep: _cepController.text,
      estado: _estadoSelecionado!,
      cidade: _cidadeSelecionada!,
    );

    String? erro = await _controller.realizarCadastro(cadastro);

    if (erro != null) {
      mostrarNotificacaoTela(context: context, texto: erro);
      return;
    }

    mostrarNotificacaoTela(
        context: context,
        texto: "Cadastro realizado com sucesso!",
        isErro: false);

    Navigator.pushNamedAndRemoveUntil(context, '/tela-login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crie sua Conta',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF045006),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pushNamed(context, '/tela-login'),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person_add, size: 50, color: Colors.green),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Crie sua conta',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                _input(
                  controller: _nomeController,
                  label: "Nome",
                  icon: Icons.person,
                  validator: (v) =>
                      v!.isEmpty ? "Digite seu nome" : null,
                ),
                const SizedBox(height: 16),

                _input(
                  controller: _telefoneController,
                  label: "Telefone",
                  icon: Icons.phone,
                  keyboard: TextInputType.phone,
                  validator: (v) => v!.length < 10 ? "Telefone inválido" : null,
                ),
                const SizedBox(height: 16),

                _input(
                  controller: _emailController,
                  label: "E-mail",
                  icon: Icons.email,
                  validator: (v) =>
                      !v!.contains("@") ? "E-mail inválido" : null,
                ),
                const SizedBox(height: 16),

                _input(
                  controller: _cpfCnpjController,
                  label: "CPF ou CNPJ",
                  icon: Icons.badge,
                  keyboard: TextInputType.number,
                  validator: (v) =>
                      v!.isEmpty ? "Digite o CPF ou CNPJ" : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _estadoSelecionado,
                  decoration: _decor("Estado", Icons.map),
                 items: _estados.map<DropdownMenuItem<String>>((Map<String, dynamic> e) {
                    return DropdownMenuItem<String>(
                      value: e['sigla'] as String,
                      child: Text(e['nome'] as String),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      _estadoSelecionado = v;
                      _cidades = [];
                      _cidadeSelecionada = null;
                    });
                    carregarCidades(v!);
                  },
                  validator: (v) => v == null ? "Selecione o estado" : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _cidadeSelecionada,
                  decoration:
                      _decor("Cidade", Icons.location_city),
                  items: _cidades
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _cidadeSelecionada = v),
                  validator: (v) => v == null ? "Selecione a cidade" : null,
                ),
                const SizedBox(height: 16),

                _input(
                  controller: _cepController,
                  label: "CEP",
                  icon: Icons.pin_drop,
                  keyboard: TextInputType.number,
                  validator: (v) =>
                      v!.isEmpty ? "Digite o CEP" : null,
                ),
                const SizedBox(height: 16),

                _input(
                  controller: _senhaController,
                  label: "Senha",
                  icon: Icons.lock,
                  isPassword: true,
                  validator: (v) => v!.isEmpty ? "Digite a senha" : null,
                ),
                const SizedBox(height: 16),

                _input(
                  controller: _confirmarSenhaController,
                  label: "Confirmar Senha",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (v) => v != _senhaController.text
                      ? "As senhas não coincidem"
                      : null,
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: cadastrar,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF3FAF47),
                  ),
                  child: const Text(
                    "Cadastrar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboard,
      decoration: _decor(label, icon),
      validator: validator,
    );
  }

  InputDecoration _decor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      prefixIcon: Icon(icon),
    );
  }
}
