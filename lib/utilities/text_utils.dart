import 'package:flutter/material.dart';
import 'package:weather/weather.dart';

String formatTemperature(Temperature? tmp) {
  return "${tmp?.celsius?.toStringAsFixed(0)}°C";
}


Text makeText(String str, {Color textColor = Colors.black, double size = 18.0 }) {
  return Text(
    str,
    style: TextStyle(
      fontSize: size, // Tamanho da fonte
      color: textColor // Cor do texto
    )
  );
}