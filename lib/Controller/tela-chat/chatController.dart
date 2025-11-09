import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _gerarChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Future<void> enviarMensagem({
    required String uidVendedor,
    required String texto,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Usuário não autenticado.");

    final chatId = _gerarChatId(user.uid, uidVendedor);

    await _firestore.collection('chats').doc(chatId).collection('mensagens').add({
      'texto': texto,
      'remetenteId': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });


    await _firestore.collection('chats').doc(chatId).set({
      'usuarios': [user.uid, uidVendedor],
      'ultimoTexto': texto,
      'ultimaMensagemEm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }


  Stream<QuerySnapshot> obterMensagens(String uidVendedor) {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("Usuário não autenticado.");
    }
    final chatId = _gerarChatId(user.uid, uidVendedor);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('mensagens')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<Map<String, dynamic>?> obterDadosVendedor(String uidVendedor) async {
    try {
      final doc = await _firestore.collection('Usuario').doc(uidVendedor).get();
      if (doc.exists) return doc.data();
      return null;
    } catch (e) {
      print("Erro ao buscar vendedor: $e");
      return null;
    }
  }

  String? obterUidUsuarioAtual() => _auth.currentUser?.uid;
}
