import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:inteligencia_agro/Controller/loginController.dart';
import 'package:inteligencia_agro/View/tela-cadastro/tela-cadastro.dart';
import 'package:inteligencia_agro/common/notificacao_tela.dart';

class LoginPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _valorEmail = TextEditingController();
  TextEditingController _valorSenha = TextEditingController();

  LoginController _loginController = LoginController();

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
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Serif'),
              ),
              Text(
                'Facilitando negócios e parcerias no mundo rural',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              TextFormField(
                controller: _valorEmail,
                decoration: InputDecoration(
                  labelText: 'email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (String? value){

                  if(value == null || value.isEmpty){
                    return "Digite o e-mail";
                  }
                  if(!value.contains("@")){
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
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value){
                  if(value == null || value.isEmpty){
                    return "Digite uma senha";
                  }
                  return null;
                }, 
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Lógica para recuperar senha
                  },
                  child: Text('Esqueceu a senha?', style: TextStyle(color: Color(0xFF00897B)),),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  btnLogin(context);
                },
                child: Text('Login',  style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF045006)
                ),
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  btnCriarConta(context);
                },
                child: Text('Criar conta', style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                   minimumSize: Size(double.infinity, 50),
                     backgroundColor: Color(0xFF3FAF47),
                ),
              ),
            ],
          ),
        ),
      ),
      )
    );
  }

  btnLogin(BuildContext context){
     String email = _valorEmail.text;
     String senha = _valorSenha.text;

     if(_formKey.currentState!.validate()){

        _loginController.LogarUsuario(email: email, senha: senha).then((String? erro){
          if(erro != null){
            mostrarNotificacaoTela(context: context, texto: erro);
          }else{
           mostrarNotificacaoTela(context: context, texto: "Usuário logado com sucesso", isErro: false);
          }
          
        });
     }
     else {
      mostrarNotificacaoTela(context: context, texto: "Há um ou mais campos inválidos.");
     }
  }

  btnCriarConta(BuildContext context){
      Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => CadastroPage()), 
  );
  }
}