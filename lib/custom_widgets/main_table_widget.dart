import 'package:citizen_lab/custom_widgets/table_widget.dart';
import 'package:flutter/material.dart';

class MainTableWidet extends StatefulWidget {
  final Function onWillPop;
  final int column;
  final int row;
  final List<TextEditingController> textEditingController;
  final Function generateTable;

  const MainTableWidet({
    @required this.onWillPop,
    @required this.column,
    @required this.row,
    @required this.textEditingController,
    @required this.generateTable,
  })  : assert(onWillPop != null),
        assert(column != null),
        assert(row != null),
        assert(textEditingController != null),
        assert(generateTable != null);

  @override
  _MainTableWidetState createState() => _MainTableWidetState();
}

class _MainTableWidetState extends State<MainTableWidet> {
  @override
  Widget build(BuildContext context) {
    widget.generateTable();

    return SafeArea(
      child: WillPopScope(
        onWillPop: () => widget.onWillPop(),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 88.0),
          child: (widget.column != null || widget.row != null)
              ? TableWidget(
                  listTextEditingController: widget.textEditingController,
                  column: widget.column,
                  row: widget.row,
                )
              : Center(
                  child: Icon(
                    Icons.table_chart,
                    color: Colors.grey,
                    size: 100.0,
                  ),
                ),
        ),
      ),
    );
  }
}
