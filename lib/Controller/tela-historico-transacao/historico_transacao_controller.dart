import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoricoTransacaoController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> obterHistoricoTransacoes() async {
    final usuario = _auth.currentUser;
    if (usuario == null) return [];

    final uidLogado = usuario.uid;

    try {
      final propostasSnapshot = await _firestore
          .collection('propostas')
          .where('status', isEqualTo: 'aceito')
          .get();

      List<Map<String, dynamic>> listaHistorico = [];

      for (var doc in propostasSnapshot.docs) {
        final dadosProposta = doc.data();
        final uidComprador = dadosProposta['uidComprador'];
        final uidVendedor = dadosProposta['uidVendedor'];
        final uidItem = dadosProposta['uidItem'];

        String tipoValor = '';
        if (uidLogado == uidComprador) {
          tipoValor = 'gasto';
        } else if (uidLogado == uidVendedor) {
          tipoValor = 'ganho';
        } else {
          continue;
        }

        final itemSnapshot =
            await _firestore.collection('itens').doc(uidItem).get();

        if (!itemSnapshot.exists) continue;

        final dadosItem = itemSnapshot.data() ?? {};

        String tipoTransacao = dadosItem['tipoTransacao'] ?? 'Desconhecido';
        String nomeItem = dadosItem['nome'] ?? 'Sem nome';
        String? imagem = dadosItem['imagem'];
        String? valor;
        String? quantidadeDias;

        if (tipoTransacao == 'Troca') {
          valor = null;
        } else if (tipoTransacao == 'Aluga') {
          valor = dadosItem['valor'] != null
              ? "R\$ ${dadosItem['valor'].toString()}"
              : null;
          quantidadeDias = dadosItem['quantidadeDias'] != null
              ? "${dadosItem['quantidadeDias']} dias"
              : null;
        } else if (tipoTransacao == 'Venda') {
          valor = dadosItem['valor'] != null
              ? "R\$ ${dadosItem['valor'].toString()}"
              : null;
        }

        listaHistorico.add({
          'imagem': imagem ?? '',
          'nomeItem': nomeItem,
          'tipoTransacao': tipoTransacao,
          'valor': valor,
          'quantidadeDias': quantidadeDias,
          'tipoValor': tipoValor,
        });
      }

      return listaHistorico;
    } catch (e) {
      print('Erro ao obter histórico de transações: $e');
      return [];
    }
  }
}
