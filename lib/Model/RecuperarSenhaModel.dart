import 'package:flutter/material.dart';

class RecuperarSenhaModel {
  final TextEditingController emailController = TextEditingController();

  String? validarEmail() {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      return "Digite o e-mail";
    }
    if (!email.contains("@")) {
      return "O e-mail é inválido";
    }
    return null;
  }

  String get email => emailController.text.trim();

  void dispose() {
    emailController.dispose();
  }
}
