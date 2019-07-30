import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ThemeChangerProvider _themeChanger;

  String output = '0';
  String _output = '0';
  double num1 = 0.0;
  double num2 = 0.0;
  String operand = '';

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFabs(),
    );
  }

  Widget _buildAppBar() {
    final String calculator = 'Rechner';

    return AppBar(
      title: GestureDetector(
        onPanStart: (_) => _themeChanger.setTheme(),
        child: Container(
          width: double.infinity,
          child: Tooltip(
            message: calculator,
            child: Text(calculator),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.all(16.0),
              child: Text(
                output,
                style: TextStyle(fontSize: 42.0),
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildButton('7'),
                      _buildButton('8'),
                      _buildButton('9'),
                      _buildButton('/')
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('4'),
                      _buildButton('5'),
                      _buildButton('6'),
                      _buildButton('X')
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('1'),
                      _buildButton('2'),
                      _buildButton('3'),
                      _buildButton('-')
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('.'),
                      _buildButton('0'),
                      _buildButton('00'),
                      _buildButton('+')
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('CLEAR'),
                      _buildButton('='),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buttonPressed(String buttonText) {
    if (buttonText == 'CLEAR') {
      _output = '0';
      num1 = 0.0;
      num2 = 0.0;
      operand = '';
    } else if (buttonText == '+' ||
        buttonText == '-' ||
        buttonText == '/' ||
        buttonText == 'X') {
      num1 = double.parse(output);
      operand = buttonText;
      _output = '0';
    } else if (buttonText == '.') {
      if (_output.contains('.')) {
        return;
      } else {
        _output = _output + buttonText;
      }
    } else if (buttonText == '=') {
      num2 = double.parse(output);

      if (operand == '+') _output = (num1 + num2).toString();
      if (operand == '-') _output = (num1 - num2).toString();
      if (operand == 'X') _output = (num1 * num2).toString();
      if (operand == '/') _output = (num1 / num2).toString();

      num1 = 0.0;
      num2 = 0.0;
      operand = '';
    } else {
      _output = _output + buttonText;
    }

    setState(() {
      output = double.parse(_output).toStringAsFixed(2);
    });
  }

  Widget _buildButton(String buttonText) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(4.0),
        child: RaisedButton(
          onPressed: () => _buttonPressed(buttonText),
          child: Text(
            buttonText,
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      ),
    );
  }

  Widget _buildFabs() {
    return FloatingActionButton(
      onPressed: () => _copyContent(),
      child: Icon(Icons.content_copy),
    );
  }

  void _copyContent() {
    final String copyContent = 'Inhalt kopiert';
    final String copyNotPossible = 'Kein Inhalt zum kopieren';

    if (output.isNotEmpty) {
      _setClipboard(output, '$copyContent.');
    } else {
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBar(text: '$copyNotPossible.'),
      );
    }
  }

  void _setClipboard(String text, String snackText) {
    Clipboard.setData(
      ClipboardData(text: text),
    );

    _scaffoldKey.currentState.showSnackBar(
      _buildSnackBar(text: snackText),
    );
  }

  Widget _buildSnackBar({@required String text}) {
    return SnackBar(
      backgroundColor: Colors.black87,
      duration: Duration(milliseconds: 500),
      content: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
