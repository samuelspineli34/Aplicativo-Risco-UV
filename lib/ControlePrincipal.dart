import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:layout/ConfigurationPage.dart';
import 'package:weather/weather.dart';
import 'components/CustomAppBar.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'utilities/text_utils.dart';

WeatherFactory wf = WeatherFactory("bd5e378503939ddaee76f12ad7a97608",
    language: Language.PORTUGUESE_BRAZIL);

class ClimaPage extends StatelessWidget {
  final WeatherFactory weatherFactory;
  ClimaPage({required this.weatherFactory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        Title: 'Clima Atual',
        isBluetooth: true,
        isDiscovering: false,
      ),
      body: FutureBuilder<Weather>(
        future: weatherFactory.currentWeatherByLocation(-19.912998, -43.940933),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao buscar o clima.'));
          } else {
            Weather weather = snapshot.data!;

            String weatherDescription = weather.weatherDescription != null
              ? "${weather.weatherDescription?[0].toUpperCase()}${weather.weatherDescription?.substring(1)}"
              : "Céu limpo";

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    weatherDescription,
                    style: const TextStyle(
                      fontSize: 28, // Tamanho da fonte
                      color: Colors.black, // Cor do texto
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      formatTemperature(weather.temperature),
                      style: const TextStyle(
                        fontSize: 64, // Tamanho da fonte
                        color: Colors.black, // Cor do texto
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),

                  Container(
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resumo diário',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 24, // Tamanho da fonte
                            color: Colors.black, // Cor do texto
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        makeText(
                          "Sensação térmica de ${formatTemperature(weather.tempFeelsLike)} em ${weather.areaName}. "
                          "Hoje a temperatura pode variar entre ${formatTemperature(weather.tempMin)} e ${formatTemperature(weather.tempMax)}."
                        ),
                      ]
                    )
                  ),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.all(10.0),  
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color.fromRGBO(83, 83, 90, 1) // Cor de fundo
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.wind_power, color: Colors.white),
                            const SizedBox(height: 16.0),
                            makeText("${weather.windSpeed?.toStringAsFixed(2)} m/s", textColor: Colors.white, size: 14),
                            makeText("Vel. Vento", textColor: Colors.white, size: 14)
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.water_drop, color: Colors.white),
                            const SizedBox(height: 16.0),
                            makeText("${weather.humidity?.toStringAsFixed(2)} %", textColor: Colors.white, size: 14),
                            makeText("Umidade", textColor: Colors.white, size: 14)
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.cloud, color: Colors.white),
                            const SizedBox(height: 16.0),
                            makeText("${weather.cloudiness?.toStringAsFixed(2)} okta", textColor: Colors.white, size: 14),
                            makeText("Nebulosidade", textColor: Colors.white, size: 14),
                          ],
                        )
                      ],

                    )
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
                          CircularPercentIndicator(
                            radius: 100.0,
                            lineWidth: 10.0,
                            percent: 0.8,
                            header: const Text(
                              'Grau de Risco',
                              style: TextStyle(
                                fontWeight: FontWeight.bold, // Negrito
                                fontSize: 18, // Tamanho da fonte
                              )),
                            center: const Icon(
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
                            child: const Text("Clima"),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(237, 46, 39, 1))),
                            onPressed: () {
                              _printReceivedData();
                            },
                            child: const Text("Imprimir Dados"),
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
                            child: const Text("Configuração"),
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
