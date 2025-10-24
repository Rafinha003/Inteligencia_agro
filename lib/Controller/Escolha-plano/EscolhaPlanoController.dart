import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EscolhaPlanoController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> salvarPlanoEscolhido(String plano) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        return "Usuário não autenticado.";
      }

      // Data atual
      DateTime dataCompra = DateTime.now();

      // Data de validade (1 ano depois)
      DateTime dataValidade = DateTime(
        dataCompra.year + 1,
        dataCompra.month,
        dataCompra.day,
      );

      await _firestore.collection("Planos").doc(user.uid).set({
        "uid": user.uid,
        "plano": plano,
        "dataCompra": dataCompra,
        "dataValidade": dataValidade,
      });

      return null; // sucesso
    } catch (e) {
      return "Erro ao salvar plano: $e";
    }
  }
}
