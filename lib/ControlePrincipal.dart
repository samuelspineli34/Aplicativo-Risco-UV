import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:layout/ConfigurationPage.dart';
import 'package:weather/weather.dart';
import 'components/CustomAppBar.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:async';

WeatherFactory wf = WeatherFactory("bd5e378503939ddaee76f12ad7a97608",
    language: Language.PORTUGUESE_BRAZIL);

class ClimaPage extends StatelessWidget {
  final WeatherFactory weatherFactory;
  ClimaPage({required this.weatherFactory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        Title: 'Clima Atual',
        isBluetooth: true,
        isDiscovering: false,
      ),
      body: FutureBuilder<Weather>(
        future: weatherFactory.currentWeatherByLocation(-19.912998, -43.940933),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao buscar o clima.'));
          } else {
            Weather weather = snapshot.data!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 16.0),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Color.fromRGBO(237, 46, 39, 1), // Cor de fundo
                    ),
                    child: Text(
                      'Cidade: ${weather.areaName}',
                      style: TextStyle(
                        fontSize: 24, // Tamanho da fonte
                        color: Colors.white, // Cor do texto
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0), // Espaçamento entre os containers
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Color.fromRGBO(237, 46, 39, 1), // Cor de fundo
                    ),
                    child: Text(
                      'Temperatura: ${weather.temperature?.celsius?.toStringAsFixed(0)}°C',
                      style: TextStyle(
                        fontSize: 24, // Tamanho da fonte
                        color: Colors.white, // Cor do texto
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0), // Espaçamento entre os containers
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Color.fromRGBO(237, 46, 39, 1), // Cor de fundo
                    ),
                    child: Text(
                      'Descrição do Clima: ${weather.weatherDescription}',
                      style: TextStyle(
                        fontSize: 24, // Tamanho da fonte
                        color: Colors.white, // Cor do texto
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class ControlePrincipalPage extends StatefulWidget {
  final BluetoothDevice? server;
  final WeatherFactory weatherFactory;
  const ControlePrincipalPage({this.server, required this.weatherFactory});

  @override
  _ControlePrincipalPage createState() => _ControlePrincipalPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ControlePrincipalPage extends State<ControlePrincipalPage> {
  static const clientID = 0;
  BluetoothConnection? connection;
  String? language;
  List<_Message> messages = <_Message>[];
  String _messageBuffer = '';
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  bool isListening = false;
  bool isConnecting = true;
  bool get isConnected => connection != null && connection!.isConnected;
  bool isDisconnecting = false;
  bool buttonClicado = false;
  List<String> _languages = ['en_US', 'es_ES', 'pt_BR'];
  String receivedData = ""; // Variável para armazenar os dados recebidos

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server!.address).then((_connection) {
      print('Connected to device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      _receiveDataFromArduino(); // Start listening for data
    }).catchError((error) {
      print('Failed to connect, something is wrong!');
      print(error);
    });
  }

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      connection!.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
                (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_message.text.trim()),
                style: const TextStyle(color: Colors.white)),
            padding: const EdgeInsets.all(12.0),
            margin: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                    _message.whom == clientID ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
    }).toList();

    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(children: [
                          new CircularPercentIndicator(
                            radius: 100.0,
                            lineWidth: 10.0,s
                            percent: 0.8,
                            header: new Text(
                              'Grau de Risco',
                              style: TextStyle(
                                fontWeight: FontWeight.bold, // Negrito
                                fontSize: 18, // Tamanho da fonte
                              )),
                            center: new Icon(
                              Icons.sunny,
                              size: 50.0,
                              color: Color.fromRGBO(237, 46, 39, 1),
                            ),
                            backgroundColor: Colors.grey,
                            progressColor: Color.fromRGBO(237, 46, 39, 1),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(237, 46, 39, 1))),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ClimaPage(
                                      weatherFactory: widget.weatherFactory),
                                ),
                              );
                            },
                            child: Text("Clima"),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(237, 46, 39, 1))),
                            onPressed: () {
                              _printReceivedData();
                            },
                            child: Text("Imprimir Dados"),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(237, 46, 39, 1))),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    settings: const RouteSettings(name: '/'),
                                    builder: (context) => ConfigurationPage()),
                              );
                            },
                            child: Text("Configuração"),
                          ),
                        ]),
                      ]),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  void _receiveDataFromArduino() {
    // Verifique se a conexão está estabelecida
    if (isConnected && !isListening) {
      // Chame a função _onDataReceived para receber dados
      connection!.input!.listen(
        _onDataReceived,
        onError: (dynamic error) {
          print('Erro na conexão Bluetooth: $error');
          // Adicione código para lidar com o erro, como tentar reconectar.
        },
        onDone: () {
          print('Conexão Bluetooth encerrada pelo dispositivo remoto');
          // Adicione código para lidar com o encerramento da conexão.
        },
      );
      isListening = true; // Marque que estamos ouvindo o stream
    } else {
      print(
          'Erro: A conexão Bluetooth não está estabelecida ou já estamos ouvindo.');
    }
  }

  void _onDataReceived(Uint8List data) {
    print('Tamanho dos dados recebidos: ${data.length}');
    print('Dados recebidos: ${String.fromCharCodes(data)}');
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    for (var byte in data) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    }
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      receivedData = backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString.substring(0, index);
      print('Dados recebidos: $receivedData'); // Imprime os dados recebidos
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _printReceivedData() {
    print('Dados recebidos: $receivedData');
  }
}
