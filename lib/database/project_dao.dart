import 'package:citizen_lab/projects/project.dart';
import 'package:flutter/widgets.dart';

abstract class ProjectDao {
  Future<int> insertProject({@required Project project});

  Future<Project> getProject({@required int id});

  Future<List> getAllProjects();

  Future<int> deleteProject({@required int id});

  Future<int> deleteAllProjects();

  Future<int> updateProject({@required Project newProject});

  Future<int> getProjectCount();
}
