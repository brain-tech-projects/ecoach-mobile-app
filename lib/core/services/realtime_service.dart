import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/core/services/session_service.dart';
import 'package:ecoach_pro/core/utils/logger.dart';

/// Live "something changed" signals from Firebase Realtime Database.
///
/// The backend gives this user a Firebase custom token (`/firebase-token`).
/// After signing in with it we watch the user's own nodes
/// (`notifications/user_<id>` and `chat_threads/user_<id>`; the security rules
/// only allow reading your own). We never parse their content: any change just
/// tells the screens to re-load through the normal API, so the data shown is
/// always the same as before - only faster.
class RealtimeService extends GetxService {
  RealtimeService(this._session, this._api);

  final SessionService _session;
  final ApiService _api;

  /// True while the connection to the database is up.
  final RxBool connected = false.obs;

  final StreamController<void> _chat = StreamController<void>.broadcast();
  final StreamController<void> _notifications = StreamController<void>.broadcast();

  /// A conversation of this user changed (new message, read state...).
  Stream<void> get chatChanged => _chat.stream;

  /// A notification was added / changed for this user.
  Stream<void> get notificationsChanged => _notifications.stream;

  final List<StreamSubscription<DatabaseEvent>> _subs = <StreamSubscription<DatabaseEvent>>[];
  bool _starting = false;
  int _retries = 0;
  Timer? _retryTimer;

  /// Never throws: without Firebase config the app just uses push + polling.
  Future<RealtimeService> init() async {
    ever<bool>(_session.isLoggedIn, (loggedIn) => loggedIn ? start() : stop());
    if (_session.isLoggedIn.value) start();
    return this;
  }

  Future<void> start() async {
    if (_starting || _subs.isNotEmpty) return;
    _starting = true;
    try {
      final auth = FirebaseAuth.instance;
      String? notificationsPath;

      // A Firebase session survives app restarts, so the token is fetched
      // only when this user is not signed in to Firebase yet.
      final expectedUid = 'user_${_session.user.value?.id}';
      if (auth.currentUser?.uid != expectedUid) {
        final res = await _api.getFirebaseToken();
        final data = res.data;
        final token = data is Map ? data['firebase_token'] as String? : null;
        if (!res.success || token == null) return;
        notificationsPath = data is Map ? data['path'] as String? : null;
        await auth.signInWithCustomToken(token);
      }

      final uid = auth.currentUser?.uid;
      if (uid == null) return;
      final db = FirebaseDatabase.instance;

      _listen(db.ref('.info/connected'), onChange: (e) => connected.value = e.snapshot.value == true, skipFirst: false);
      _listen(db.ref(notificationsPath ?? 'notifications/$uid'), onChange: (_) => _notifications.add(null));
      _listen(db.ref('chat_threads/$uid'), onChange: (_) => _chat.add(null));
      _retries = 0;
    } on FirebaseAuthException catch (error, stackTrace) {
      if (error.code == 'channel-error') {
        // The firebase_auth / firebase_database native code is not part of
        // this build (plugin added after the app was installed). Retrying
        // cannot help; push + polling keep working.
        AppLogger.error(
          'Realtime disabled: Firebase plugins are not in this build. '
          'Stop the app, run `flutter clean`, `flutter pub get`, `cd ios && pod install`, then run again (not hot restart).',
          error: error,
        );
      } else {
        AppLogger.error('Realtime start failed', error: error, stackTrace: stackTrace);
        _scheduleRetry();
      }
    } catch (error, stackTrace) {
      AppLogger.error('Realtime start failed', error: error, stackTrace: stackTrace);
      _scheduleRetry();
    } finally {
      _starting = false;
    }
  }

  /// [skipFirst]: the first event is just the data that is already there.
  void _listen(
    DatabaseReference ref, {
    required void Function(DatabaseEvent) onChange,
    bool skipFirst = true,
  }) {
    var first = skipFirst;
    _subs.add(
      ref.onValue.listen(
        (event) {
          if (first) {
            first = false;
            return;
          }
          onChange(event);
        },
        onError: (Object error) {
          AppLogger.error('Realtime listener error', error: error);
          _scheduleRetry();
        },
      ),
    );
  }

  /// Rules said no / network trouble: start over a few times, then give up
  /// (push + polling keep everything working).
  void _scheduleRetry() {
    if (_retries >= 3 || !_session.isLoggedIn.value) return;
    _retries++;
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: 20 * _retries), () async {
      await _cancelListeners();
      start();
    });
  }

  Future<void> _cancelListeners() async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    connected.value = false;
  }

  /// Sign-out: stop listening and leave Firebase too.
  Future<void> stop() async {
    _retryTimer?.cancel();
    _retries = 0;
    await _cancelListeners();
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
  }

  @override
  void onClose() {
    _retryTimer?.cancel();
    _chat.close();
    _notifications.close();
    super.onClose();
  }
}