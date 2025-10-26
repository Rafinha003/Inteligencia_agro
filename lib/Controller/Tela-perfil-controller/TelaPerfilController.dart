import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
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

   Future<List<String>> obterTipoTransacao() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('TipoTransacao').get();

      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data() as Map<String, dynamic>;
        if (data.containsKey('tipos') && data['tipos'] is List) {
          return List<String>.from(data['tipos']);
        }
      }

      return []; // retorna lista vazia caso não tenha nada
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
  String? valor,
  String? dias,
  String? base64Image,
}) async {
  try {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("Usuário não logado");

    await _firestore.collection('itens').add({
      'uidUsuario': user.uid,
      'nome': nome,
      'ano': ano,
      'descricao': descricao,
      'tipoTransacao': tipoTransacao,
      'valor': valor,
      'quantidadeDias': dias,
      'imagem': base64Image,
      'criadoEm': DateTime.now(), // data do dia de hoje
    });
  } catch (e) {
    print("Erro ao salvar item: $e");
    rethrow;
  }
}


  // 🔹 Função utilitária: converte imagem para base64 <= 1MB
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
          'nome': data['nome'] ?? '',
          'ano': data['ano'] ?? '',
          'tipoTransacao': data['tipoTransacao'] ?? '',
          'valor': data['valor'] ?? '',
          'imagem': data['imagem'] ?? '', // ✅ adiciona imagem
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }
}


