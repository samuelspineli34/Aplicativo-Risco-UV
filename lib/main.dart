import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'bluetooth_controller.dart';
import 'dart:async';

void main() async {
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
                    Timer(Duration(seconds: 34), () {
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
                        final filteredDevices = devices
                            .where((data) => data.device.name != null &&
                            data.device.name!.isNotEmpty)
                            .toList();
                        if (filteredDevices.isNotEmpty) {
                          return ListView.builder(
                            itemCount: filteredDevices.length,
                            itemBuilder: (context, index) {
                              final data = filteredDevices[index];
                              final deviceName = data.device.name!;
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
                            child: Text("Nenhum dispositivo Bluetooth encontrado com nome"),
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
