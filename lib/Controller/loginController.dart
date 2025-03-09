import 'package:firebase_auth/firebase_auth.dart';

class LoginController{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> LogarUsuario({required String email, required String senha}) async {

  try{
      await  _firebaseAuth.signInWithEmailAndPassword(email: email, password: senha);
      return null;
  } on FirebaseAuthException catch (e){
      print(e.message);
      if(e.message == 'The supplied auth credential is incorrect, malformed or has expired.'){
          return "O usuário não existe, por favor cadastre o usuário";
      }
      return e.message;
  }
}
}