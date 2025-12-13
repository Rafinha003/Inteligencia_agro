 import 'package:intl/intl.dart';

String formatarValor(String valorOriginal) {
  if (valorOriginal.isEmpty) return "R\$ 0,00";

  String somenteNumeros = valorOriginal.replaceAll(RegExp(r'[^0-9]'), '');

  if (somenteNumeros.isEmpty) return "R\$ 0,00";

  double valorDouble;

  if (somenteNumeros.length == 2 && !somenteNumeros.startsWith('0')) {
    valorDouble = double.parse(somenteNumeros).toDouble();
  }

  else if (somenteNumeros.length == 3 && somenteNumeros.startsWith('0')) {
    String reais = "0";
    String centavos = somenteNumeros.substring(1);
    valorDouble = double.parse("$reais.$centavos");
  }

  else if (somenteNumeros.length <= 2) {
    valorDouble = double.parse(somenteNumeros) / 100;
  } else {
    String reais = somenteNumeros.substring(0, somenteNumeros.length - 2);
    String centavos = somenteNumeros.substring(somenteNumeros.length - 2);
    valorDouble = double.parse("$reais.$centavos");
  }

  final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  return formatter.format(valorDouble);
}