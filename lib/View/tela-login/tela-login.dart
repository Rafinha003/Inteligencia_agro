import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView( 
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.grass, size: 50, color: Colors.green),
              ),
              SizedBox(height: 16),
              Text(
                'Inteligência Agro',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Serif'),
              ),
              Text(
                'Facilitando negócios e parcerias no mundo rural',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Usuário',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true, // Oculta a senha
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Lógica para recuperar senha
                  },
                  child: Text('Esqueceu a senha?', style: TextStyle(color: Color(0xFF00897B)),),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Lógica de login
                },
                child: Text('Login',  style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF045006)
                ),
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  // Lógica para criar conta
                },
                child: Text('Criar conta', style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                   minimumSize: Size(double.infinity, 50),
                     backgroundColor: Color(0xFF3FAF47),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}