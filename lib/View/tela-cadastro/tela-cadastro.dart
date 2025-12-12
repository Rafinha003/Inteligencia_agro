import 'package:flutter/material.dart';
import 'package:inteligencia_agro/Controller/autenticacao/autenticacaoController.dart';
import 'package:inteligencia_agro/Controller/ibge/ibgeController.dart';
import 'package:inteligencia_agro/common/notificacao_tela.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _cpfCnpjController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();

  final AutenticacaoController _autenticacaoController = AutenticacaoController();
  final IbgeController _ibgeController = IbgeController();

  List<Map<String, dynamic>> _estados = [];
  List<String> _cidades = [];
  String? _estadoSelecionado;
  String? _cidadeSelecionada;

  @override
  void initState() {
    super.initState();
    _carregarEstados();
  }

  Future<void> _carregarEstados() async {
    try {
      final estados = await _ibgeController.buscarEstados();
      setState(() {
        _estados = estados;
      });
    } catch (e) {
      mostrarNotificacaoTela(context: context, texto: 'Erro ao carregar estados');
    }
  }

  Future<void> _carregarCidades(String uf) async {
    try {
      final cidades = await _ibgeController.buscarCidades(uf);
      setState(() {
        _cidades = cidades;
        _cidadeSelecionada = null;
      });
    } catch (e) {
      mostrarNotificacaoTela(context: context, texto: 'Erro ao carregar cidades');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crie sua Conta', style: TextStyle(color: Colors.white, fontSize: 22)),
        centerTitle: true,
        backgroundColor: const Color(0xFF045006),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/tela-login');
          },
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person_add, size: 50, color: Colors.green),
                ),
                const SizedBox(height: 16),
                const Text('Crie sua conta', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                _buildTextField(
                  controller: _nomeController,
                  label: "Nome",
                  icon: Icons.person,
                  validator: (value) => value!.isEmpty ? "Digite seu nome" : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _telefoneController,
                  label: "Telefone",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.isEmpty ? "Digite seu telefone" : (value.length < 10 ? "Telefone inválido" : null),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: "E-mail",
                  icon: Icons.email,
                  validator: (value) => !value!.contains("@") ? "E-mail inválido" : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _cpfCnpjController,
                  label: "CPF ou CNPJ",
                  icon: Icons.badge,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return "Digite o CPF ou CNPJ";
                    if (value.length != 11 && value.length != 14) return "CPF ou CNPJ inválido";
                    if (value.length == 11 && isCpfInvalido(value)) return "CPF inválido";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 🔹 Campo Estado
                DropdownButtonFormField<String>(
                  value: _estadoSelecionado,
                  decoration: InputDecoration(
                    labelText: "Estado",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.map),
                  ),
                  items: _estados.map((estado) {
                    return DropdownMenuItem<String>(
                      value: estado['sigla'],
                      child: Text(estado['nome']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _estadoSelecionado = value;
                      _cidades = [];
                      _cidadeSelecionada = null;
                    });
                    _carregarCidades(value!);
                  },
                  validator: (value) => value == null ? "Selecione o estado" : null,
                ),
                const SizedBox(height: 16),

                // 🔹 Campo Cidade
                DropdownButtonFormField<String>(
                  value: _cidadeSelecionada,
                  decoration: InputDecoration(
                    labelText: "Cidade",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.location_city),
                  ),
                  items: _cidades.map((cidade) {
                    return DropdownMenuItem<String>(
                      value: cidade,
                      child: Text(cidade),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _cidadeSelecionada = value;
                    });
                  },
                  validator: (value) => value == null ? "Selecione a cidade" : null,
                ),
                const SizedBox(height: 16),

                // 🔹 Campo CEP
                _buildTextField(
                  controller: _cepController,
                  label: "CEP",
                  icon: Icons.pin_drop,
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? "Digite o CEP" : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _senhaController,
                  label: "Senha",
                  icon: Icons.lock,
                  isPassword: true,
                  validator: (value) => value!.isEmpty ? "Digite uma senha" : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _confirmarSenhaController,
                  label: "Confirmar Senha",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) =>
                      value != _senhaController.text ? "As senhas não coincidem" : null,
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () => _cadastrarUsuario(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF3FAF47),
                  ),
                  child: const Text("Cadastrar", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }

  _cadastrarUsuario(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      String? erro = await _autenticacaoController.cadastrarUsuario(
        email: _emailController.text,
        senha: _senhaController.text,
      );

      if (erro != null) {
        mostrarNotificacaoTela(context: context, texto: erro);
        return;
      }

      String? erroCriar = await _autenticacaoController.criarUsuario(
        nome: _nomeController.text,
        email: _emailController.text,
        telefone: _telefoneController.text,
        cpfCnpj: _cpfCnpjController.text,
        estado: _estadoSelecionado!,
        cidade: _cidadeSelecionada!,
        cep: _cepController.text,
      );

      if (erroCriar != null) {
        mostrarNotificacaoTela(context: context, texto: erroCriar);
        return;
      }

      mostrarNotificacaoTela(context: context, texto: "Cadastro realizado com sucesso!", isErro: false);
      Navigator.pushNamedAndRemoveUntil(context, '/tela-login', (route) => false);
    }
  }

  bool isCpfInvalido(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length != 11 || RegExp(r'^(.)\1+$').hasMatch(cpf)) return true;

    List<int> numeros = cpf.split('').map(int.parse).toList();
    for (int j = 9; j < 11; j++) {
      int soma = 0;
      for (int i = 0; i < j; i++) {
        soma += numeros[i] * ((j + 1) - i);
      }
      int resto = (soma * 10) % 11;
      if (resto == 10) resto = 0;
      if (numeros[j] != resto) return true;
    }
    return false;
  }
}
