import 'package:citizen_lab/citizen_science/citizen_science_detail_page.dart';
import 'package:citizen_lab/citizen_science/citizen_science_page.dart';
import 'package:citizen_lab/citizen_science/citizen_science_web.dart';
import 'package:citizen_lab/citizen_science/simple_info_page.dart';
import 'package:citizen_lab/custom_widgets/info_page.dart';
import 'package:citizen_lab/home/home_page.dart';
import 'package:citizen_lab/notes/audio/audio_record_page.dart';
import 'package:citizen_lab/notes/image/image_page.dart';
import 'package:citizen_lab/notes/note_page.dart';
import 'package:citizen_lab/notes/table/table_page.dart';
import 'package:citizen_lab/notes/text/text_page.dart';
import 'package:citizen_lab/notes/weblink/weblink_page.dart';
import 'package:citizen_lab/onboarding/onboarding_page.dart';
import 'package:citizen_lab/projects/create_project_page.dart';
import 'package:citizen_lab/splash_page.dart';
import 'package:citizen_lab/tools/calculator/calculator_page.dart';
import 'package:citizen_lab/tools/geolocation/geolocation_page.dart';
import 'package:citizen_lab/tools/stopwatch/stopwatch_page.dart';
import 'package:flutter/material.dart';

import '../template/project_template_page.dart';
import 'custom_log_printer.dart';

class CustomRoute {
  static const String homePage = '/home_page';
  static const String splashPage = '/splash_page';
  static const String createProjectPage = '/create_project';
  static const String projectPage = '/entry';
  static const String textPage = '/text_page';
  static const String imagePage = '/image_page';
  static const String tablePage = '/table_page';
  static const String aboutPage = '/about';
  static const String infoPage = '/info_page';
  static const String citizenSciencePage = '/citizen_science_page';
  static const String detailPage = '/detail_page';
  static const String locationPage = '/sensor_page';
  static const String onboardingPage = '/onboarding_page';
  static const String calculatorPage = '/calculator_page';
  static const String stopwatchPage = '/stopwatch_page';
  static const String webLinkPage = '/linking_page';
  static const String projectTemplatePage = '/project_template_page';
  static const String audioRecordPage = '/audio_record_page';
  static const String webPage = '/citizen_science_web_page';

  static const String routeHomePage = 'home';
  static const String routeSplashPage = 'splash_page';
  static const String routeCreateProject = 'create_project';
  static const String routeAboutPage = 'about';
  static const String routeEntryPage = 'entry';
  static const String routeTextPage = 'text_page';
  static const String routeImagePage = 'image_page';
  static const String routeTablePage = 'table_page';
  static const String routeSketchPage = 'sketch_page';
  static const String routeInfoPage = 'info_page';
  static const String routeDetailPage = 'detail_page';
  static const String routeCitizenSciencePage = 'citizen_science_page';
  static const String routeSensorPage = 'sensor_page';
  static const String routeOnboardingPage = 'onboarding_page';
  static const String routeCalculatorPage = 'calculator_page';
  static const String routeStopwatchPage = 'stopwatch_page';
  static const String routeLinkingRecordPage = 'linking_page';
  static const String routeCitizenScienceWebPage = 'citizen_science_web_page';
  static const String routeProjectTemplatePage = 'project_template_page';
  static const String routeAudioRecordingPage = 'audio_record_page';
}

const String argProject = 'project';
const String argProjectTitle = 'projectTitle';
const String argProjectUuid = 'projectUuid';
const String argIsFromProjectPage = 'isFromProjectPage';
const String argIsFromProjectSearchPage = 'isFromProjectSearchPage';
const String argNote = 'note';
const String argUrl = 'url';
const String argTitle = 'title';
const String argTabLength = 'tabLength';
const String argTabs = 'tabs';
const String argTabChildren = 'tabChildren';
const String argImage = 'image';
const String argLocation = 'location';
const String argResearchSubject = 'research_subject';
const String argBuilt = 'built';
const String argExtended = 'extended';
const String argContactPerson = 'contact_person';
const String argContent = 'content';
const String argSearchEngine = 'search_engine';

class RouteGenerator {
  static RouteFactory generateRoute() {
    final log = getLogger('Router');

    return (settings) {
      final Map<String, dynamic> args = settings.arguments;
      final String name = settings.name;
      Widget page;
      String route;

      log.i('generateRoute | name: $name | arguments: $args');

      switch (name) {
        case CustomRoute.homePage:
          page = HomePage();
          route = CustomRoute.routeHomePage;
          break;
        case CustomRoute.splashPage:
          page = SplashPage();
          route = CustomRoute.routeSplashPage;
          break;
        case CustomRoute.createProjectPage:
          page = CreateProjectPage();
          route = CustomRoute.routeCreateProject;
          break;
        case CustomRoute.projectPage:
          page = NotePage(
            project: args[argProject],
            projectTitle: args[argProjectTitle],
            isFromProjectPage: args[argIsFromProjectPage],
            isFromProjectSearchPage: args[argIsFromProjectSearchPage],
          );
          route = CustomRoute.routeEntryPage;
          break;
        case CustomRoute.textPage:
          page = TextPage(
            uuid: args[argProjectUuid],
            note: args[argNote],
          );
          route = CustomRoute.routeTextPage;
          break;
        case CustomRoute.imagePage:
          page = ImagePage(
            uuid: args[argProjectUuid],
            note: args[argNote],
          );
          route = CustomRoute.routeImagePage;
          break;
        case CustomRoute.tablePage:
          page = TablePage(
            uuid: args[argProjectUuid],
            note: args[argNote],
          );
          route = CustomRoute.routeTablePage;
          break;
        case CustomRoute.locationPage:
          page = GeolocationPage();
          route = CustomRoute.routeSensorPage;
          break;
        case CustomRoute.infoPage:
          page = InfoPage(
            title: args[argTitle],
            tabLength: args[argTabLength],
            tabs: args[argTabs],
            tabChildren: args[argTabChildren],
          );
          route = CustomRoute.routeInfoPage;
          break;
        case CustomRoute.citizenSciencePage:
          page = CitizenSciencePage();
          route = CustomRoute.routeCitizenSciencePage;
          break;
        case CustomRoute.detailPage:
          page = DetailPage(
            title: args[argTitle],
            image: args[argImage],
            location: args[argLocation],
            researchSubject: args[argResearchSubject],
            built: args[argBuilt],
            extended: args[argExtended],
            contactPerson: args[argContactPerson],
            url: args[argUrl],
          );
          route = CustomRoute.routeDetailPage;
          break;
        case CustomRoute.onboardingPage:
          page = OnboardingPage();
          route = CustomRoute.routeOnboardingPage;
          break;
        case CustomRoute.aboutPage:
          page = SimpleInfoPage(
            title: args[argTitle],
            content: args[argContent],
          );
          route = CustomRoute.routeAboutPage;
          break;
        case CustomRoute.calculatorPage:
          page = CalculatorPage();
          route = CustomRoute.routeCalculatorPage;
          break;
        case CustomRoute.stopwatchPage:
          page = StopwatchPage();
          route = CustomRoute.routeStopwatchPage;
          break;
        case CustomRoute.webLinkPage:
          page = WeblinkPage(
            uuid: args[argProjectUuid],
            note: args[argNote],
            searchEngine: args[argSearchEngine],
          );
          route = CustomRoute.routeLinkingRecordPage;
          break;
        case CustomRoute.webPage:
          page = CitizenScienceWebPage(
            title: args[argTitle],
            url: args[argUrl],
          );
          route = CustomRoute.routeCitizenScienceWebPage;
          break;
        case CustomRoute.projectTemplatePage:
          page = ProjectTemplatePage();
          route = CustomRoute.routeProjectTemplatePage;
          break;
        case CustomRoute.audioRecordPage:
          page = AudioRecordPage(
            uuid: args[argProjectUuid],
            note: args[argNote],
          );
          route = CustomRoute.routeAudioRecordingPage;
          break;
      }

      return MaterialPageRoute(
        builder: (context) => page,
        settings: RouteSettings(name: route),
      );
    };
  }
}
