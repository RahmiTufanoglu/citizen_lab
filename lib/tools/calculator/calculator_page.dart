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

  String _out = '0';
  String output = '0';
  double _num1 = 0.0;
  double _num2 = 0.0;
  String _operand = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFabs(),
    );
  }

  Widget _buildAppBar() {
    const String calculator = 'Rechner';

    return AppBar(
      title: Consumer<ThemeChangerProvider>(
        builder: (
          BuildContext context,
          ThemeChangerProvider provider,
          Widget child,
        ) {
          return GestureDetector(
            onPanStart: (_) => provider.setTheme(),
            child: Container(
              width: double.infinity,
              child: Tooltip(
                message: calculator,
                child: const Text(calculator),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.all(16.0),
              child: Text(
                output,
                style: TextStyle(fontSize: 42.0),
              ),
            ),
            const Divider(),
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

  void _buttonPressed(String buttonText) {
    if (buttonText == 'CLEAR') {
      _out = '0';
      _num1 = 0.0;
      _num2 = 0.0;
      _operand = '';
    } else if (buttonText == '+' ||
        buttonText == '-' ||
        buttonText == '/' ||
        buttonText == 'X') {
      _num1 = double.parse(output);
      _operand = buttonText;
      _out = '0';
    } else if (buttonText == '.') {
      if (_out.contains('.')) {
        return;
      } else {
        _out = _out + buttonText;
      }
    } else if (buttonText == '=') {
      _num2 = double.parse(output);

      switch (_operand) {
        case '+':
          _out = (_num1 + _num2).toString();
          break;
        case '-':
          _out = (_num1 - _num2).toString();
          break;
        case 'X':
          _out = (_num1 - _num2).toString();
          break;
        case '/':
          _out = (_num1 / _num2).toString();
          break;
      }

      _num1 = 0.0;
      _num2 = 0.0;
      _operand = '';
    } else {
      _out = _out + buttonText;
    }

    setState(() => output = double.parse(_out).toStringAsFixed(2));
  }

  Widget _buildButton(String buttonText) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
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
    const String copyContent = 'Inhalt kopiert';
    const String copyNotPossible = 'Kein Inhalt zum kopieren';

    if (output.isNotEmpty) {
      _setClipboard(output, '$copyContent.');
    } else {
      _scaffoldKey.currentState.showSnackBar(
        _buildSnackBar(text: '$copyNotPossible.'),
      );
    }
  }

  void _setClipboard(String text, String snackText) {
    Clipboard.setData(ClipboardData(text: text));

    _scaffoldKey.currentState.showSnackBar(
      _buildSnackBar(text: snackText),
    );
  }

  Widget _buildSnackBar({@required String text}) {
    return SnackBar(
      backgroundColor: Colors.black87,
      duration: const Duration(milliseconds: 500),
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
