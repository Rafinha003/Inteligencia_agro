import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inteligencia_agro/Model/LoginModel.dart';
import 'package:inteligencia_agro/View/Tela-principal/tela-principal.dart';
import 'package:inteligencia_agro/common/notificacao_tela.dart';

class LoginController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Métodos Firebase
  Future<String?> logarUsuario({
    required String email,
    required String senha,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "Usuário não encontrado. Cadastre-se primeiro.";
      }
      if (e.code == 'wrong-password') {
        return "Senha incorreta.";
      }
      return e.message;
    }
  }

  // Métodos da tela

  Future<void> realizarLogin({
    required BuildContext context,
    required LoginModel login,
    required GlobalKey<FormState> formKey,
  }) async {
   
    String? erroModel = login.validar();
    if (erroModel != null) {
      mostrarNotificacaoTela(context: context, texto: erroModel);
      return;
    }

   
    if (!formKey.currentState!.validate()) {
      mostrarNotificacaoTela(
        context: context,
        texto: "Há um ou mais campos inválidos.",
      );
      return;
    }

    
    String? erro = await logarUsuario(
      email: login.email,
      senha: login.senha,
    );

    if (erro != null) {
      mostrarNotificacaoTela(context: context, texto: erro);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TelaPrincipal()),
    );
  }

  void irParaCriarConta(BuildContext context) {
    Navigator.popAndPushNamed(context, '/tela-cadastro');
  }

  void irParaRecuperarSenha(BuildContext context) {
    Navigator.pushNamed(context, '/tela-recuperar-senha');
  }
}
