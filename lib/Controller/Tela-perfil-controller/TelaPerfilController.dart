import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaPerfilController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obter dados do usuário logado
  Future<Map<String, dynamic>?> obterUsuario() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    DocumentSnapshot doc = await _firestore.collection('Usuario').doc(user.uid).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  // Atualizar a descrição do perfil
  Future<void> atualizarDescricao(String descricao) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('Usuario').doc(user.uid).update({
      'descricao': descricao,
    });
  }

  Future<void> atualizarFotoPerfil(String base64Image) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("Usuário não logado");
      }

      await _firestore.collection('Usuario').doc(user.uid).update({
        'fotoPerfil': base64Image,
      });
    } catch (e) {
      print("Erro ao atualizar foto de perfil: $e");
      rethrow;
    }
  }

}
