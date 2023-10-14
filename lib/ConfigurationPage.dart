import 'package:flutter/material.dart';
import 'components/CustomAppBar.dart';

class ConfigurationPage extends StatefulWidget {
  @override
  _ConfigurationPageState createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  String selectedSkinColor = 'Nenhuma selecionada';
  int selectedAge = 23;
  String selectedCondition = 'Nenhuma selecionada';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        Title: 'Configuração',
        isBluetooth: false,
        onPress: () {},
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text('Cor de pele: $selectedSkinColor'),
              onTap: () {
                _showSkinColorDialog();
              },
            ),
            ListTile(
              title: Text('Idade: $selectedAge anos'),
              onTap: () {
                _showAgeDialog();
              },
            ),
            ListTile(
              title: Text('Condição: $selectedCondition'),
              onTap: () {
                _showConditionDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSkinColorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selecione a cor de pele'),
          content: Text('Implement your skin color selection here.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Salvar'),
              onPressed: () {
                // Update selectedSkinColor and save data
                selectedSkinColor = 'Updated Skin Color';
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAgeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Insira a idade'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              // Update selectedAge as the user types
              selectedAge = int.tryParse(value) ?? 0;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Salvar'),
              onPressed: () {
                // Save data and close the dialog
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showConditionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selecione a condição'),
          content: Text('Implement your condition selection here.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Salvar'),
              onPressed: () {
                // Update selectedCondition and save data
                selectedCondition = 'Updated Condition';
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
