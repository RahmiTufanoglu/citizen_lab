import 'package:citizen_lab/utils/constants.dart';

class PageModel {
  String image;
  String title;
  String content;

  PageModel({
    this.image,
    this.title,
    this.content,
  });
}

var pageList = [
  PageModel(
    image: 'assets/images/notes_1.jpg',
    title: '1',
    content: lorem_short,
  ),
  PageModel(
    image: 'assets/images/notes_2.jpg',
    title: '2',
    content: lorem,
  ),
  PageModel(
    image: 'assets/images/notes_3.jpg',
    title: '3',
    content: lorem_shorter,
  ),
];
