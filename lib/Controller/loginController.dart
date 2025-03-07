import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? usuario;

  // Método para realizar o login com email e senha
  void login(String email, String password, Function(User? user) onLoginComplete) {
    _auth.signInWithEmailAndPassword(email: email, password: password)
      .then((UserCredential userCredential) {
        // Chama o callback passando o usuário autenticado
        onLoginComplete(userCredential.user);
      }).catchError((e) {
        print("Erro ao fazer login: $e");
        onLoginComplete(null); // Passa null em caso de erro
      });
  }

  // Método para iniciar a escuta das mudanças no estado de autenticação
  void startListeningAuthState() {
    _auth.authStateChanges().listen((User? user) {
      usuario = user; // Atualiza o usuário com base no estado de autenticação
      notifyListeners(); // Notifica que o estado de autenticação foi alterado
    });
  }

  // Método para deslogar
  Future<void> logout() async {
    await _auth.signOut();
  }
}
