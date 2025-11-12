import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaListagemController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

 Future<List<Map<String, dynamic>>> obterTodosItens() async {
  try {
    // 1️⃣ Busca todos os itens normalmente
    final snapshot = await _firestore.collection('itens').get();
    final todosItens = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'nome': data['nome'] ?? '',
        'ano': data['ano'] ?? '',
        'tipoTransacao': data['tipoTransacao'] ?? '',
        'valor': data['valor'] ?? '',
        'imagem': data['imagem'] ?? '',
        'estado': data['estado'] ?? '',
        'cidade': data['cidade'] ?? '',
      };
    }).toList();

    // 2️⃣ Busca todos os uidItem das propostas com status "aceito"
    final propostasAceitasSnapshot = await _firestore
        .collection('propostas')
        .where('status', isEqualTo: 'aceito')
        .get();

    final Set<String> itensComPropostaAceita = propostasAceitasSnapshot.docs
        .map((doc) => doc['uidItem']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    // 3️⃣ Filtra removendo os itens que já têm proposta aceita
    final itensFiltrados = todosItens
        .where((item) => !itensComPropostaAceita.contains(item['id']))
        .toList();

    return itensFiltrados;
  } catch (e) {
    print('Erro ao buscar itens: $e');
    return [];
  }
}



  // 🔹 Obtém um item por ID
  Future<Map<String, dynamic>?> obterItemPorId(String itemId) async {
    try {
      final doc = await _firestore.collection('itens').doc(itemId).get();
      if (doc.exists) return doc.data();
      return null;
    } catch (e) {
      print('Erro ao buscar item por ID: $e');
      return null;
    }
  }

  // 🔹 Obtém usuário pelo UID
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

  // 🔹 Obtém item com dados do usuário
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
}
  
