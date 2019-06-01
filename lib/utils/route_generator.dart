import 'package:citizen_lab/citizen_science/about_page.dart';
import 'package:citizen_lab/entries/sensor/sensor_page.dart';
import 'package:citizen_lab/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:citizen_lab/projects/create_project_page.dart';
import 'package:citizen_lab/entries/entry_page.dart';
import 'package:citizen_lab/entries/image/image_page.dart';
import 'package:citizen_lab/projects/project_page.dart';
import 'package:citizen_lab/entries/sketch_page.dart';
import 'package:citizen_lab/entries/table/table_page.dart';
import 'package:citizen_lab/entries/text/text_page.dart';

import 'package:citizen_lab/citizen_science/citizen_science_page.dart';
import 'package:citizen_lab/custom_widgets/detail_page.dart';
import 'package:citizen_lab/home/home_page.dart';
import 'package:citizen_lab/custom_widgets/info_page.dart';
import 'package:citizen_lab/onboarding/onboarding.dart';

import '../audio_recording_page.dart';

class RouteGenerator {
  static const String home = '/home_page';
  static const String splashPage = '/splash_page';
  static const String createProject = '/create_project';
  static const String aboutPage = '/about';
  static const String entry = '/entry';
  static const String projectPage = '/project_page';
  static const String textPage = '/text_page';
  static const String imagePage = '/image_page';
  static const String tablePage = '/table_page';
  static const String sketchPage = '/sketch_page';
  static const String infoPage = '/info_page';
  static const String citizenSciencePage = '/citizen_science_page';
  static const String detailPage = '/detail_page';
  static const String sensorPage = '/sensor_page';
  static const String aeyriumPage = '/aeyrium_page';
  static const String onboardingPage = '/onboarding_page';

  static const String routeHomePage = 'home';
  static const String routeSplashPage = 'splash_page';
  static const String routeCreateProject = 'create_project';
  static const String routeAboutPage = 'about';
  static const String routeEntry = 'entry';
  static const String routeProjectPage = 'project_page';
  static const String routeTextPage = 'text_page';
  static const String routeImagePage = 'image_page';
  static const String routeTablePage = 'table_page';
  static const String routeSketchPage = 'sketch_page';
  static const String routeInfoPage = 'info_page';
  static const String routeDetailPage = 'detail_page';
  static const String routeCitizenSciencePage = 'citizen_science_page';
  static const String routeSensorPage = 'sensor_page';
  static const String routeAeyriumPage = 'aeyrium_page';
  static const String routeOnboardingPage = 'onboarding_page';

  static RouteFactory routes() {
    return (settings) {
      final Map<String, dynamic> args = settings.arguments;
      Widget page;
      String route;
      switch (settings.name) {
        case home:
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
            isFromCreateProjectPage: args['isFromCreateProjectPage'],
            isFromProjectPage: args['isFromProjectPage'],
          );
          route = routeEntry;
          break;
        case projectPage:
          page = ProjectPage();
          route = projectPage;
          break;
        case textPage:
          page = TextPage(
            projectTitle: args['project'],
            note: args['note'],
          );
          route = routeTextPage;
          break;
        case imagePage:
          page = ImagePage(
            projectTitle: args['projectImagePage'],
            note: args['note'],
          );
          route = routeImagePage;
          break;
        case tablePage:
          page = TablePage(
            projectTitle: args['project'],
            note: args['note'],
          );
          route = routeTablePage;
          break;
        case sketchPage:
          page = SketchPage();
          route = routeSketchPage;
          break;
        case sensorPage:
          page = SensorPage(
            projectTitle: args['project'],
            note: args['note'],
          );
          route = routeSensorPage;
          break;
        case aeyriumPage:
          page = AudioRecordingPage(
            projectTitle: args['project'],
            note: args['note'],
          );
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
            content: args['content'],
            image: args['image'],
          );
          route = routeDetailPage;
          break;
        case onboardingPage:
          page = Onboarding();
          route = routeOnboardingPage;
          break;
        case aboutPage:
          page = AboutPage();
          route = routeAboutPage;
          break;
        default:
          return null;
      }
      return MaterialPageRoute(
        builder: (context) => page,
        settings: RouteSettings(name: route),
      );
    };
  }
}
