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

      DateTime dataCompra = DateTime.now();

      DateTime dataValidade = DateTime(
        dataCompra.year + 1,
        dataCompra.month,
        dataCompra.day,
      );

      DocumentReference planoRef = _firestore.collection("Planos").doc(user.uid);
      DocumentSnapshot planoSnapshot = await planoRef.get();

      if (planoSnapshot.exists) {
        await planoRef.update({
          "plano": plano,
          "dataValidade": dataValidade,
          "dataAlteracaoPlano": dataCompra,
        });
      } else {
        await planoRef.set({
          "uid": user.uid,
          "plano": plano,
          "dataCompra": dataCompra,
          "dataValidade": dataValidade,
        });
      }

      return null; 
    } catch (e) {
      return "Erro ao salvar plano: $e";
    }
  }
}
