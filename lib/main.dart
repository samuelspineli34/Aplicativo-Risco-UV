import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'bluetooth_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Solicite as permissões necessárias
  final permissions = [Permission.bluetooth, Permission.location];
  await permissions.request();

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key});

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
  const MyHomePage({required this.title, Key? key}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool scanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conexão Bluetooth App UV'),
      ),
      body: GetBuilder<BluetoothController>(
        init: BluetoothController(),
        builder: (controller) {
          return Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      scanning = true;
                    });
                    controller.bluetooth_escanear();
                    Timer(Duration(seconds: 5), () {
                      setState(() {
                        scanning = false;
                      });
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                  child: Text("Escanear dispositivos"),
                ),
              ),
              const SizedBox(height: 20),
              if (scanning)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else
                Expanded(
                  child: StreamBuilder<List<ScanResult>>(
                    stream: controller.scanResults,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final devices = snapshot.data!;
                        if (devices.isNotEmpty) {
                          return ListView.builder(
                            itemCount: devices.length,
                            itemBuilder: (context, index) {
                              final data = devices[index];
                              final deviceName = data.device.name ?? 'Desconhecido';
                              return Card(
                                elevation: 2,
                                child: ListTile(
                                  title: Text(deviceName),
                                  subtitle: Text(data.device.id.id),
                                ),
                              );
                            },
                          );
                        } else {
                          return const Center(
                            child: Text("Nenhum dispositivo Bluetooth encontrado"),
                          );
                        }
                      } else {
                        return const Center(
                          child: Text("Nenhum dispositivo encontrado"),
                        );
                      }
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
