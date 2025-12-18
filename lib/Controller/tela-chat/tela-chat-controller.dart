import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> obterConversasUsuario() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("Usuário não autenticado.");
    }

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot;

      // 🔹 Tenta buscar com ordenação (caso exista índice)
      try {
        querySnapshot = await _firestore
            .collection('chats')
            .where('usuarios', arrayContains: user.uid)
            .orderBy('ultimaMensagemEm', descending: true)
            .get();
      } catch (_) {
        // 🔹 Fallback sem orderBy (evita erro de índice)
        querySnapshot = await _firestore
            .collection('chats')
            .where('usuarios', arrayContains: user.uid)
            .get();
      }

      List<Map<String, dynamic>> conversas = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final List usuarios = (data['usuarios'] ?? []) as List;

        // 🔹 Validação de segurança
        if (usuarios.isEmpty || !usuarios.contains(user.uid)) continue;

        // 🔹 Descobre o outro usuário do chat
        final String? outroUid = usuarios.firstWhere(
          (uid) => uid != user.uid,
          orElse: () => null,
        );

        if (outroUid == null) continue;

        // 🔹 Busca dados do outro usuário
        final outroUsuarioDoc =
            await _firestore.collection('Usuario').doc(outroUid).get();

        final outroUsuarioData = outroUsuarioDoc.data() ?? {};

        conversas.add({
          'uidOutroUsuario': outroUid,
          'nome': outroUsuarioData['nome'] ?? 'Usuário',
          'fotoPerfil': outroUsuarioData['fotoPerfil'],
          'ultimoTexto': data['ultimoTexto'] ?? '',
          'ultimaMensagemEm': data['ultimaMensagemEm'],
        });
      }

      return conversas;
    } catch (e) {
      return [];
    }
  }
}
