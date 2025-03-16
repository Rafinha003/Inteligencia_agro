import 'package:flutter/material.dart';
import 'package:inteligencia_agro/Controller/autenticacao/autenticacaoController.dart';
import 'package:inteligencia_agro/View/tela-login/tela-login.dart';
import 'package:inteligencia_agro/common/notificacao_tela.dart';

class TelaRecuperarSenha extends StatefulWidget {
  const TelaRecuperarSenha({super.key});

  @override
  State<TelaRecuperarSenha> createState() => _TelaRecuperarSenhaState();
}

class _TelaRecuperarSenhaState extends State<TelaRecuperarSenha> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  AutenticacaoController _autenticacaoController = AutenticacaoController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recupere sua senha',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Siga as intruções",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Informe seu e-mail para receber as instruções de recuperação de senha.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Digite o e-mail";
                    }
                    if (!value.contains("@")) {
                      return "O e-mail é inválido";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF045006),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      btnEnviar();
                    },
                    child: const Text(
                      "Enviar",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  btnEnviar() {
    String email = _emailController.text;

    _autenticacaoController.RecuperarSenha(email: email).then((String? erro) {
      if (erro != null) {
        mostrarNotificacaoTela(context: context, texto: erro);
      } else {
        mostrarNotificacaoTela(
          context: context,
          texto: "Email de recuperação enviado com sucesso!!",
          isErro: false,
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TelaLogin()),
        );
      }
    });
  }
}
