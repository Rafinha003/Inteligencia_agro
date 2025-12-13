import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inteligencia_agro/View/Tela-chat/tela-chat-pessoal/chat-pessoal.dart';
import 'package:inteligencia_agro/common/formatacao.dart';

class TelaListagemDetalheController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
 
  //METODOS FIREBASE
Future<Map<String, dynamic>?> obterItemPorId(String itemId) async {
  try {
    final doc = await _firestore.collection('itens').doc(itemId).get();

    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;

    data['valor'] = formatarValor(data['valor']?.toString() ?? '');

    return data;
  } catch (e) {
    return null;
  }
}

  Future<Map<String, dynamic>?> obterUsuarioPorUid(String uidUsuario) async {
    try {
      final doc = await _firestore.collection('Usuario').doc(uidUsuario).get();
      if (doc.exists) return doc.data();
      return null;
    } catch (e) {
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
      rethrow;
    }

}
  
// METODOS DA TELA

  Future<Map<String, dynamic>?> carregarDados(String itemId) async {
    return await obterItemComUsuario(itemId);
  }

  void abrirChat(BuildContext context, Map<String, dynamic>? itemData, Map<String, dynamic>? usuarioData) {
    if (usuarioData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuário vendedor não encontrado.")),
      );
      return;
    }

    final uidVendedor = itemData?['uidUsuario'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TelaChatPessoal(uidVendedor: uidVendedor),
      ),
    );
  }
}