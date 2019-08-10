import 'package:citizen_lab/citizen_science/about_page.dart';
import 'package:citizen_lab/citizen_science/citizen_science_detail_page.dart';
import 'package:citizen_lab/citizen_science/citizen_science_page.dart';
import 'package:citizen_lab/citizen_science/citizen_science_web.dart';
import 'package:citizen_lab/custom_widgets/info_page.dart';
import 'package:citizen_lab/entries/entry_page.dart';
import 'package:citizen_lab/entries/image/image_page.dart';
import 'package:citizen_lab/entries/table/table_page.dart';
import 'package:citizen_lab/entries/text/text_page.dart';
import 'package:citizen_lab/entries/weblink/weblink_page.dart';
import 'package:citizen_lab/home/home_page.dart';
import 'package:citizen_lab/onboarding/onboarding_page.dart';
import 'package:citizen_lab/projects/create_project_page.dart';
import 'package:citizen_lab/splash_page.dart';
import 'package:citizen_lab/tools/calculator/calculator_page.dart';
import 'package:citizen_lab/tools/geolocation/geolocation_page.dart';
import 'package:citizen_lab/tools/stopwatch/stopwatch_page.dart';
import 'package:flutter/material.dart';

import '../audio_record_page.dart';
import '../custom_log_printer.dart';
import '../project_template_page.dart';

const String homePage = '/home_page';
const String splashPage = '/splash_page';
const String createProjectPage = '/create_project';
const String projectPage = '/entry';
const String textPage = '/text_page';
const String imagePage = '/image_page';
const String tablePage = '/table_page';
const String aboutPage = '/about';
const String infoPage = '/info_page';
const String citizenSciencePage = '/citizen_science_page';
const String detailPage = '/detail_page';
const String locationPage = '/sensor_page';
const String onboardingPage = '/onboarding_page';
const String calculatorPage = '/calculator_page';
const String stopwatchPage = '/stopwatch_page';
const String webLinkPage = '/linking_page';
const String projectTemplatePage = '/project_template_page';
const String audioRecordPage = '/audio_record_page';
const String webPage = '/citizen_science_web_page';

const String routeHomePage = 'home';
const String routeSplashPage = 'splash_page';
const String routeCreateProject = 'create_project';
const String routeAboutPage = 'about';
const String routeEntryPage = 'entry';
const String routeTextPage = 'text_page';
const String routeImagePage = 'image_page';
const String routeTablePage = 'table_page';
const String routeSketchPage = 'sketch_page';
const String routeInfoPage = 'info_page';
const String routeDetailPage = 'detail_page';
const String routeCitizenSciencePage = 'citizen_science_page';
const String routeSensorPage = 'sensor_page';
const String routeOnboardingPage = 'onboarding_page';
const String routeCalculatorPage = 'calculator_page';
const String routeStopwatchPage = 'stopwatch_page';
const String routeLinkingRecordPage = 'linking_page';
const String routeCitizenScienceWebPage = 'citizen_science_web_page';
const String routeProjectTemplatePage = 'project_template_page';
const String routeAudioRecordingPage = 'audio_record_page';

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

class RouteGenerator {
  static RouteFactory generateRoute() {
    final log = getLogger('Router');

    return (settings) {
      final Map<String, dynamic> args = settings.arguments;
      Widget page;
      String route;

      log.i(
        'generateRoute | name: ${settings.name} | arguments: $args',
      );

      switch (settings.name) {
        case homePage:
          page = HomePage();
          route = routeHomePage;
          break;
        case splashPage:
          page = SplashPage();
          route = routeSplashPage;
          break;
        case createProjectPage:
          page = CreateProjectPage();
          route = routeCreateProject;
          break;
        case projectPage:
          page = EntryPage(
            project: args[argProject],
            projectTitle: args[argProjectTitle],
            isFromProjectPage: args[argIsFromProjectPage],
            isFromProjectSearchPage: args[argIsFromProjectSearchPage],
          );
          route = routeEntryPage;
          break;
        case textPage:
          page = TextPage(
            uuid: args[argProjectUuid],
            note: args[argNote],
          );
          route = routeTextPage;
          break;
        case imagePage:
          page = ImagePage(
            uuid: args[argProjectUuid],
            note: args[argNote],
          );
          route = routeImagePage;
          break;
        case tablePage:
          page = TablePage(
            uuid: args[argProjectUuid],
            note: args[argNote],
          );
          route = routeTablePage;
          break;
        case locationPage:
          page = GeolocationPage();
          route = routeSensorPage;
          break;
        case infoPage:
          page = InfoPage(
            title: args[argTitle],
            tabLength: args[argTabLength],
            tabs: args[argTabs],
            tabChildren: args[argTabChildren],
          );
          route = routeInfoPage;
          break;
        case citizenSciencePage:
          page = CitizenSciencePage();
          route = routeCitizenSciencePage;
          break;
        case detailPage:
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
          route = routeDetailPage;
          break;
        case onboardingPage:
          page = OnboardingPage();
          route = routeOnboardingPage;
          break;
        case aboutPage:
          page = SimpleInfoPage(
            title: args[argTitle],
            content: args[argContent],
          );
          route = routeAboutPage;
          break;
        case calculatorPage:
          page = CalculatorPage();
          route = routeCalculatorPage;
          break;
        case stopwatchPage:
          page = StopwatchPage();
          route = routeStopwatchPage;
          break;
        case webLinkPage:
          page = WeblinkPage(
            uuid: args[argProjectUuid],
            note: args[argNote],
          );
          route = routeLinkingRecordPage;
          break;
        case webPage:
          page = CitizenScienceWebPage(
            title: args[argTitle],
            url: args[argUrl],
          );
          route = routeCitizenScienceWebPage;
          break;
        case projectTemplatePage:
          page = ProjectTemplatePage();
          route = routeProjectTemplatePage;
          break;
        case audioRecordPage:
          page = AudioRecordPage(
            uuid: args[argProjectUuid],
            note: args[argNote],
          );
          route = routeAudioRecordingPage;
          break;
      }

      return MaterialPageRoute(
        builder: (context) => page,
        settings: RouteSettings(name: route),
      );
    };
  }
}
