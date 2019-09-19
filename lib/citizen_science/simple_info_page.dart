import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SimpleInfoPage extends StatefulWidget {
  final String title;
  final String content;

  const SimpleInfoPage({
    @required this.title,
    @required this.content,
  });

  @override
  _SimpleInfoPageState createState() => _SimpleInfoPageState();
}

class _SimpleInfoPageState extends State<SimpleInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    const String back = 'Zurück';

    return AppBar(
      leading: Tooltip(
        message: back,
        child: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                message: widget.title,
                child: Text(widget.title),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(widget.content),
      ),
    );
  }
}
