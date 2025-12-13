import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inteligencia_agro/common/notificacao_tela.dart';
import 'package:inteligencia_agro/Model/RecuperarSenhaModel.dart';

class RecuperarSenhaController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// MÉTODO FIREBASE
  Future<String?> recuperarSenha({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return null; 
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Erro inesperado ao recuperar senha.";
    }
  }

  /// MÉTODO DA TELA 
  Future<void> btnEnviar({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required RecuperarSenhaModel model,
  }) async {
    // Validar formulário
    if (!formKey.currentState!.validate()) {
      return;
    }

    final email = model.email;

    final String? erro = await recuperarSenha(email: email);

    if (erro != null) {
      mostrarNotificacaoTela(context: context, texto: erro);
    } else {
      mostrarNotificacaoTela(
        context: context,
        texto: "Email de recuperação enviado com sucesso!!",
        isErro: false,
      );
      Navigator.pushNamed(context, '/tela-login');
    }
  }
}
