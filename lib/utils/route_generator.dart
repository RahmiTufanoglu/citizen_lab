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
  static const String homePage = '/home_page';
  static const String splashPage = '/splash_page';
  static const String createProject = '/create_project';
  static const String aboutPage = '/about';
  static const String entry = '/entry';

  //static const String projectPage = '/project_page';
  static const String textPage = '/text_page';
  static const String imagePage = '/image_page';
  static const String tablePage = '/table_page';
  static const String sketchPage = '/sketch_page';
  static const String infoPage = '/info_page';
  static const String citizenSciencePage = '/citizen_science_page';
  static const String detailPage = '/detail_page';
  static const String sensorPage = '/sensor_page';
  static const String onboardingPage = '/onboarding_page';
  static const String calculatorPage = '/calculator_page';
  static const String stopwatchPage = '/stopwatch_page';
  static const String linkingPage = '/linking_page';
  static const String citizenScienceWebPage = '/citizen_science_web_page';
  static const String projectTemplatePage = '/project_template_page';
  static const String speechRecognitionPage = '/speech_recognition_page';
  static const String audioRecordPage = '/audio_record_page';

  static const String routeHomePage = 'home';
  static const String routeSplashPage = 'splash_page';
  static const String routeCreateProject = 'create_project';
  static const String routeAboutPage = 'about';
  static const String routeEntryPage = 'entry';

  //static const String routeProjectPage = 'project_page';
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
  static const String routeSpeechRecognitionPage = 'speech_recognition_page';
  static const String routeAudioRecordPage = 'audio_record_page';

  static RouteFactory routes() {
    return (settings) {
      final Map<String, dynamic> args = settings.arguments;
      Widget page;
      String route;
      switch (settings.name) {
        case homePage:
          page = HomePage();
          route = routeHomePage;
          break;
        case splashPage:
          page = SplashPage();
          route = routeSplashPage;
          break;
        case createProject:
          page = CreateProjectPage();
          route = routeCreateProject;
          break;
        case entry:
          page = EntryPage(
            project: args['project'],
            projectTitle: args['projectTitle'],
            isFromProjectPage: args['isFromProjectPage'],
            isFromProjectSearchPage: args['isFromProjectSearchPage'],
          );
          route = routeEntryPage;
          break;
        /*case projectPage:
          page = ProjectPage(
            isFromCreateProjectPage: args['isFromCreateProjectPage'],
          );
          route = routeProjectPage;
          break;*/
        case textPage:
          page = TextPage(
            uuid: args['projectRandom'],
            //projectId: args['projectId'],
            //projectTitle: args['projectTitle'],
            note: args['note'],
          );
          route = routeTextPage;
          break;
        case imagePage:
          page = ImagePage(
            uuid: args['projectRandom'],
            //projectId: args['projectId'],
            //projectTitle: args['projectTitle'],
            note: args['note'],
          );
          route = routeImagePage;
          break;
        case tablePage:
          page = TablePage(
            uuid: args['projectRandom'],
            //projectId: args['projectId'],
            //projectTitle: args['projectTitle'],
            note: args['note'],
          );
          route = routeTablePage;
          break;
        case sensorPage:
          page = GeolocationPage();
          route = routeSensorPage;
          break;
        case infoPage:
          page = InfoPage(
            title: args['title'],
            tabLength: args['tabLength'],
            tabs: args['tabs'],
            tabChildren: args['tabChildren'],
          );
          route = routeInfoPage;
          break;
        case citizenSciencePage:
          page = CitizenSciencePage();
          route = routeCitizenSciencePage;
          break;
        case detailPage:
          page = DetailPage(
            title: args['title'],
            image: args['image'],
            location: args['location'],
            researchSubject: args['research_subject'],
            built: args['built'],
            extended: args['extended'],
            contactPerson: args['contact_person'],
            url: args['url'],
          );
          route = routeDetailPage;
          break;
        case onboardingPage:
          page = OnboardingPage();
          route = routeOnboardingPage;
          break;
        case aboutPage:
          page = SimpleInfoPage(
            title: args['title'],
            content: args['content'],
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
        case linkingPage:
          page = WeblinkPage(
            uuid: args['projectRandom'],
            //projectId: args['projectId'],
            //projectTitle: args['projectTitle'],
            note: args['note'],
            //url: args['url'],
          );
          route = routeLinkingRecordPage;
          break;
        case citizenScienceWebPage:
          page = CitizenScienceWebPage(
            url: args['url'],
          );
          route = routeCitizenScienceWebPage;
          break;
        case projectTemplatePage:
          page = ProjectTemplatePage();
          route = routeProjectTemplatePage;
          break;
        case speechRecognitionPage:
          page = SpeechRecognitionPage();
          route = routeSpeechRecognitionPage;
          break;
        case audioRecordPage:
          page = AudioRecordPage(
            uuid: args['projectRandom'],
            note: args['note'],
          );
          route = routeAudioRecordPage;
          break;
      }
      return MaterialPageRoute(
        builder: (context) => page,
        settings: RouteSettings(name: route),
      );
    };
  }
}
