import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/features/stats/domain/entities/match_rating.dart';
import 'package:ecoach_pro/features/stats/domain/repositories/stats_repository.dart';

class RatingTrackerController extends GetxController {
  RatingTrackerController(this._repository);

  final StatsRepository _repository;
  final RxList<MatchRating> matches = <MatchRating>[].obs;
  final RxSet<String> expanded = <String>{}.obs;
  final RxBool loading = true.obs;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    matches.assignAll(await _repository.fetchMatchRatings());
    loading.value = false;
  }

  void toggle(String id) {
    if (expanded.contains(id)) {
      expanded.remove(id);
    } else {
      expanded.add(id);
    }
    expanded.refresh();
  }

  Future<void> addDemoMatch() async {
    final next = MatchRating(
      id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
      name: 'new match',
      date: 'OCTOBER 23, 2026',
      goals: 0,
      assists: 0,
      saves: 0,
      passing: 0,
      dribbling: 0,
      shooting: 0,
      defending: 0,
      pace: 0,
      physical: 0,
    );
    matches.insert(0, next);
  }

  Future<void> showAddMatch(BuildContext context) async {
    final add = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: const Color(0xFF2B4046),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Add match',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add a local demo match for testing. API integration can replace this later.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFB9B9B9), fontSize: 13),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF69F675),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Add demo match'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (add == true) await addDemoMatch();
  }
}
