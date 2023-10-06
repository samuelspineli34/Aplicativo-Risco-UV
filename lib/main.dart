import 'package:flutter/material.dart';
import 'package:layout/SelecionarDispositivo.dart';
import 'package:layout/HomePage.dart';
import 'package:provider/provider.dart';
import 'provider/StatusConexaoProvider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // Solicite as permissões necessárias
  final permissions = [Permission.bluetooth, Permission.location, Permission.bluetoothScan, Permission.bluetoothConnect, Permission.bluetoothAdvertise];
  await permissions.request();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Solicite permissão antes de iniciar o aplicativo
      future: _requestBluetoothPermission(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<StatusConexaoProvider>.value(
                value: StatusConexaoProvider(),
              ),
            ],
            child: MaterialApp(
              title: 'Xerocasa',
              initialRoute: '/',
              routes: {
                '/': (context) => HomePage(),
                '/selectDevice': (context) => const SelecionarDispositivoPage(),
              },
            ),
          );
        } else {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      }
    );
  }

  Future<void> _requestBluetoothPermission() async {
    final permissions = await Permission.bluetooth.request();
    if (!permissions.isGranted) {
      // Trate o caso em que a permissão não é concedida aqui
    }

}
}
