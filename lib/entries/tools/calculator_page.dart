import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'calculator_button.dart';

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _calcEditingController = TextEditingController();

  ThemeChangerProvider _themeChanger;

  List<CalculatorButton> _calculatorButtonList = [];

  int count = 0;

  @override
  void initState() {
    List<CalculatorButton> list = [
      CalculatorButton(false, 'C', null, null),
      CalculatorButton(false, '', null, null),
      CalculatorButton(false, '%', null, null),
      CalculatorButton(false, '/', null, null),
      CalculatorButton(false, '7', null, null),
      CalculatorButton(false, '8', null, null),
      CalculatorButton(false, '9', null, null),
      CalculatorButton(false, 'x', null, null),
      CalculatorButton(false, '4', null, null),
      CalculatorButton(false, '5', null, null),
      CalculatorButton(false, '6', null, null),
      CalculatorButton(false, '-', null, null),
      CalculatorButton(false, '1', null, null),
      CalculatorButton(false, '2', null, null),
      CalculatorButton(false, '3', null, null),
      CalculatorButton(true, '+', null, null),
      CalculatorButton(false, '', null, null),
      CalculatorButton(false, '0', null, null),
      CalculatorButton(false, '.', null, null),
      CalculatorButton(false, '=', null, null),
    ];

    for (int i = 0; i < list.length; i++) {
      _calculatorButtonList.add(list[i]);
    }

    super.initState();
  }

  @override
  void dispose() {
    _calcEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);
    _themeChanger.checkIfDarkModeEnabled(context);

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFabs(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: GestureDetector(
        //onPanStart: (_) => _enableDarkMode(),
        onPanStart: (_) => _themeChanger.setTheme(),
        child: Container(
          width: double.infinity,
          child: Tooltip(
            message: '',
            child: Text('CALC'),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          TextFormField(
            controller: _calcEditingController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 28.0,
            ),
          ),
          RaisedButton(
            child: Text('Berechne'),
            onPressed: () => _checkOperation(),
          ),
        ],
      ),
    );
  }

  void _checkOperation() {
    String s1 = _calcEditingController.text;
    String s = s1.replaceAll(RegExp(r"\s\b|\b\s"), '');

    /*List<String> list = [];

    for (int i = 0; i < list.length; i++) {
      String tmp = s.substring(count, s.indexOf(' '));
      count = tmp.length;
      list.add(s.substring(count, s.indexOf(' ')));
    }*/

    List<String> strNumber = [];
    List<int> doubleNumber = [];

    //print(stringLength);

    /*String tmp;
    int count = 0;
    int index;
    for (int i = 0; i < stringLength; i++) {
      if (s.contains('+')) {
        index = s.indexOf('+');
        //print(index);
        tmp = s.substring(count, index);
        number.add(int.parse(tmp));
        //i = index;
      }
    }*/

    for (int i = 0; i < s.length; i++) {
      if (s[i] != '+') {
        strNumber.add(s[i]);
      } else {
        //doubleNumber.add(int.parse(strNumber[i]));
        break;
      }
    }

    print('ERG: ${strNumber[0]}');
  }

  Widget _buildFabs() {
    return FloatingActionButton(
      child: Icon(Icons.content_copy),
      onPressed: () {},
    );
  }
}
