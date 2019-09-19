import 'package:citizen_lab/projects/project.dart';

abstract class ProjectDao {
  Future<int> insertProject({Project project});

  Future<Project> getProject({int id});

  Future<List> getAllProjects();

  Future<int> deleteProject({int id});

  Future<int> deleteAllProjects();

  Future<int> updateProject({Project newProject});

  Future<int> getProjectCount();
}
