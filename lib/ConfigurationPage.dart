import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/CustomAppBar.dart';
import 'package:multiselect/multiselect.dart';

class ConfigurationPage extends StatefulWidget {
  @override
  _ConfigurationPageState createState() => _ConfigurationPageState();
}

const List<String> skinColors = ['Nenhuma selecionada', 'extremamente branca', 'branca', 'morena clara', 'morena', 'morena escura', 'negra'];
const List<String> conditions = ['Albinismo', 'Imunossupressão', 'Xeroderma pigmentoso', 'Histórico familiar'];

class _ConfigurationPageState extends State<ConfigurationPage> {
  String selectedSkinColor = 'Nenhuma selecionada';
  int selectedAge = 23;
  List<String> selectedConditions = [];

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
            const Text("Raça/Cor da pele: "),
            DropdownMenu<String>(
              initialSelection: selectedSkinColor,
              textStyle: const TextStyle(
                fontStyle: FontStyle.normal
              ),
              onSelected: (String? value) {
                // This is called when the user selects an item.
                setState(() {
                  selectedSkinColor = value!;
                });
              },
              dropdownMenuEntries: skinColors.map<DropdownMenuEntry<String>>((String value) {
                return DropdownMenuEntry<String>(value: value, label: value);
              }).toList(),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 20)),
            const Text("Idade: "),
            const Padding(padding: EdgeInsets.only(bottom: 10)),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Idade"
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ], // Only numbers can be entered
              onChanged: (String? value) {
                setState(() {
                  selectedAge = int.parse(value!);  
                });
              }
            ),
            const Padding(padding: EdgeInsets.only(bottom: 20)),
            const Text("Condições: "),
            const Padding(padding: EdgeInsets.only(bottom: 10)),
            DropDownMultiSelect(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Escolha alguma condição de saúde",
              ),
              options: conditions,
		          selectedValues: selectedConditions,
		          onChanged: (value) {
                setState(() {
                  selectedConditions = value as List<String>;
                });
              },
            )
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
                selectedConditions = ['Updated Condition'];
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


}
