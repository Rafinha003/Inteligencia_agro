class ChatModel {
  final String uidOutroUsuario;
  final String nome;
  final String? ultimoTexto;
  final String? fotoPerfil;

  ChatModel({
    required this.uidOutroUsuario,
    required this.nome,
    this.ultimoTexto,
    this.fotoPerfil,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      uidOutroUsuario: map['uidOutroUsuario'] ?? '',
      nome: map['nome'] ?? 'Usuário',
      ultimoTexto: map['ultimoTexto'],
      fotoPerfil: map['fotoPerfil'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uidOutroUsuario': uidOutroUsuario,
      'nome': nome,
      'ultimoTexto': ultimoTexto,
      'fotoPerfil': fotoPerfil,
    };
  }
}
