import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:citizen_lab/constants.dart';
import 'package:citizen_lab/custom_stroke.dart';
import 'package:citizen_lab/flat_alert_dialog_button.dart';
import 'package:citizen_lab/painter_widget.dart';
import 'package:citizen_lab/simple_alert_dialog_with_icon.dart';
import 'package:citizen_lab/utils.dart';
import 'package:share/share.dart';

class SketchPage extends StatefulWidget {
  @override
  _SketchPageState createState() => _SketchPageState();
}

class ShakeCurve extends Curve {
  @override
  double transform(double t) => sin(t * pi * 2);
}

class _SketchPageState extends State<SketchPage>
    with SingleTickerProviderStateMixin {
  List<CustomStroke> strokes = [];

  Color currentColor;
  double currentStrokeWidth;

  //
  //ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  //Canvas canvas;

  @override
  void initState() {
    currentColor = Colors.black;
    currentStrokeWidth = 4.0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final PainterWidget painter = PainterWidget(
      strokes: strokes,
      color: currentColor,
      strokeWidth: currentStrokeWidth,
    );

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(painter),
      floatingActionButton: _buildFabs(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        tooltip: 'Zurück',
        icon: Icon(
          Icons.arrow_back,
          color: Colors.black,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Sketch',
        style: TextStyle(color: Colors.black),
      ),
      elevation: 2.0,
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.black),
      actions: <Widget>[
        InkWell(
            child: Padding(
              padding: const EdgeInsets.only(
                right: 16.0,
                left: 16.0,
              ),
              child: Icon(Icons.refresh),
            ),
            onTap: () {
              clearPaintedScreen();
            }),
        InkWell(
          child: Padding(
            padding: const EdgeInsets.only(
              right: 16.0,
              left: 16.0,
            ),
            child: Icon(Icons.info_outline),
          ),
          onTap: () => _buildInfoDialog(),
        ),
      ],
    );
  }

  Widget _buildBody(PainterWidget painter) {
    return GestureDetector(
      child: CustomPaint(
        foregroundPainter: painter,
        isComplex: true,
        willChange: false,
        child: Container(
          color: Colors.white,
        ),
      ),
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
    );
  }

  void onPanStart(DragStartDetails details) =>
      addStroke(details.globalPosition);

  void onPanUpdate(DragUpdateDetails details) =>
      addStroke(details.globalPosition);

  void onPanEnd(DragEndDetails details) {
    setState(() {
      strokes = List.of(strokes)..add(null);
    });
  }

  void clearPaintedScreen() {
    strokes.clear();
  }

  void clearLast() {
    //TODO
  }

  void addStroke(Offset globalPosition) {
    final Offset offset = Utils.localPosition(context, globalPosition);

    final CustomStroke customStroke = CustomStroke(
      color: currentColor,
      strokeWidth: currentStrokeWidth,
      offset: offset,
    );

    setState(() {
      strokes = List.of(strokes)..add(customStroke);
    });
  }

  Future<bool> _buildInfoDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => Theme(
            data: Theme.of(context).copyWith(
              dialogBackgroundColor: Colors.white,
            ),
            child: AlertDialog(
              contentPadding: const EdgeInsets.all(0.0),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
              content: Container(
                height: 500.0,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 9,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PageView(
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                Positioned(
                                  top: 200.0,
                                  right: 0.0,
                                  child: Icon(
                                    Icons.arrow_right,
                                    color: Colors.black,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: 16.0,
                                    bottom: 8.0,
                                    top: 8.0,
                                    left: 8.0,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            'Hinweis 1',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 16.0),
                                          Text(
                                            lorem + lorem,
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Stack(
                              children: <Widget>[
                                Positioned(
                                  top: 200.0,
                                  left: 0.0,
                                  child: Icon(
                                    Icons.arrow_left,
                                    color: Colors.black,
                                  ),
                                ),
                                Positioned(
                                  top: 200.0,
                                  right: 0.0,
                                  child: Icon(
                                    Icons.arrow_right,
                                    color: Colors.black,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: 16.0,
                                    bottom: 8.0,
                                    top: 8.0,
                                    left: 16.0,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            'Hinweis 2',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 16.0),
                                          Text(
                                            lorem + lorem,
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Stack(
                              children: <Widget>[
                                Positioned(
                                  top: 200.0,
                                  left: 0.0,
                                  child: Icon(
                                    Icons.arrow_left,
                                    color: Colors.black,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: 8.0,
                                    bottom: 8.0,
                                    top: 8.0,
                                    left: 16.0,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            'Hinweis 3',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 16.0),
                                          Text(
                                            lorem + lorem,
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.black,
                        ),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildFabs() {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          FloatingActionButton(
            heroTag: null,
            backgroundColor: Colors.white.withOpacity(0.8),
            elevation: 4.0,
            child: Icon(Icons.colorize, color: Colors.black),
            onPressed: () {
              _buildMainBottomSheetColor();
            },
          ),
          FloatingActionButton(
            heroTag: null,
            backgroundColor: Colors.white.withOpacity(0.8),
            elevation: 4.0,
            child: Icon(Icons.clear, color: Colors.black),
            onPressed: () {
              setState(() {
                //clearLast();
                currentColor = Colors.white;
              });
            },
          ),
          FloatingActionButton(
            heroTag: null,
            backgroundColor: Colors.white.withOpacity(0.8),
            elevation: 4.0,
            child: Icon(Icons.straighten, color: Colors.black),
            onPressed: () => _buildMainBottomSheetStrokeWidth(),
          ),
        ],
      ),
    );
  }

  void _buildMainBottomSheetColor() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Color(0xFF737373),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16.0),
                topRight: const Radius.circular(16.0),
              ),
            ),
            /*child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _createTileColor('Schwarz', Colors.black),
                  _createTileColor('Rot', Colors.red),
                  _createTileColor('Blau', Colors.blue),
                  _createTileColor('Grün', Colors.green),
                  _createTileColor('Gelb', Colors.yellow),
                  _createTileColor('Orange', Colors.orange),
                  _createTileColor('Lila', Colors.purple),
                  _createTileColor('Braun', Colors.brown),
                  _createTileColor('Grau', Colors.grey),
                ],
              ),
            ),*/
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 4.0,
                shrinkWrap: true,
                children: <Widget>[
                  /*Container(color: Colors.yellow),
                  Container(color: Colors.red),
                  Container(color: Colors.green),
                  Container(color: Colors.blue),
                  Container(color: Colors.pink),
                  Container(color: Colors.purple),*/
                  _createTileColor(Colors.yellow),
                  _createTileColor(Colors.red),
                  _createTileColor(Colors.blue),
                  _createTileColor(Colors.pink),
                  _createTileColor(Colors.purple),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _createTileColor(
    //String name,
    Color color,
  ) {
    //double width = (MediaQuery.of(context).size.width / 2) - 16;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.all(
                Radius.circular(360.0),
              ),
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            setState(() {
              currentColor = color;
            });
          },
        ),
      ),
    );
  }

  void _buildMainBottomSheetStrokeWidth() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Color(0xFF737373),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16.0),
                topRight: const Radius.circular(16.0),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _createTileStrokeWidth('4', 4.0),
                  _createTileStrokeWidth('8', 8.0),
                  _createTileStrokeWidth('16', 16.0),
                  _createTileStrokeWidth('32', 32.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _createTileStrokeWidth(
    String name,
    double strokeWidth,
  ) {
    double width = (MediaQuery.of(context).size.width / 2) - 16;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        child: ListTile(
          leading: Container(
            height: strokeWidth,
            width: width,
            color: Colors.black,
          ),
          title: Text(
            name,
            style: TextStyle(color: Colors.black),
          ),
          onTap: () {
            Navigator.pop(context);
            setState(() {
              currentStrokeWidth = strokeWidth;
            });
          },
        ),
        onTap: () {},
      ),
    );
  }

  Future<bool> _buildSaveDialog() async {
    const String save = 'Wollen sie den Eintrag lokal speichern?';
    const String yes = 'Ja';
    const String no = 'Nein';
    return await showDialog(
      context: context,
      builder: (context) => Theme(
            data: Theme.of(context).copyWith(
              dialogBackgroundColor: Colors.white,
            ),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(16.0),
                ),
              ),
              title: Text(
                save,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 2,
                      maxLength: 50,
                      decoration: InputDecoration(
                        hintText: 'Titel',
                        hintStyle: TextStyle(fontSize: 16.0),
                        border: UnderlineInputBorder(),
                      ),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                    ),
                    TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
                      maxLength: 100,
                      decoration: InputDecoration(
                        hintText: 'Beschreibung',
                        hintStyle: TextStyle(fontSize: 16.0),
                        border: UnderlineInputBorder(),
                      ),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(height: 0.0),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatAlertDialogButton(
                  title: no,
                  onPressed: () => Navigator.pop(context, false),
                ),
                FlatAlertDialogButton(
                  title: yes,
                  onPressed: () {
                    Navigator.pop(context, false);
                    _buildShareDialog();
                  },
                ),
              ],
            ),
          ),
    );
  }

  void createImage() {
    //TODO
  }

  Future<bool> _buildShareDialog() async {
    const String yes = 'Ja';
    const String no = 'Nein';
    const String share = 'Wollen Sie diese Aufzeichnung teilen?';
    return await showDialog(
      context: context,
      builder: (context) => Theme(
            data: Theme.of(context).copyWith(
              dialogBackgroundColor: Colors.white,
            ),
            child: SimpleAlertDialogWithIcon(
              text: share,
              icon: Icons.share,
              iconColor: Colors.green,
              actions: <Widget>[
                FlatAlertDialogButton(
                  title: no,
                  onPressed: () => Navigator.pop(context, false),
                ),
                FlatAlertDialogButton(
                  title: yes,
                  fontColor: Colors.white,
                  buttonColor: Colors.green,
                  onPressed: () {
                    _createPdf();
                    Navigator.pop(context, false);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _createPdf() {
    Share.share('create csv');
  }
}
