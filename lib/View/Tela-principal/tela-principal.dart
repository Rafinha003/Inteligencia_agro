import 'package:flutter/material.dart';
import 'package:inteligencia_agro/View/Tela-chat/chat.dart';
import 'package:inteligencia_agro/View/tela-listagem/tela-listagem.dart';
import 'package:inteligencia_agro/View/tela-perfil/tela-perfil.dart';
import 'package:inteligencia_agro/View/tela-historico-transacao/tela-historico-transacao.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({Key? key}) : super(key: key);

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _indiceSelecionado = 0;

  List<Widget> get _telas => const [
        TelaListagem(),
        TelaChat(),
        TelaHistoricoTransacao(),
        TelaPerfil(),
      ];

  List<IconData> get _icones => const [
        Icons.home,
        Icons.chat,
        Icons.attach_money,
        Icons.person,
      ];

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
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6CCF77).withOpacity(0.35),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6CCF77)
                                      .withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        ),

                      AnimatedScale(
                        duration: const Duration(milliseconds: 250),
                        scale: isSelected ? 1.35 : 1.0,
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
