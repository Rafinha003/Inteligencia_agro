import 'package:flutter/material.dart';
import 'package:inteligencia_agro/Controller/autenticacao/Tela-login-controller.dart';
import 'package:inteligencia_agro/Model/LoginModel.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _valorEmail = TextEditingController();
  final TextEditingController _valorSenha = TextEditingController();

  final LoginController _controller = LoginController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.grass, size: 50, color: Colors.green),
                ),
                SizedBox(height: 16),
                Text(
                  'Inteligência Agro',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif',
                  ),
                ),
                Text(
                  'Facilitando negócios e parcerias no mundo rural',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),

                TextFormField(
                  controller: _valorEmail,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Digite o e-mail";
                    }
                    if (!value.contains("@")) {
                      return "O e-mail é inválido";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16),

                TextFormField(
                  controller: _valorSenha,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Digite uma senha";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        _controller.irParaRecuperarSenha(context),
                    child: Text(
                      'Esqueceu a senha?',
                      style: TextStyle(color: Color(0xFF00897B)),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () {
                    LoginModel login = LoginModel(
                      email: _valorEmail.text.trim(),
                      senha: _valorSenha.text.trim(),
                    );

                    _controller.realizarLogin(
                      context: context,
                      login: login,
                      formKey: _formKey,
                    );
                  },
                  child: Text('Login', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF045006),
                  ),
                ),

                SizedBox(height: 8),

                TextButton(
                  onPressed: () => _controller.irParaCriarConta(context),
                  child: Text(
                    'Criar conta',
                    style: TextStyle(color: Colors.white),
                  ),
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
}
