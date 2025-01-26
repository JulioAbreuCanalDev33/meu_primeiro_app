import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  ThemeData _buildTheme() {
    return ThemeData(
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor:
          _isDarkMode ? Colors.grey[900] : Colors.blue[100],
      primarySwatch: Colors.blue,
      appBarTheme: AppBarTheme(
        backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.blue,
        foregroundColor: _isDarkMode ? Colors.white : Colors.black,
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: _isDarkMode ? Colors.white : Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: _isDarkMode ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de Juros Compostos',
      theme: _buildTheme(),
      home: MyHomePage(
        toggleTheme: () {
          setState(() {
            _isDarkMode = !_isDarkMode;
          });
        },
        isDarkMode: _isDarkMode,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  MyHomePage({required this.toggleTheme, required this.isDarkMode});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  double valorInicial = 0.0;
  double valorMensal = 0.0;
  double jurosAnual = 0.0;
  int tempoMeses = 0;
  String resultado = "";

  String _calcularJurosCompostos() {
    if (valorInicial == 0 && valorMensal == 0) {
      return "Insira um valor inicial ou aporte mensal.";
    }

    double jurosMensal = pow(1 + jurosAnual, 1 / 12) - 1;
    double montante = valorInicial;
    double capitalInvestido = valorInicial;

    for (int i = 1; i <= tempoMeses; i++) {
      montante = (montante + valorMensal) * (1 + jurosMensal);
      capitalInvestido += valorMensal;
    }

    double jurosAcumulados = montante - capitalInvestido;

    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return "Resultado:\n"
        "Capital Investido: ${currencyFormat.format(capitalInvestido)}\n"
        "Juros Acumulados: ${currencyFormat.format(jurosAcumulados)}\n"
        "Montante Final: ${currencyFormat.format(montante)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora de Juros Compostos'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              SystemNavigator.pop(); // Fecha o aplicativo
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            children: [
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Valor inicial de aporte (R\$)',
                ),
                style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black),
                validator: (value) {
                  if (value == null ||
                      double.tryParse(value) == null ||
                      double.parse(value) < 0) {
                    return 'Insira um valor inicial válido (positivo).';
                  }
                  return null;
                },
                onSaved: (newValue) => valorInicial = double.parse(newValue!),
              ),
              SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Valor mensal de aporte (R\$)',
                ),
                style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black),
                validator: (value) {
                  if (value == null ||
                      double.tryParse(value) == null ||
                      double.parse(value) < 0) {
                    return 'Insira um valor mensal válido (positivo).';
                  }
                  return null;
                },
                onSaved: (newValue) => valorMensal = double.parse(newValue!),
              ),
              SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Taxa de juros anual (%)',
                ),
                style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black),
                validator: (value) {
                  if (value == null ||
                      double.tryParse(value) == null ||
                      double.parse(value) < 0) {
                    return 'Insira uma taxa de juros válida (positiva).';
                  }
                  return null;
                },
                onSaved: (newValue) =>
                    jurosAnual = double.parse(newValue!) / 100,
              ),
              SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Tempo investido (meses)',
                ),
                style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black),
                validator: (value) {
                  if (value == null ||
                      int.tryParse(value) == null ||
                      int.parse(value) < 0) {
                    return 'Insira um tempo de investimento válido (positivo).';
                  }
                  return null;
                },
                onSaved: (newValue) => tempoMeses = int.parse(newValue!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    setState(() {
                      resultado = _calcularJurosCompostos();
                    });
                  } else {
                    setState(() {
                      resultado = "";
                    });
                  }
                },
                child: Text('Calcular'),
              ),
              if (resultado.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    resultado,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.toggleTheme,
        child:
            Icon(widget.isDarkMode ? Icons.brightness_7 : Icons.brightness_4),
      ),
    );
  }
}
