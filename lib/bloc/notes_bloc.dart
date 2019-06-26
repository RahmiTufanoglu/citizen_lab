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

  getNotes({@required int random}) async {
    //_notesController.sink.add(await DatabaseProvider().getAllNotes());
    _notesController.sink.add(
      await DatabaseProvider().getNotesOfProject(random: random),
    );
  }

  NotesBloc({@required int random}) {
    getNotes(random: random);
  }

  blockUnblock(Note note) {
    //DatabaseProvider().blockOrUnblock(note);
    getNotes(random: note.projectRandom);
  }

  add(Note note) {
    DatabaseProvider().insertNote(note: note);
    getNotes(random: note.projectRandom);
  }

  update(Note note) {
    DatabaseProvider().updateNote(newNote: note);
    getNotes(random: note.projectRandom);
  }

  delete(Note note) {
    DatabaseProvider().deleteNote(id: note.id);
    getNotes(random: note.projectRandom);
  }
}
