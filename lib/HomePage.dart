// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:layout/SelecionarDispositivo.dart';
import 'package:layout/ControlePrincipal.dart';
import 'package:provider/provider.dart';
import 'components/CustomAppBar.dart';
import 'provider/StatusConexaoProvider.dart';
import 'package:weather/weather.dart';

WeatherFactory wf = WeatherFactory("bd5e378503939ddaee76f12ad7a97608", language: Language.PORTUGUESE_BRAZIL);


class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    onPressBluetooth() {
      return (() async {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            settings: const RouteSettings(name: 'selectDevice'),
            builder: (context) => const SelecionarDispositivoPage()));
      });
    }

    return Scaffold(
      appBar: CustomAppBar(
        Title: 'UVC Seguro',
        isBluetooth: true,
        isDiscovering: false,
        onPress: onPressBluetooth,

      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
          child: Consumer<StatusConexaoProvider>(
              builder: (context, StatusConnectionProvider, widget) {
            return (StatusConnectionProvider.device == null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bluetooth_disabled_sharp, size: 50),
                      const Text(
                        "Bluetooth desconectado",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      )
                    ],
                  )
                : ControlePrincipalPage(
                    server: StatusConnectionProvider.device,  weatherFactory: wf));
          }),
        ),
      ),
    );
  }
}
