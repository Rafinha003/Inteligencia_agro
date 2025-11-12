import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inteligencia_agro/View/Tela-chat/chat.dart';
import 'package:inteligencia_agro/View/tela-historico-transacao/tela-historico-transacao.dart';
import 'package:inteligencia_agro/View/tela-listagem/tela-listagem.dart';
import 'package:inteligencia_agro/View/tela-perfil/tela-perfil.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({Key? key}) : super(key: key);

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _indiceSelecionado = 0;
  String _planoUsuario = "Gratuito"; // padrão caso não carregue
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _carregarPlanoUsuario();
  }

  // Busca o plano do usuário no Firestore
  Future<void> _carregarPlanoUsuario() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DocumentSnapshot doc = await _firestore.collection("Planos").doc(user.uid).get();

    if (doc.exists) {
      setState(() {
        _planoUsuario = doc.get("plano") ?? "Gratuito";
      });
    }
  }

  // Gera a lista de telas dinamicamente
  List<Widget> get _telas {
    List<Widget> telas = [
      const TelaListagem(),
      const TelaChat(),
      const TelaPerfil(),
    ];

    // Adiciona histórico de transação apenas para planos pagos
    if (_planoUsuario != "Gratuito") {
      telas.insert(2, const TelaHistoricoTransacao());
    }

    return telas;
  }

  // Gera os ícones do bottomNavigationBar dinamicamente
  List<IconData> get _icones {
    List<IconData> icones = [
      Icons.home,
      Icons.chat,
      Icons.person,
    ];

    if (_planoUsuario != "Gratuito") {
      icones.insert(2, Icons.attach_money);
    }

    return icones;
  }

  void _onItemTapped(int index) {
    setState(() {
      _indiceSelecionado = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _telas[_indiceSelecionado],
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFF045006),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_icones.length, (index) {
              final bool isSelected = _indiceSelecionado == index;

              return GestureDetector(
                onTap: () => _onItemTapped(index),
                child: SizedBox(
                  width: 60,
                  height: 80,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      if (isSelected)
                        Positioned(
                          top: -35,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6CCF77).withOpacity(0.5),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6CCF77).withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                      AnimatedScale(
                        duration: const Duration(milliseconds: 250),
                        scale: isSelected ? 1.5 : 1.0,
                        child: Icon(
                          _icones[index],
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
