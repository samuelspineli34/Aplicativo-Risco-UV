import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:layout/ListaBluetooth.dart';
import 'package:layout/HomePage.dart';
import 'package:layout/provider/StatusConexaoProvider.dart';
import 'package:provider/provider.dart';
import 'components/CustomAppBar.dart';

class SelecionarDispositivoPage extends StatefulWidget {
  final bool checkAvailability;

  const SelecionarDispositivoPage({this.checkAvailability = true});

  @override
  _SelecionarDispositivoPageState createState() =>
      _SelecionarDispositivoPageState();
}

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class _DeviceWithAvailability extends BluetoothDevice {
  BluetoothDevice? device;
  _DeviceAvailability? availability;
  int? rssi;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi])
      : super(address: device!.address);
}

class _SelecionarDispositivoPageState extends State<SelecionarDispositivoPage> {
  List<_DeviceWithAvailability> devices = <_DeviceWithAvailability>[];
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
  bool? _isDiscovering;

  @override
  void initState() {
    super.initState();
    _discoveryStreamSubscription = null; // Inicializa como null

    _isDiscovering = widget.checkAvailability;

    if (_isDiscovering!) {
      _startDiscovery();
    }

    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        devices = bondedDevices
            .map(
              (device) => _DeviceWithAvailability(
            device,
            widget.checkAvailability
                ? _DeviceAvailability.maybe
                : _DeviceAvailability.yes,
          ),
        )
            .toList();
      });
    });
  }

  void _startDiscovery() {
    _discoveryStreamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
          if (r.device.address == '1B:DF:2B:11:7B:B6') {
            // O dispositivo possui o endereço MAC do arduino
            setState(() {
              devices.clear(); // Limpa a lista atual
              devices.add(_DeviceWithAvailability(
                r.device,
                _DeviceAvailability.yes,
                r.rssi,
              ));
            });

            // Cancela a descoberta após encontrar o dispositivo desejado.
            _discoveryStreamSubscription!.cancel();
          }
        });

    _discoveryStreamSubscription!.onDone(() {
      setState(() {
        _isDiscovering = false;
      });
    });
  }


  @override
  void dispose() {
    _discoveryStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<ListaBluetoothPage> list = devices
        .map(
          (_device) => ListaBluetoothPage(
        device: _device.device,
        onTap: () {
          Provider.of<StatusConexaoProvider>(context, listen: false)
              .setDevice(_device.device!);
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              settings: const RouteSettings(name: '/'),
              builder: (context) => HomePage()));
        },
      ),
    )
        .toList();
    return Scaffold(
      appBar: CustomAppBar(
        Title: 'Bluetooth List',
        isBluetooth: false,
        isDiscovering: _isDiscovering!,
        onPress: () {},
      ),
      body: ListView(
        children: list,
      ),
    );
  }
}
