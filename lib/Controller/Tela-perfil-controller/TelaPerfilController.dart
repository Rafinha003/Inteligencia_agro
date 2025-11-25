import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaPerfilController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔹 Obter dados do usuário logado
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

  // 🔹 Atualizar a descrição do perfil
  Future<void> atualizarDescricao(String descricao) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('Usuario').doc(user.uid).update({
      'descricao': descricao,
    });
  }

  // 🔹 Atualizar a foto de perfil
  Future<void> atualizarFotoPerfil(String base64Image) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception("Usuário não logado");

      await _firestore.collection('Usuario').doc(user.uid).update({
        'fotoPerfil': base64Image,
      });
    } catch (e) {
      print("Erro ao atualizar foto de perfil: $e");
      rethrow;
    }
  }

  // 🔹 Obter tipos de transação
  Future<List<String>> obterTipoTransacao() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('TipoTransacao').get();

      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data() as Map<String, dynamic>;
        if (data.containsKey('tipos') && data['tipos'] is List) {
          return List<String>.from(data['tipos']);
        }
      }

      return [];
    } catch (e) {
      print("Erro ao obter tipos de transação: $e");
      return [];
    }
  }

Future<void> salvarItem({
  required String nome,
  required String ano,
  required String descricao,
  required String tipoTransacao,
  required String tipoProduto,
  String? valor,
  String? dias,
  String? base64Image,
  String? estado,
  String? cidade,
  String? itemId,
}) async {
  try {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("Usuário não logado");

    final uid = user.uid;

    final planoDoc = await _firestore.collection("Planos").doc(uid).get();

    final tipoPlano = planoDoc.data()?["plano"]?.toString() ?? "Gratuito";

    int limite = 0;

    if (tipoPlano == "Gratuito") {
      limite = 5;
    } else if (tipoPlano == "Basico") {
      limite = 15;
    } else if (tipoPlano == "Premium") {
      limite = 9999999; 
    }


    final agora = DateTime.now();
    final inicioMes = DateTime(agora.year, agora.month, 1);
    final fimMes = DateTime(agora.year, agora.month + 1, 1);

    final query = await _firestore
        .collection("itens")
        .where("uidUsuario", isEqualTo: uid)
        .where("criadoEm", isGreaterThanOrEqualTo: inicioMes)
        .where("criadoEm", isLessThan: fimMes)
        .get();

    final quantidadeMes = query.docs.length;


    final bool isEdicao = itemId != null;

    if (!isEdicao && quantidadeMes >= limite) {
      throw Exception(
        "Você atingiu o limite do seu plano ($tipoPlano). "
        "Itens cadastrados este mês: $quantidadeMes / $limite",
      );
    }

    final data = {
      'uidUsuario': uid,
      'nome': nome,
      'ano': ano,
      'descricao': descricao,
      'tipoTransacao': tipoTransacao,
      'tipoProduto': tipoProduto,
      'valor': valor,
      'quantidadeDias': dias,
      'imagem': base64Image,
      'estado': estado,
      'cidade': cidade,
      'criadoEm': itemId == null ? DateTime.now() : FieldValue.serverTimestamp(),
    };

    if (itemId == null) {
      await _firestore.collection('itens').add(data);
    } else {
      await _firestore.collection('itens').doc(itemId).update(data);
    }
  } catch (e) {
    print("Erro ao salvar item: $e");
    rethrow;
  }
}


Future<List<Map<String, dynamic>>> obterPropostasEnviadas() async {
  try {
    User? user = _auth.currentUser;
    if (user == null) return [];

    QuerySnapshot snapshot = await _firestore
        .collection('propostas')
        .where('uidComprador', isEqualTo: user.uid)
        .get();

    List<Map<String, dynamic>> lista = [];

    for (var doc in snapshot.docs) {
      final proposta = doc.data() as Map<String, dynamic>;
      final id = doc.id;

      final itemRef =
          await _firestore.collection('itens').doc(proposta['uidItem']).get();
      final itemData = itemRef.data() ?? {};

      lista.add({
        'idProposta': id,
        'imagemItem': itemData['imagem'] ?? '',
        'nomeItem': itemData['nome'] ?? 'Sem nome',
        'status': proposta['status'] ?? 'pendente',
      });
    }

    return lista;
  } catch (e) {
    print("Erro ao obter enviados: $e");
    return [];
  }
}



 Future<List<Map<String, dynamic>>> obterItensUsuario() async {
  try {
    User? user = _auth.currentUser;
    if (user == null) return [];

    QuerySnapshot snapshot = await _firestore
        .collection('itens')
        .where('uidUsuario', isEqualTo: user.uid)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'nome': data['nome'] ?? '',
        'ano': data['ano'] ?? '',
        'descricao': data['descricao'] ?? '',
        'tipoTransacao': data['tipoTransacao'] ?? '',
        'tipoProduto': data['tipoProduto'] ?? '',
        'valor': data['valor'] ?? '',
        'quantidadeDias': data['quantidadeDias'] ?? '',
        'imagem': data['imagem'] ?? '',
        'estado': data['estado'] ?? '', 
        'cidade': data['cidade'] ?? '', 
      };
    }).toList();
  } catch (e) {
    print("Erro ao obter itens do usuário: $e");
    return [];
  }
}

 
  Future<String> converterImagemParaBase64(Uint8List bytes) async {
    img.Image? imagemDecode = img.decodeImage(bytes);
    if (imagemDecode != null) {
      img.Image imagemRedimensionada = img.copyResize(imagemDecode, width: 300);
      Uint8List bytesRedimensionados = Uint8List.fromList(
        img.encodeJpg(imagemRedimensionada, quality: 85),
      );
      return base64Encode(bytesRedimensionados);
    } else {
      throw Exception("Falha ao processar imagem");
    }
  }

  Future<List<Map<String, dynamic>>> obterPropostasDoUsuario() async {
  try {
    User? user = _auth.currentUser;
    if (user == null) return [];

    QuerySnapshot propostasSnapshot = await _firestore
        .collection('propostas')
        .where('uidVendedor', isEqualTo: user.uid)
        .get();

    List<Map<String, dynamic>> propostas = [];

    for (var doc in propostasSnapshot.docs) {
      final proposta = doc.data() as Map<String, dynamic>;
      final String idProposta = doc.id;

      if (proposta.containsKey('status') &&
          (proposta['status'] == 'aceito' || proposta['status'] == 'recusado')) {
        continue;
      }

      final itemRef = await _firestore.collection('itens').doc(proposta['uidItem']).get();
      final itemData = itemRef.data() as Map<String, dynamic>?;

      final compradorRef =
          await _firestore.collection('Usuario').doc(proposta['uidComprador']).get();
      final compradorData = compradorRef.data() as Map<String, dynamic>?;

      if (itemData != null && compradorData != null) {
        propostas.add({
          'idProposta': idProposta,
          'imagemItem': itemData['imagem'] ?? '',
          'nomeItem': itemData['nome'] ?? 'Sem nome',
          'nomeComprador': compradorData['nome'] ?? 'Desconhecido',
          'telefoneComprador': compradorData['telefone'] ?? 'Não informado',
        });
      }
    }
    return propostas;
  } catch (e) {
    print(" Erro ao obter propostas: $e");
    return [];
  }
}


  Future<void> atualizarStatusProposta(String idProposta, String status) async {
    try {
      if (status != 'aceito' && status != 'recusado') {
        throw Exception("Status inválido: $status");
      }

      await _firestore.collection('propostas').doc(idProposta).update({
        'status': status,
      });
    } catch (e) {
      print("Erro ao atualizar status da proposta: $e");
      rethrow;
    }
  }

  Future<void> excluirItem(String itemId) async {
  try {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("Usuário não logado");

    await _firestore.collection("itens").doc(itemId).delete();
  } catch (e) {
    print("Erro ao excluir item: $e");
    rethrow;
  }
}

}
