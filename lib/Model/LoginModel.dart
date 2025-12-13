class LoginModel {
  String email;
  String senha;

  LoginModel({
    required this.email,
    required this.senha,
  });

  /// Valida se os campos estão preenchidos corretamente
  String? validar() {
    if (email.isEmpty) {
      return "Digite o e-mail";
    }
    if (!email.contains("@")) {
      return "E-mail inválido";
    }
    if (senha.isEmpty) {
      return "Digite a senha";
    }

    return null; // tudo certo
  }

  /// Retorna mapa (para usar em APIs futuramente)
  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "senha": senha,
    };
  }
}
