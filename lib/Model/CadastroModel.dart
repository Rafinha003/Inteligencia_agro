class CadastroModel {
  String nome;
  String email;
  String telefone;
  String cpfCnpj;
  String senha;
  String confirmarSenha;
  String cep;
  String estado;
  String cidade;

  CadastroModel({
    required this.nome,
    required this.email,
    required this.telefone,
    required this.cpfCnpj,
    required this.senha,
    required this.confirmarSenha,
    required this.cep,
    required this.estado,
    required this.cidade,
  });
}
