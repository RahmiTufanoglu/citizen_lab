import 'package:flutter/material.dart';

class TableWidget extends StatefulWidget {
  final List<TextEditingController> listTextEditingController;
  final int column;
  final int row;

  TableWidget({
    @required this.listTextEditingController,
    @required this.column,
    @required this.row,
  });

  @override
  _TableWidgetState createState() => _TableWidgetState();
}

class _TableWidgetState extends State<TableWidget> {
  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = 24.0;
    final double screenHeight =
        (MediaQuery.of(context).size.height) - kToolbarHeight - statusBarHeight;
    final double screenWidth = MediaQuery.of(context).size.width;

    int size = widget.column * widget.row;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.column,
        crossAxisSpacing: 0.0,
        childAspectRatio: screenHeight / screenWidth,
      ),
      itemCount: (size == null) ? widget.column * widget.row : size,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
          ),
          child: TextFormField(
            maxLines: 4,
            controller: widget.listTextEditingController[index],
            decoration: InputDecoration(
              hintText: index.toString(),
              contentPadding: const EdgeInsets.all(8.0),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
            ),
          ),
        );
      },
    );
  }
}
