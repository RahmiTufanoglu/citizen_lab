import 'dart:io';

import 'package:meta/meta.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PdfCreator {
  String title;
  String content;

  PdfCreator({
    @required this.title,
    @required this.content,
  });

  final pdf = Document();

  void createPdf() {
    pdf.addPage(
      Page(
        pageFormat: PdfPageFormat.a4,
        build: (Context context) {
          return Column(
            children: [
              Text(title),
              Text(content),
            ],
          );
        },
      ),
    ); // Page
  }

  void savePdf() async {
    final file = File('$title.pdf');
    await file.writeAsBytes(pdf.save());
  }
}
