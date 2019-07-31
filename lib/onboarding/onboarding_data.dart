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

const String pageOne = """
Vor dem Benutzen der App noch ein paar nützliche Hinweise.\n
Für die Hinweise nach rechts Wischen.\n
Oben das Kreuz-Icon betätigen, um das Onboarding zu überspringen. 
""";

const String pageTwo = """
Mit dieser App kann der Benutzer ein Projekt erstellen.\n
Ein Projekt kann mehrere Notizen haben, welche als Karten in einer Liste abgebildet werden.\n
Es wird zwischen folgenden Notizen unterschieden:\n
Text-, Tabellen-, Fotos- und Webnotiz.
""";

const String pageFour = """
Eine Notiz besteht immer aus einem Titel und einer Beschreibung.\n
Die Angabe des Titels ist immer Pflicht.\n
Das Speichern einer Notiz erfolgt, durch Drücken des Pfeil-Icons in der AppBar oder durch das Wischen nach rechts (Systemabhängig).\n
""";

const String pageFive = """
Zu Beginn macht es durchaus Sinn sich mit den Funktionaliäten der App vertraut zu machen.\n
Die App nutzt die Vorteile der Gestensteuerung, wie z.B. das Löschen von Notiz-Karten durch ein Wischen nach rechts uvm. Am besten selbst ausprobieren.\n
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
