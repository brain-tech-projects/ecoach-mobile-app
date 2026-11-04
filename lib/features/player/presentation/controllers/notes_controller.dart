import 'package:flutter/painting.dart' show Color;
import 'package:get/get.dart';

import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/fun/domain/entities/fun_entities.dart';
import 'package:ecoach_pro/features/fun/domain/repositories/fun_repository.dart';
import 'package:ecoach_pro/features/player/domain/entities/player_entities.dart';
import 'package:ecoach_pro/features/player/domain/repositories/player_repository.dart';
import 'package:ecoach_pro/features/skills/presentation/widgets/complete_dialog.dart';

/// Notes: "Skills Notes" (player repository) / "Challenges Notes" (the note
/// each fun challenge carries in `FunRepository`).
class NotesController extends GetxController {
  NotesController(this._player, this._fun);

  static const String _challengePrefix = 'challenge:';

  final PlayerRepository _player;
  final FunRepository _fun;

  final RxInt tab = 0.obs;
  final RxList<NoteNode> skillNotes = <NoteNode>[].obs;
  final RxList<NoteNode> challengeNotes = <NoteNode>[].obs;
  final RxSet<String> expanded = <String>{}.obs;
  final RxBool loading = true.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    errorMessage.value = null;
    try {
      skillNotes.assignAll(await _player.fetchSkillNotes());
      final res = await _fun.fetchChallenges();
      if (!res.success) throw Exception(res.message);
      challengeNotes.assignAll(<NoteNode>[
        for (final Challenge c in res.data ?? const <Challenge>[])
          if (c.note.trim().isNotEmpty)
            NoteNode(
              id: '$_challengePrefix${c.id}',
              title: c.title,
              thumbnail: c.thumbnail,
              notes: <NoteEntry>[
                NoteEntry(id: '$_challengePrefix${c.id}', text: c.note),
              ],
            ),
      ]);
    } catch (error, stackTrace) {
      AppLogger.error('Notes load failed', error: error, stackTrace: stackTrace);
      errorMessage.value = 'Could not load your notes.';
    } finally {
      loading.value = false;
    }
  }

  bool isExpanded(String id) => expanded.contains(id);

  void toggle(String id) {
    if (!expanded.remove(id)) expanded.add(id);
  }

  Future<void> deleteNote(NoteEntry note) async {
    final yes = await Get.dialog<bool>(
      const CompleteDialog(
        title: 'Delete Note',
        message: 'Are you sure you want to delete this note?',
      ),
      barrierColor: const Color(0xB3000000),
    );
    if (yes != true) return;
    try {
      if (note.id.startsWith(_challengePrefix)) {
        final res = await _fun.saveNote(note.id.substring(_challengePrefix.length), '');
        if (!res.success) throw Exception(res.message);
      } else {
        await _player.deleteNote(note.id);
      }
      await load();
      AppToast.success('Note deleted');
    } catch (error, stackTrace) {
      AppLogger.error('Delete note failed', error: error, stackTrace: stackTrace);
      AppToast.error('Could not delete the note. Please try again.');
    }
  }
}
