import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class BluetoothController extends GetxController {
  bool isScanning = false;

  Future bluetooth_escanear() async {
    isScanning = true;
    update(); // Notifique a mudança de estado

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 35));

    // Espere por 25 segundos
    await Future.delayed(Duration(seconds: 35));

    await FlutterBluePlus.stopScan();
    isScanning = false;
    update(); // Notifique a mudança de estado
    print("Fim do escaneamento");
  }

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
}
