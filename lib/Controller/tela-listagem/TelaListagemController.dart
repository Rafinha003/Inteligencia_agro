import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaListagemController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> obterTodosItens() async {
    try {
      final snapshot = await _firestore.collection('itens').get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id, 
          'nome': data['nome'] ?? '',
          'ano': data['ano'] ?? '',
          'tipoTransacao': data['tipoTransacao'] ?? '',
          'valor': data['valor'] ?? '',
          'imagem': data['imagem'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Erro ao buscar itens: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> obterItemPorId(String itemId) async {
    try {
      final doc = await _firestore.collection('itens').doc(itemId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Erro ao buscar item por ID: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> obterUsuarioPorUid(String uidUsuario) async {
    try {
      final doc = await _firestore.collection('Usuario').doc(uidUsuario).get();
      if (doc.exists) {
        return doc.data();
      }
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
      print('Erro ao buscar item com usuário: $e');
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
