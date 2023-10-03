import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class BluetoothController extends GetxController {
  bool isScanning = false;

  Future bluetooth_escanear() async {
    isScanning = true;
    update(); // Notifique a mudança de estado

    print("Iniciando varredura Bluetooth");
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    print("Varredura Bluetooth em andamento...");
    await Future.delayed(Duration(seconds: 5));
    print("Parando a varredura Bluetooth");
    await FlutterBluePlus.stopScan();
    print("Varredura Bluetooth concluída");

    isScanning = false;
    update(); // Notifique a mudança de estado
    print("Fim do escaneamento");
  }

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
}
