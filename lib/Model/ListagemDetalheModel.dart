import 'dart:convert';

class ListagemDetalheModel {
  final String? id;
  final String? nome;
  final String? descricao;
  final dynamic valor;
  final String? ano;
  final String? tipoTransacao;
  final int? quantidadeDias;
  final String? imagem;
  final String? uidUsuario;

  final String? nomeUsuario;
  final String? telefoneUsuario;

  ListagemDetalheModel({
    this.id,
    this.nome,
    this.descricao,
    this.valor,
    this.ano,
    this.tipoTransacao,
    this.quantidadeDias,
    this.imagem,
    this.uidUsuario,
    this.nomeUsuario,
    this.telefoneUsuario,
  });

  factory ListagemDetalheModel.fromMap(Map<String, dynamic> map) {
    return ListagemDetalheModel(
      id: map['id'] ?? map['uidItem'],
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      valor: map['valor'],
      ano: map['ano']?.toString() ?? '',
      tipoTransacao: map['tipoTransacao'] ?? map['tipoTransacao'] ?? '',
      quantidadeDias: map['quantidadeDias'],
      imagem: map['imagem'],
      uidUsuario: map['uidUsuario'],
      nomeUsuario: map['usuario'] != null ? map['usuario']['nome'] : null,
      telefoneUsuario: map['usuario'] != null ? map['usuario']['telefone'] : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'valor': valor,
      'ano': ano,
      'tipoTransacao': tipoTransacao,
      'quantidadeDias': quantidadeDias,
      'imagem': imagem,
      'uidUsuario': uidUsuario,
      'usuario': {
        'nome': nomeUsuario,
        'telefone': telefoneUsuario,
      },
    };
  }

  factory ListagemDetalheModel.fromJson(String source) => ListagemDetalheModel.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());
}
