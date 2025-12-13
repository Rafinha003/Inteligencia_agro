import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inteligencia_agro/Controller/Ibge/ibgeController.dart';
import 'package:inteligencia_agro/Model/CadastroModel.dart';

class CadastroController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final IbgeController _ibgeController = IbgeController();

  //METODO FIREBASE 
  Future<String?> cadastrarUsuario({
    required String email,
    required String senha,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        return "O email já foi cadastrado";
      }
      if (e.code == "weak-password") {
        return "A senha precisa ter mais de 6 caracteres";
      }
      if (e.code == "invalid-email") {
        return "O e-mail está inválido";
      }
      return e.message;
    }
  }

  Future<String?> criarUsuario({
    required String nome,
    required String email,
    required String telefone,
    required String cpfCnpj,
    required String estado,
    required String cidade,
    required String cep,
  }) async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user == null) {
        return "Erro ao criar o usuário.";
      }

      await _firestore.collection('Usuario').doc(user.uid).set({
        'uid': user.uid,
        'nome': nome,
        'email': email,
        'telefone': telefone,
        'cpfCnpj': cpfCnpj,
        'endereco': [
          {
            'estado': estado,
            'cidade': cidade,
            'cep': cep,
          }
        ],
        'dataCadastro': DateTime.now(),
      });

      return null;
    } catch (e) {
      return "Erro ao salvar dados do usuário: $e";
    }
  }

  //METODO BUSCAR NA API IBGE
  Future<List<Map<String, dynamic>>> buscarEstados() async {
    return await _ibgeController.buscarEstados();
  }

  Future<List<String>> buscarCidades(String estado) async {
    return await _ibgeController.buscarCidades(estado);
  }

  //METODO DE VALIDACAO
  bool isCpfInvalido(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length != 11 || RegExp(r'^(.)\1+$').hasMatch(cpf)) return true;

    List<int> numeros = cpf.split('').map(int.parse).toList();
    for (int j = 9; j < 11; j++) {
      int soma = 0;
      for (int i = 0; i < j; i++) {
        soma += numeros[i] * ((j + 1) - i);
      }
      int resto = (soma * 10) % 11;
      if (resto == 10) resto = 0;
      if (numeros[j] != resto) return true;
    }
    return false;
  }

 //METODO DA TELA 
  Future<String?> realizarCadastro(CadastroModel cadastro) async {
    // 1. Criar autenticação
    String? erro = await cadastrarUsuario(
      email: cadastro.email,
      senha: cadastro.senha,
    );
    if (erro != null) return erro;

    // 2. Salvar dados no Firestore
    String? erroCriar = await criarUsuario(
      nome: cadastro.nome,
      email: cadastro.email,
      telefone: cadastro.telefone,
      cpfCnpj: cadastro.cpfCnpj,
      estado: cadastro.estado,
      cidade: cadastro.cidade,
      cep: cadastro.cep,
    );

    if (erroCriar != null) return erroCriar;

    return null;
  }
}
