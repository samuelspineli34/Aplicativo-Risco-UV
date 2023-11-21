import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('UVC Seguro'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              // Substitua 'IP_DO_SEU_ESP32' pelo endereço IP do seu ESP32
              var response = await http.get(Uri.parse('http://192.168.4.1'));

              if (response.statusCode == 200) {
                print('Resposta do ESP32: ${response.body}');
              } else {
                print('Erro na solicitação ao ESP32: ${response.statusCode}');
              }
            },
            child: Text('Solicitar Leitura do Sensor'),
          ),
        ),
      ),
    );
  }
}
