class HistoricoTransacaoModel {
  final String? imagem;
  final String? nomeItem;
  final String? tipoTransacao;
  final String? valor;
  final dynamic quantidadeDias;
  final String? tipoValor; // ganho ou gasto

  HistoricoTransacaoModel({
    this.imagem,
    this.nomeItem,
    this.tipoTransacao,
    this.valor,
    this.quantidadeDias,
    this.tipoValor,
  });

  factory HistoricoTransacaoModel.fromMap(Map<String, dynamic> map) {
    return HistoricoTransacaoModel(
      imagem: map['imagem'],
      nomeItem: map['nomeItem'],
      tipoTransacao: map['tipoTransacao'],
      valor: map['valor'],
      quantidadeDias: map['quantidadeDias'],
      tipoValor: map['tipoValor'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imagem': imagem,
      'nomeItem': nomeItem,
      'tipoTransacao': tipoTransacao,
      'valor': valor,
      'quantidadeDias': quantidadeDias,
      'tipoValor': tipoValor,
    };
  }
}
