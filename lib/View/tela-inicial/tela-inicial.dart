import 'package:flutter/material.dart';

class TelaInicial extends StatelessWidget {
  final List<Map<String, dynamic>> produtos = [
    {
      'nome': 'Produto 1',
      'preco': 'R\$ 50,00',
      'imagem':
          'https://www.bing.com/images/search?view=detailV2&ccid=sX6NenLe&id=490E7DCC06E47773F6762985CEC072BC1BB6179C&thid=OIP.sX6NenLeDO6szc7SQXRBEgHaEK&mediaurl=https%3a%2f%2fwww.deere.com.br%2fassets%2fimages%2fregion-3%2fproducts%2fnutrient-application%2fsprayer-m4040%2fr3c006531_NK_pulverizador_m4040_foto_no_campo_large_475c87a6d7b39d14322e3c6ce8f2e0695021fb67.jpg&cdnurl=https%3a%2f%2fth.bing.com%2fth%2fid%2fR.b17e8d7a72de0ceeaccdced241744112%3frik%3dnBe2G7xywM6FKQ%26pid%3dImgRaw%26r%3d0&exph=768&expw=1366&q=equipamento+agricola&simid=608033706512682530&FORM=IRPRST&ck=FAB62AACBC26C15B8451BE79CA7182A5&selectedIndex=8&itb=0',
    },
    {
      'nome': 'Produto 2',
      'preco': 'R\$ 75,00',
      'imagem':
          'https://www.bing.com/images/search?view=detailV2&ccid=sX6NenLe&id=490E7DCC06E47773F6762985CEC072BC1BB6179C&thid=OIP.sX6NenLeDO6szc7SQXRBEgHaEK&mediaurl=https%3a%2f%2fwww.deere.com.br%2fassets%2fimages%2fregion-3%2fproducts%2fnutrient-application%2fsprayer-m4040%2fr3c006531_NK_pulverizador_m4040_foto_no_campo_large_475c87a6d7b39d14322e3c6ce8f2e0695021fb67.jpg&cdnurl=https%3a%2f%2fth.bing.com%2fth%2fid%2fR.b17e8d7a72de0ceeaccdced241744112%3frik%3dnBe2G7xywM6FKQ%26pid%3dImgRaw%26r%3d0&exph=768&expw=1366&q=equipamento+agricola&simid=608033706512682530&FORM=IRPRST&ck=FAB62AACBC26C15B8451BE79CA7182A5&selectedIndex=8&itb=0',
    },
    {
      'nome': 'Produto 3',
      'preco': 'R\$ 100,00',
      'imagem':
          'https://www.bing.com/images/search?view=detailV2&ccid=sX6NenLe&id=490E7DCC06E47773F6762985CEC072BC1BB6179C&thid=OIP.sX6NenLeDO6szc7SQXRBEgHaEK&mediaurl=https%3a%2f%2fwww.deere.com.br%2fassets%2fimages%2fregion-3%2fproducts%2fnutrient-application%2fsprayer-m4040%2fr3c006531_NK_pulverizador_m4040_foto_no_campo_large_475c87a6d7b39d14322e3c6ce8f2e0695021fb67.jpg&cdnurl=https%3a%2f%2fth.bing.com%2fth%2fid%2fR.b17e8d7a72de0ceeaccdced241744112%3frik%3dnBe2G7xywM6FKQ%26pid%3dImgRaw%26r%3d0&exph=768&expw=1366&q=equipamento+agricola&simid=608033706512682530&FORM=IRPRST&ck=FAB62AACBC26C15B8451BE79CA7182A5&selectedIndex=8&itb=0',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela Inicial'),
        backgroundColor: Color(0xFF045006),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: produtos.length,
          itemBuilder: (context, index) {
            final produto = produtos[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(8.0),
                leading: Image.network(
                  produto['imagem'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
                title: Text(
                  produto['nome'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(produto['preco']),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: Text('Ver detalhes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3FAF47),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Color(0xFF00897B),
        child: Icon(Icons.add),
      ),
    );
  }
}
