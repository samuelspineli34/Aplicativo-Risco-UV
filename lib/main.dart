import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Bluetooth teste'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<BluetoothDevice> devices = []; // Lista de dispositivos encontrados
  Stopwatch? stopwatch; // Timer de tempo decorrido procurando a rede
  int elapsedTime = 0;


  void bluetooth_escanear() async {
    try {
      stopwatch = Stopwatch()..start();
      // Inicie a procura de redes bluetooths
      FlutterBluePlus.startScan(timeout: Duration(seconds: 40));

      // Configurar o StreamBuilder ou similar para exibir os dispositivos encontrados
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          if (!devices.contains(r.device)) {
            setState(() {
              devices.add(r.device);
            });
          }
        }
      });

      // Configurar um timer para atualizar o tempo decorrido a cada segundo
      Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          elapsedTime = stopwatch!.elapsed.inSeconds;
        });
      });


      // Aguarde o término da varredura
      await Future.delayed(Duration(seconds: 40));

      // Pare a varredura
      await FlutterBluePlus.stopScan();
    } catch (e) {
      print("Erro ao escanear: $e");
    }
  }

  void conectarDispositivo(BluetoothDevice device) async {
    try {
      await device.connect(); // Tenta conectar ao dispositivo
      stopwatch = Stopwatch()..start(); // Inicia o cronômetro
      // Implemente o que deseja fazer após a conexão bem-sucedida, como navegar para uma nova tela.
    } catch (e) {
      print("Erro ao conectar: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Conexão Bluetooth App UV'),
        ),
        body: SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Botão para iniciar a varredura
            Container(
                margin: EdgeInsetsDirectional.all(15),
                child: ElevatedButton(
                  onPressed: bluetooth_escanear,
                  child: Text('Iniciar Varredura'),
                )),
            Container(
                margin: EdgeInsetsDirectional.all(15),
                child: ElevatedButton(
                  onPressed: () {
                    devices
                        .clear(); // Limpa a lista de dispositivos encontrados
                    bluetooth_escanear(); // Inicia a varredura novamente
                  },
                  child: Text('Reiniciar Varredura'),
                )),

            // Lista de dispositivos encontrados
            ListView.builder(
              shrinkWrap: true,
              itemCount: devices.length,
              itemBuilder: (BuildContext context, int index) {
                final device = devices[index];

                // Verifique se o dispositivo tem um nome visível (localName)
                if (device.localName != null && device.localName.isNotEmpty) {
                  return ListTile(
                    title: Text(device.localName),
                    subtitle: Text(device.remoteId.toString()),
                    trailing: ElevatedButton(
                      onPressed: () => conectarDispositivo(device),
                      child: Text('Conectar'),
                    ),
                  );
                } else {
                  // Se o dispositivo não tiver um nome visível, retorne um widget vazio (não será exibido na lista)
                  return SizedBox.shrink();
                }
              },
            ),
            // Timer
            StreamBuilder<int>(
              stream: Stream.periodic(Duration(seconds: 1))
                  .where((_) => stopwatch != null)
                  .map((_) => elapsedTime),
              builder: (context, snapshot) {
                return Text(
                  'Tempo decorrido de procura: ${snapshot.data ?? 0} segundos',
                  style: TextStyle(fontSize: 16),
                );
              },
            ),



          ],
        ),
      ),
    ));
  }
}
