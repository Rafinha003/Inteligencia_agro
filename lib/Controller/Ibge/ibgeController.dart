import 'dart:convert';
import 'package:http/http.dart' as http;

class IbgeController {
  Future<List<Map<String, dynamic>>> buscarEstados() async {
    final url = Uri.parse('https://servicodados.ibge.gov.br/api/v1/localidades/estados');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      data.sort((a, b) => a['nome'].compareTo(b['nome']));
      return data.map((estado) => {
        'sigla': estado['sigla'],
        'nome': estado['nome'],
      }).toList();
    } else {
      throw Exception('Erro ao carregar estados');
    }
  }

  Future<List<String>> buscarCidades(String uf) async {
    final url = Uri.parse('https://servicodados.ibge.gov.br/api/v1/localidades/estados/$uf/municipios');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      data.sort((a, b) => a['nome'].compareTo(b['nome']));
      return data.map((cidade) => cidade['nome'].toString()).toList();
    } else {
      throw Exception('Erro ao carregar cidades');
    }
  }
}
