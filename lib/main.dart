import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:inteligencia_agro/View/Tela-escolha-plano/tela-escolha-plano.dart';
import 'package:inteligencia_agro/View/Tela-principal/tela-principal.dart';
import 'package:inteligencia_agro/View/tela-cadastro/tela-cadastro.dart';
import 'package:inteligencia_agro/View/tela-historico-transacao/tela-historico-transacao.dart';
import 'package:inteligencia_agro/View/tela-listagem/tela-listagem-detalhe/tela-listagem-detalhe.dart';
import 'package:inteligencia_agro/View/tela-listagem/tela-listagem.dart';
import 'package:inteligencia_agro/View/tela-login/tela-login.dart';
import 'package:inteligencia_agro/View/tela-perfil/tela-exibir-propostas/tela-exibir-propostas.dart';
import 'package:inteligencia_agro/View/tela-perfil/tela-perfil.dart';
import 'package:inteligencia_agro/View/tela-perfil/tela-ver-meus-itens/tela-ver-meus-itens.dart';
import 'package:inteligencia_agro/View/tela-recuperar-senha/tela-recuperar-senha.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(DevicePreview(enabled: true, builder: (context) => const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'Inteligência Agro',
  theme: ThemeData(primarySwatch: Colors.green),
  initialRoute: '/tela-login',
  routes: {
    '/tela-login': (context) => TelaLogin(),
    '/tela-cadastro': (context) => TelaCadastro(),
    '/tela-recuperar-senha': (context) => TelaRecuperarSenha(),
    '/tela-escolher-plano': (context) => TelaEscolhaPlano(),
    '/tela-principal': (context) => TelaPrincipal(),
    '/tela-perfil': (context) => TelaPerfil(),
    '/tela-ver-meus-itens': (context) => TelaVerMeusItens(),
    '/tela-listagem': (context) => TelaListagem(),
    '/tela-exibir-propostas': (context) => TelaExibirProposta(),
    '/tela-historico-transacao': (context) => TelaHistoricoTransacao()
  },

  onGenerateRoute: (settings) {
    if (settings.name == '/tela-listagem-detalhe') {
      final args = settings.arguments as Map<String, dynamic>;
      final itemId = args['itemId'];

      return MaterialPageRoute(
        builder: (context) => TelaListagemDetalhe(itemId: itemId),
      );
    }
    return null; 
  },
);
  }
}
