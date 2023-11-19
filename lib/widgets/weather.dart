import 'package:app_meteorologica/class.clima/clima.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherPage extends StatefulWidget {
  const WeatherPage({Key? key}) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late Future<Clima> futureClima;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureClima = fetchClima('honduras');
  }

  Future<Clima> fetchClima(String country) async {
    final response = await http.get(Uri.parse(
        'http://api.weatherapi.com/v1/current.json?key=c8eeaba6130f47a589e233355231811&q=$country&aqi=yes'));

    if (response.statusCode == 200) {
      return Clima.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al carga el clima :(');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima :)'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Escribe una ubicacion',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  futureClima = fetchClima(_controller.text);
                });
              },
              child: const Text('Buscar'),
            ),
            FutureBuilder<Clima>(
              future: futureClima,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                          'Ubicacion: ${snapshot.data!.location.name}, ${snapshot.data!.location.region}, ${snapshot.data!.location.country}'),
                      Text('Temperatura: ${snapshot.data!.current.tempC}°C'),
                      Text(
                          'Condicion: ${snapshot.data!.current.condition.text}'),
                      Text(
                          'Velocidad del viento: ${snapshot.data!.current.windKph} kph'),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}
