import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TelaListagemController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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



  Future<Map<String, dynamic>?> obterItemPorId(String itemId) async {
  try {
    final doc = await _firestore.collection('itens').doc(itemId).get();

    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;

    data['valor'] = formatarValor(data['valor']?.toString() ?? '');

    return data;
  } catch (e) {
    print('Erro ao buscar item por ID: $e');
    return null;
  }
}



  Future<Map<String, dynamic>?> obterUsuarioPorUid(String uidUsuario) async {
    try {
      final doc = await _firestore.collection('Usuario').doc(uidUsuario).get();
      if (doc.exists) return doc.data();
      return null;
    } catch (e) {
      print('Erro ao buscar usuário: $e');
      return null;
    }
  }

  


 Future<Map<String, dynamic>?> obterItemComUsuario(String itemId) async {
  try {
    final itemDoc = await _firestore.collection('itens').doc(itemId).get();
    if (!itemDoc.exists) return null;

    final itemData = itemDoc.data()!;
    Map<String, dynamic>? usuarioData;

    final uidUsuario = itemData['uidUsuario'];
    if (uidUsuario != null && uidUsuario.toString().isNotEmpty) {
      final usuarioDoc =
          await _firestore.collection('Usuario').doc(uidUsuario).get();
      if (usuarioDoc.exists) {
        usuarioData = usuarioDoc.data();
      }
    }

    return {
      'item': itemData,
      'usuario': usuarioData,
    };
  } catch (e) {
    print('Erro ao obter item com usuário: $e');
    return null;
  }
}

   Future<void> enviarProposta({
    required String uidItem,
    required String uidVendedor,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("Usuário não logado");

      await _firestore.collection('propostas').add({
        'uidItem': uidItem,
        'uidComprador': user.uid,
        'uidVendedor': uidVendedor,
        'criadoEm': DateTime.now(),
      });
    } catch (e) {
      print('Erro ao enviar proposta: $e');
      rethrow;
    }
  }

  String formatarValor(String valorOriginal) {
  if (valorOriginal.isEmpty) return "R\$ 0,00";

  String somenteNumeros = valorOriginal.replaceAll(RegExp(r'[^0-9]'), '');

  if (somenteNumeros.isEmpty) return "R\$ 0,00";

  double valorDouble;

  if (somenteNumeros.length == 2 && !somenteNumeros.startsWith('0')) {
    valorDouble = double.parse(somenteNumeros).toDouble();
  }

  else if (somenteNumeros.length == 3 && somenteNumeros.startsWith('0')) {
    String reais = "0";
    String centavos = somenteNumeros.substring(1);
    valorDouble = double.parse("$reais.$centavos");
  }

  else if (somenteNumeros.length <= 2) {
    valorDouble = double.parse(somenteNumeros) / 100;
  } else {
    String reais = somenteNumeros.substring(0, somenteNumeros.length - 2);
    String centavos = somenteNumeros.substring(somenteNumeros.length - 2);
    valorDouble = double.parse("$reais.$centavos");
  }

  final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  return formatter.format(valorDouble);
}

}
  
