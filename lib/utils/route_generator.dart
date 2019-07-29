import 'package:citizen_lab/SpeechRecognitionPage.dart';
import 'package:citizen_lab/citizen_science/about_page.dart';
import 'package:citizen_lab/citizen_science/citizen_science_page.dart';
import 'package:citizen_lab/citizen_science/citizen_science_web.dart';
import 'package:citizen_lab/citizen_science/detail_page.dart';
import 'package:citizen_lab/custom_widgets/info_page.dart';
import 'package:citizen_lab/entries/entry_page.dart';
import 'package:citizen_lab/entries/image/image_page.dart';
import 'package:citizen_lab/entries/linking_page/weblink_page.dart';
import 'package:citizen_lab/entries/table/table_page.dart';
import 'package:citizen_lab/entries/text/text_page.dart';
import 'package:citizen_lab/entries/tools/calculator_page.dart';
import 'package:citizen_lab/entries/tools/geolocation_page.dart';
import 'package:citizen_lab/entries/tools/stopwatch/stopwatch_page.dart';
import 'package:citizen_lab/home/home_page.dart';
import 'package:citizen_lab/onboarding/onboarding_page.dart';
import 'package:citizen_lab/projects/create_project_page.dart';
import 'package:citizen_lab/splash_page.dart';
import 'package:flutter/material.dart';

import '../audio_record_page.dart';
import '../project_template_page.dart';

class RouteGenerator {
  static const String HOMEPAGE = '/home_page';
  static const String SPLASHPAGE = '/splash_page';
  static const String CREATE_PROJECT = '/create_project';
  static const String ABOUT_PAGE = '/about';
  static const String ENTRY = '/entry';
  static const String TEXT_PAGE = '/text_page';
  static const String IMAGE_PAGE = '/image_page';
  static const String TABLE_PAGE = '/table_page';
  static const String SKETCH_PAGE = '/sketch_page';
  static const String INFO_PAGE = '/info_page';
  static const String CITIZEN_SCIENCE_PAGE = '/citizen_science_page';
  static const String DETAIL_PAGE = '/detail_page';
  static const String SENSOR_PAGE = '/sensor_page';
  static const String ONBOARDING_PAGE = '/onboarding_page';
  static const String CALCULATOR_PAGE = '/calculator_page';
  static const String STOPWATCH_PAGE = '/stopwatch_page';
  static const String LINKING_PAGE = '/linking_page';
  static const String CITIZEN_SCIENCE_WEB_PAGE = '/citizen_science_web_page';
  static const String PROJECT_TEMPLATE_PAGE = '/project_template_page';
  static const String SPEECH_RECOGNITION_PAGE = '/speech_recognition_page';
  static const String AUDIO_RECORD_PAGE = '/audio_record_page';

  static const String ROUTE_HOME_PAGE = 'home';
  static const String ROUTE_SPLASH_PAGE = 'splash_page';
  static const String ROUTE_CREATE_PROJECT = 'create_project';
  static const String ROUTE_ABOUT_PAGE = 'about';
  static const String ROUTE_ENTRY_PAGE = 'entry';
  static const String ROUTE_TEXT_PAGE = 'text_page';
  static const String ROUTE_IMAGE_PAGE = 'image_page';
  static const String ROUTE_TABLE_PAGE = 'table_page';
  static const String ROUTE_SKETCH_PAGE = 'sketch_page';
  static const String ROUTE_INFO_PAGE = 'info_page';
  static const String ROUTE_DETAIL_PAGE = 'detail_page';
  static const String ROUTE_CITIZEN_SCIENCE_PAGE = 'citizen_science_page';
  static const String ROUTE_SENSOR_PAGE = 'sensor_page';
  static const String ROUTE_ONBOARDING_PAGE = 'onboarding_page';
  static const String ROUTE_CALCULATOR_PAGE = 'calculator_page';
  static const String ROUTE_STOPWATCH_PAGE = 'stopwatch_page';
  static const String ROUTE_LINKING_RECORD_PAGE = 'linking_page';
  static const String ROUTE_CITIZEN_SCIENCE_WEB_PAGE =
      'citizen_science_web_page';
  static const String ROUTE_PROJECT_TEMPLATE_PAGE = 'project_template_page';
  static const String ROUTE_SPEECH_RECOGNITION_PAGE = 'speech_recognition_page';
  static const String ROUTE_AUDIO_RECORDING_PAGE = 'audio_record_page';

  static const String PROJECT = 'project';
  static const String PROJECT_TITLE = 'projectTitle';
  static const String PROJECT_UUID = 'projectUuid';
  static const String IS_FROM_PROJECT_PAGE = 'isFromProjectPage';
  static const String IS_FROM_PROJECT_SEARCH_PAGE = 'isFromProjectSearchPage';
  static const String NOTE = 'note';
  static const String URL = 'url';
  static const String TITLE = 'title';
  static const String TAB_LENGTH = 'tabLength';
  static const String TABS = 'tabs';
  static const String TAB_CHILDREN = 'tabChildren';
  static const String IMAGE = 'image';
  static const String LOCATION = 'location';
  static const String RESEARCH_SUBJECT = 'research_subject';
  static const String BUILT = 'built';
  static const String EXTENDED = 'extended';
  static const String CONTACT_PERSON = 'contact_person';
  static const String CONTENT = 'content';

  static RouteFactory routes() {
    return (settings) {
      final Map<String, dynamic> args = settings.arguments;
      Widget page;
      String route;
      switch (settings.name) {
        case HOMEPAGE:
          page = HomePage();
          route = ROUTE_HOME_PAGE;
          break;
        case SPLASHPAGE:
          page = SplashPage();
          route = ROUTE_SPLASH_PAGE;
          break;
        case CREATE_PROJECT:
          page = CreateProjectPage();
          route = ROUTE_CREATE_PROJECT;
          break;
        case ENTRY:
          page = EntryPage(
            project: args[PROJECT],
            projectTitle: args[PROJECT_TITLE],
            isFromProjectPage: args[IS_FROM_PROJECT_PAGE],
            isFromProjectSearchPage: args[IS_FROM_PROJECT_SEARCH_PAGE],
          );
          route = ROUTE_ENTRY_PAGE;
          break;
        case TEXT_PAGE:
          page = TextPage(
            uuid: args[PROJECT_UUID],
            note: args[NOTE],
          );
          route = ROUTE_TEXT_PAGE;
          break;
        case IMAGE_PAGE:
          page = ImagePage(
            uuid: args[PROJECT_UUID],
            note: args[NOTE],
          );
          route = ROUTE_IMAGE_PAGE;
          break;
        case TABLE_PAGE:
          page = TablePage(
            uuid: args[PROJECT_UUID],
            note: args[NOTE],
          );
          route = ROUTE_TABLE_PAGE;
          break;
        case SENSOR_PAGE:
          page = GeolocationPage();
          route = ROUTE_SENSOR_PAGE;
          break;
        case INFO_PAGE:
          page = InfoPage(
            title: args[TITLE],
            tabLength: args[TAB_LENGTH],
            tabs: args[TABS],
            tabChildren: args[TAB_CHILDREN],
          );
          route = ROUTE_INFO_PAGE;
          break;
        case CITIZEN_SCIENCE_PAGE:
          page = CitizenSciencePage();
          route = ROUTE_CITIZEN_SCIENCE_PAGE;
          break;
        case DETAIL_PAGE:
          page = DetailPage(
            title: args[TITLE],
            image: args[IMAGE],
            location: args[LOCATION],
            researchSubject: args[RESEARCH_SUBJECT],
            built: args[BUILT],
            extended: args[EXTENDED],
            contactPerson: args[CONTACT_PERSON],
            url: args[URL],
          );
          route = ROUTE_DETAIL_PAGE;
          break;
        case ONBOARDING_PAGE:
          page = OnboardingPage();
          route = ROUTE_ONBOARDING_PAGE;
          break;
        case ABOUT_PAGE:
          page = SimpleInfoPage(
            title: args[TITLE],
            content: args[CONTENT],
          );
          route = ROUTE_ABOUT_PAGE;
          break;
        case CALCULATOR_PAGE:
          page = CalculatorPage();
          route = ROUTE_CALCULATOR_PAGE;
          break;
        case STOPWATCH_PAGE:
          page = StopwatchPage();
          route = ROUTE_STOPWATCH_PAGE;
          break;
        case LINKING_PAGE:
          page = WeblinkPage(
            uuid: args[PROJECT_UUID],
            note: args[NOTE],
          );
          route = ROUTE_LINKING_RECORD_PAGE;
          break;
        case CITIZEN_SCIENCE_WEB_PAGE:
          page = CitizenScienceWebPage(
            url: args[URL],
          );
          route = ROUTE_CITIZEN_SCIENCE_WEB_PAGE;
          break;
        case PROJECT_TEMPLATE_PAGE:
          page = ProjectTemplatePage();
          route = ROUTE_PROJECT_TEMPLATE_PAGE;
          break;
        case SPEECH_RECOGNITION_PAGE:
          page = SpeechRecognitionPage();
          route = ROUTE_SPEECH_RECOGNITION_PAGE;
          break;
        case AUDIO_RECORD_PAGE:
          page = AudioRecordPage(
            uuid: args[PROJECT_UUID],
            note: args[NOTE],
          );
          route = ROUTE_AUDIO_RECORDING_PAGE;
          break;
      }

      return MaterialPageRoute(
        builder: (context) => page,
        settings: RouteSettings(name: route),
      );
    };
  }
}
