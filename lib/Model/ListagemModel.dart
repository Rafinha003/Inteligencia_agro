class ListagemModel {
  final String id;
  final String nome;
  final String tipoTransacao;
  final String ano;
  final double? valor;
  final String estado;
  final String cidade;
  final String? imagem;

  ListagemModel({
    required this.id,
    required this.nome,
    required this.tipoTransacao,
    required this.ano,
    this.valor,
    required this.estado,
    required this.cidade,
    this.imagem,
  });

  factory ListagemModel.fromMap(Map<String, dynamic> map) {
    final valorString = map['valor']?.toString();
    final valorParsed = valorString != null && valorString.isNotEmpty
        ? double.tryParse(valorString)
        : null;

    return ListagemModel(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      tipoTransacao: map['tipoTransacao'] ?? '',
      ano: map['ano']?.toString() ?? '',
      valor: valorParsed,
      estado: map['estado'] ?? '',
      cidade: map['cidade'] ?? '',
      imagem: map['imagem'],
    );
  }
}
