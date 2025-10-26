import 'package:flutter/material.dart';
import 'package:inteligencia_agro/View/tela-listagem/tela-listagem.dart';
import 'package:inteligencia_agro/View/tela-perfil/tela-perfil.dart';


class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({Key? key}) : super(key: key);

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _indiceSelecionado = 0;

  final List<IconData> _icones = [
    Icons.home,
    Icons.chat,
    Icons.attach_money,
    Icons.person,
  ];

  // Lista de telas que serão exibidas no body
  final List<Widget> _telas = [
    const TelaListagem(),
    const Center(child: Text("Chat", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
    const Center(child: Text("Financeiro", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
    const TelaPerfil(), // tela de perfil
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

      body: _telas[_indiceSelecionado], // renderiza a tela selecionada

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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
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
          ],
        ),
      ),
    );
  }
}
