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

final String pageOne = """
Vor dem Benutzen der App noch ein paar nützliche Hinweise.\n
Für die Hinweise nach rechts Wischen.\n
Oben das Kreuz-Icon betätigen, um das Onboarding zu überspringen. 
""";

final String pageTwo = """
Mit dieser App kann der Benutzer ein Projekt erstellen.\n
Ein Projekt kann mehrere Notizen haben, welche als Karten in einer Liste abgebildet werden.\n
Es wird zwischen folgenden Notizen unterschieden:\n
Text-, Tabellen-, Fotos- und Webnotiz.
""";

final String pageFour = """
Eine Notiz besteht immer aus einem Titel und einer Beschreibung.\n
Die Angabe des Titels ist immer Pflicht.\n
Das Speichern einer Notiz erfolgt, durch Drücken des Pfeil-Icons in der AppBar oder durch das Wischen nach rechts (Systemabhängig).\n
""";

final String pageFive = """
Es macht durchaus Sinn zu Beginn sich mit den restlichen Funktionaliäten wie den Suchoptionen und hilfreichen Tools der App vertraut zu machen.\n
Die App nutzt die Vorteile der Gestensteuerung, wie z.B. das Löschen von Notiz-Karten durch ein Wischen nach rechts uvm.\n
Am besten selbst probieren und Spaß haben.\n
Viel Spaß mit der App.
""";

var pageList = [
  PageModel(
    image: 'assets/app_logo.png',
    title: 'Willkommen zu Citizen Lab.',
    content: pageOne,
  ),
  PageModel(
    image: 'assets/app_logo.png',
    title: 'Projekt.',
    content: pageTwo,
  ),
  PageModel(
    image: 'assets/app_logo.png',
    title: 'Notiz.',
    content: pageFour,
  ),
  PageModel(
    image: 'assets/app_logo.png',
    title: 'Letzte Worte.',
    content: pageFive,
  ),
];
