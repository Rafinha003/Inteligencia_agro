import 'package:firebase_auth/firebase_auth.dart';

class AutenticacaoController{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

 Future<String?> cadastrarUsuario({required String email, required String senha}) async {
  try {
    await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: senha);
    return null; // Retorno explícito quando o cadastro é bem-sucedido
  } on FirebaseAuthException catch (e) {
    if (e.code == "email-already-in-use") {
      return "O email já foi cadastrado";
    }
    return e.message; // Retorna a mensagem de erro do Firebase
  } 
}


  Future<String?> LogarUsuario({required String email, required String senha}) async {

  try{
      await  _firebaseAuth.signInWithEmailAndPassword(email: email, password: senha);
      return null;
  } on FirebaseAuthException catch (e){

      if(e.message == 'The supplied auth credential is incorrect, malformed or has expired.'){
          return "O usuário não existe, por favor cadastre o usuário";
      }
      return e.message;
  }
}
}