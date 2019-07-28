import 'dart:async';

import 'package:citizen_lab/database/database_provider.dart';
import 'package:citizen_lab/entries/note.dart';
import 'package:meta/meta.dart';

import 'base_bloc.dart';

class NotesBloc implements BaseBloc {
  //final _notesController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _notesController = StreamController<List<Note>>.broadcast();

  Stream<List<Note>> get notes => _notesController.stream;

  @override
  void dispose() {
    _notesController.close();
  }

  void getNotes({@required String uuid, String order}) async {
    //_notesController.sink.add(await DatabaseProvider().getAllNotes());
    _notesController.sink.add(
      await DatabaseHelper.db.getNotesOfProject(uuid: uuid),
    );
  }

  NotesBloc({
    @required String uuid,
    String order,
  }) {
    getNotes(uuid: uuid, order: order);
  }

  void blockUnblock(Note note) {
    //DatabaseProvider().blockOrUnblock(note);
    getNotes(uuid: note.uuid);
  }

  void add(Note note) {
    if (note != null) {
      DatabaseHelper.db.insertNote(note: note);
      getNotes(uuid: note.uuid);
    }
  }

  void update(Note note) {
    if (note != null) {
      DatabaseHelper.db.updateNote(newNote: note);
      getNotes(uuid: note.uuid);
    }
  }

  void delete(Note note) {
    DatabaseHelper.db.deleteNote(id: note.id);
    getNotes(uuid: note.uuid);
  }

  void deleteAllNotesFromProject(List<Note> notes, String uuid) {
    DatabaseHelper.db.deleteAllNotesFromProject(uuid: uuid);
    for (int i = 0; i < notes.length; i++) {
      getNotes(uuid: notes[i].uuid);
    }
  }

  /**
   *
   */

  void sortByTitleArc(List<Note> notes) {
    notes.sort(
      (Note a, Note b) =>
          a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );
    getNotes(uuid: null);
  }

  void sortByTitleDesc(List<Note> notes) {
    notes.toList().sort(
          (Note a, Note b) =>
              a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
  }

  void sortByReleaseDateArc(List<Note> notes) {
    notes.toList().sort(
          (Note a, Note b) => a.createdAt.compareTo(b.createdAt),
        );
  }

  void sortByReleaseDateDesc(List<Note> notes) {
    notes.toList().sort(
          (Note a, Note b) => b.createdAt.compareTo(a.createdAt),
        );
  }
}
