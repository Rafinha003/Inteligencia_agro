import 'package:flutter/material.dart';
import 'package:inteligencia_agro/common/notificacao_tela.dart';

class CadastroPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro', style: TextStyle(color: Colors.white, fontSize: 22),),
        centerTitle: true,
        backgroundColor: const Color(0xFF045006),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person_add, size: 50, color: Colors.green),
                ),
                SizedBox(height: 16),
                Text(
                  'Crie sua conta',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 32),
                _buildTextField(
                  controller: _nomeController,
                  label: "Nome",
                  icon: Icons.person,
                  validator: (value){
                    if(value!.isEmpty){
                      return "Digite seu nome";
                    }
                    return null;
                  }
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: "E-mail",
                  icon: Icons.email,
                  validator: (value) {
                    if (value!.isEmpty){
                        return "Digite o e-mail";
                    } 
                    if (!value.contains("@")) {
                       return "O e-mail é inválido";
                    }
                   
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _cpfController,
                  label: "CPF",
                  icon: Icons.badge,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if(value!.isEmpty){
                      return "Digite um CPF";    
                    }
                    if(value!.length != 11){
                      return  "CPF inválido";
                    }
                    if(isCpfInvalido(value)){
                      return "CPF inválido";
                    }
                    return null;
                  }
        
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _senhaController,
                  label: "Senha",
                  icon: Icons.lock,
                  isPassword: true,
                  validator: (value){
                    if(value!.isEmpty){
                      return "Digite uma senha";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _confirmarSenhaController,
                  label: "Confirmar Senha",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) {
                    if (value!.isEmpty){
                      return "Confirme a senha";
                    } 
                    if (value != _senhaController.text){
                      return "As senhas não coincidem";
                    } 
                    return null;
                  },
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    _cadastrarUsuario(context);
                  },
                  child: Text("Cadastrar", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Color(0xFF3FAF47),
                  ),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }

   _cadastrarUsuario(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      mostrarNotificacaoTela(
        context: context,
        texto: "Cadastro realizado com sucesso!",
        isErro: false,
      );
      Navigator.pop(context); 
    } else {
      mostrarNotificacaoTela(
        context: context,
        texto: "Há um ou mais campos inválidos.",
      );
    }
  }

  bool isCpfInvalido(String cpf) {
  cpf = cpf.replaceAll(RegExp(r'[^0-9]'), ''); // Remove pontos e traços

  if (cpf.length != 11 || RegExp(r'^(.)\1+$').hasMatch(cpf)) {
    return true; // CPF inválido (tamanho errado ou todos os dígitos iguais)
  }

  List<int> numeros = cpf.split('').map(int.parse).toList();

  for (int j = 9; j < 11; j++) {
    int soma = 0;
    for (int i = 0; i < j; i++) {
      soma += numeros[i] * ((j + 1) - i);
    }

    int resto = (soma * 10) % 11;
    if (resto == 10) resto = 0;

    if (numeros[j] != resto) {
      return true; // CPF inválido
    }
  }

  return false; // CPF válido
}

}
