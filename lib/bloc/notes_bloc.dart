import 'dart:async';

import 'package:citizen_lab/database/database_provider.dart';
import 'package:citizen_lab/entries/note.dart';
import 'package:meta/meta.dart';

import 'base_bloc.dart';

class NotesBloc implements BaseBloc {
  //final _notesController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _notesController = StreamController<List<Note>>.broadcast();

  get notes => _notesController.stream;

  @override
  dispose() {
    _notesController.close();
  }

  void getNotes({@required int random, String order}) async {
    //_notesController.sink.add(await DatabaseProvider().getAllNotes());
    _notesController.sink.add(
      await DatabaseProvider.db.getNotesOfProject(
        random: random,
        order: order,
      ),
    );
  }

  NotesBloc({
    @required int random,
    String order,
  }) {
    getNotes(random: random, order: order);
  }

  void blockUnblock(Note note) {
    //DatabaseProvider().blockOrUnblock(note);
    getNotes(random: note.projectRandom);
  }

  void add(Note note) {
    if (note != null) {
      DatabaseProvider.db.insertNote(note: note);
      getNotes(random: note.projectRandom);
    }
  }

  void update(Note note) {
    if (note != null) {
      DatabaseProvider.db.updateNote(newNote: note);
      getNotes(random: note.projectRandom);
    }
  }

  void delete(Note note) {
    DatabaseProvider.db.deleteNote(id: note.id);
    getNotes(random: note.projectRandom);
  }

  void deleteAllNotesFromProject(List<Note> notes, int random) {
    DatabaseProvider.db.deleteAllNotesFromProject(random: random);
    for (int i = 0; i < notes.length; i++) {
      getNotes(random: notes[i].projectRandom);
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
    getNotes(random: null);
  }

  void sortByTitleDesc(List<Note> notes) {
    notes.toList().sort(
          (Note a, Note b) =>
              a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
  }

  void sortByReleaseDateArc(List<Note> notes) {
    notes.toList().sort(
          (Note a, Note b) => a.dateCreated.compareTo(b.dateCreated),
        );
  }

  void sortByReleaseDateDesc(List<Note> notes) {
    notes.toList().sort(
          (Note a, Note b) => b.dateCreated.compareTo(a.dateCreated),
        );
  }
}
