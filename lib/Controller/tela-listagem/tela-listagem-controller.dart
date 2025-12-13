import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inteligencia_agro/Controller/ibge/IbgeController.dart';
import 'package:inteligencia_agro/common/formatacao.dart';

class TelaListagemController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final IbgeController _ibgeController = IbgeController();

  //METODO FIREBASE
Future<List<Map<String, dynamic>>> obterTodosItens() async {
  try {
    final usuarioLogado = FirebaseAuth.instance.currentUser;
    if (usuarioLogado == null) {
      return [];
    }

    final snapshot = await _firestore.collection('itens').get();
    final todosItens = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'nome': data['nome'] ?? '',
        'ano': data['ano'] ?? '',
        'tipoTransacao': data['tipoTransacao'] ?? '',
        'valor': formatarValor(data['valor']?.toString() ?? ''),
        'imagem': data['imagem'] ?? '',
        'estado': data['estado'] ?? '',
        'cidade': data['cidade'] ?? '',
        'uidUsuario': data['uidUsuario'] ?? '',
      };
    }).toList();

    final propostasAceitasSnapshot = await _firestore
        .collection('propostas')
        .where('status', isEqualTo: 'aceito')
        .get();

    final Set<String> itensComPropostaAceita = propostasAceitasSnapshot.docs
        .map((doc) => doc['uidItem']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    
    final itensFiltrados = todosItens.where((item) {
      final bool pertenceOutroUsuario = item['uidUsuario'] != usuarioLogado.uid;
      final bool semPropostaAceita = !itensComPropostaAceita.contains(item['id']);
      return pertenceOutroUsuario && semPropostaAceita;
    }).toList();

   
    final itensFinal = itensFiltrados.map((item) {
      final copy = Map<String, dynamic>.from(item);
      copy.remove('uidUsuario');
      return copy;
    }).toList();

    return itensFinal;
  } catch (e) {
    print('Erro ao buscar itens: $e');
    return [];
  }
}

 // METODOS API IBGE
  Future<List<Map<String, dynamic>>> buscarEstados() async {
    return _ibgeController.buscarEstados();
  }

  Future<List<String>> buscarCidades(String uf) async {
    return _ibgeController.buscarCidades(uf);
  }


}
  
