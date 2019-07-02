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
        MediaQuery.of(context).size.height - kToolbarHeight - statusBarHeight;
    final double screenWidth = MediaQuery.of(context).size.width;
    final int size = widget.column * widget.row;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.column,
        crossAxisSpacing: 0.0,
        childAspectRatio:
            MediaQuery.of(context).orientation == Orientation.portrait
                ? screenHeight / screenWidth * 0.8
                : screenWidth / screenHeight * 0.4,
      ),
      itemCount: size == null ? widget.column * widget.row : size,
      itemBuilder: (BuildContext context, int index) => Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: TextFormField(
              maxLines: 4,
              controller: widget.listTextEditingController[index],
              decoration: InputDecoration(
                hintText: index.toString(),
                contentPadding: EdgeInsets.all(8.0),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
              ),
            ),
          ),
    );
  }
}
