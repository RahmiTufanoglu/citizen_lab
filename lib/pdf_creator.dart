import 'dart:io';

import 'package:meta/meta.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PdfCreator {
  String title;
  String content;
  String dateCreated;
  String filePath;

  final pdf = Document();

  PdfCreator({
    @required this.title,
    @required this.content,
    @required this.dateCreated,
    @required this.filePath,
  });

  void createPdf() {
    pdf.addPage(
      Page(
        pageFormat: PdfPageFormat.a4,
        build: (Context context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                content,
                style: TextStyle(fontSize: 12.0),
              ),
              SizedBox(height: 16.0),
              Text(
                dateCreated,
                style: TextStyle(
                  fontSize: 12.0,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          );
        },
      ),
    ); // Page
  }

  Future<void> savePdf() async {
    //final directory = await getApplicationDocumentsDirectory();
    //final path = '${directory.path}/$title.pdf';
    final File file = File(filePath);
    await file.writeAsBytes(pdf.save());
  }

/*Future<File> get _localFile async {
    final path = _localPath;
    return File('$path/$title.pdf');
  }*/
}
