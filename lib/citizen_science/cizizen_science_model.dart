import 'package:flutter/widgets.dart';

class CitizenScienceModel {
  String title;
  String image;
  String location;
  String researchSubject;
  String built;
  String extended;
  String contactPerson;

  CitizenScienceModel({
    @required this.title,
    @required this.image,
    @required this.location,
    @required this.researchSubject,
    @required this.built,
    @required this.extended,
    @required this.contactPerson,
  });

  String get getTitle => title;

  String get getImage => image;

  String get getLocation => location;

  String get getResearchSubject => researchSubject;

  String get getBuilt => built;

  String get getExtended => extended;

  String get getContactPerson => contactPerson;
}
