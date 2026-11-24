import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/core/services/session_service.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/features/player/domain/notification_route.dart';

/// Runs in its own isolate when a push arrives while the app is closed.
/// Push messages that carry a `notification` block are shown by the system,
/// so there is nothing else to do here.
@pragma('vm:entry-point')
Future<void> pushBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// Push notifications (FCM): permission, device-token registration with the
/// backend (`/device-token`, `/device-token/remove`), foreground banners and
/// opening the right screen when a notification is tapped.
class PushService extends GetxService {
  PushService(this._session, this._api);

  final SessionService _session;
  final ApiService _api;

  static const String _channelId = 'ecoach_default';
  static const String _channelName = 'eCoach Pro';

  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  /// True when the user has switched notifications off in the phone settings.
  final RxBool permissionDenied = false.obs;

  final StreamController<Map<String, dynamic>> _events = StreamController<Map<String, dynamic>>.broadcast();

  /// Data of every push that arrives while the app is open (chat screens use it
  /// to refresh at once).
  Stream<Map<String, dynamic>> get messages => _events.stream;

  /// A screen that is already showing this push's content (e.g. the open chat)
  /// returns true so no banner is shown for it.
  bool Function(Map<String, dynamic> data)? suppressBanner;

  bool _ready = false;
  String? _registered;
  Map<String, dynamic>? _pendingTap;

  FirebaseMessaging get _fcm => FirebaseMessaging.instance;

  /// Call once at start-up. Never throws: without Firebase config the app just
  /// runs without push.
  Future<PushService> init() async {
    try {
      await Firebase.initializeApp();
      await _initLocal();
      // Banners are drawn by us (so an open chat can hide its own).
      await _fcm.setForegroundNotificationPresentationOptions(alert: false, badge: true, sound: false);

      FirebaseMessaging.onMessage.listen(_onForeground);
      FirebaseMessaging.onMessageOpenedApp.listen((m) => _onTap(Map<String, dynamic>.from(m.data)));
      _fcm.onTokenRefresh.listen(_register);

      final initial = await _fcm.getInitialMessage();
      if (initial != null) _pendingTap = Map<String, dynamic>.from(initial.data);

      _ready = true;
      ever<bool>(_session.isLoggedIn, (loggedIn) {
        if (loggedIn) sync();
      });
      if (_session.isLoggedIn.value) sync();
    } catch (error, stackTrace) {
      AppLogger.error('Push init failed', error: error, stackTrace: stackTrace);
    }
    return this;
  }

  Future<void> _initLocal() async {
    await _local.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          _onTap(Map<String, dynamic>.from(jsonDecode(payload) as Map));
        } catch (_) {}
      },
    );
    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            importance: Importance.high,
          ),
        );
  }

  /// Asks for permission (first time only shows the system prompt) and
  /// registers this device with the backend. Safe to call repeatedly.
  Future<void> sync() async {
    if (!_ready || !_session.isLoggedIn.value) return;
    try {
      final settings = await _fcm.requestPermission();
      final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      permissionDenied.value = !granted;
      if (!granted) return;

      // iOS: the APNs token arrives a moment after permission is granted.
      if (!kIsWeb && Platform.isIOS) {
        for (var i = 0; i < 6 && await _fcm.getAPNSToken() == null; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }
      }
      final token = await _fcm.getToken();
      if (token != null) await _register(token);
    } catch (error, stackTrace) {
      AppLogger.error('Push sync failed', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _register(String token) async {
    if (!_session.isLoggedIn.value || token == _registered) return;
    try {
      final res = await _api.registerDeviceToken(token, Platform.isIOS ? 'ios' : 'android');
      if (res.success) _registered = token;
    } catch (error, stackTrace) {
      AppLogger.error('Device token registration failed', error: error, stackTrace: stackTrace);
    }
  }

  /// Sign-out: stop pushes for this account on this device. Must run while
  /// the session token is still valid (see `ApiService.logout`).
  Future<void> unregister() async {
    if (!_ready) return;
    final token = _registered ?? await _safeToken();
    _registered = null;
    if (token != null) {
      try {
        await _api.removeDeviceToken(token);
      } catch (error, stackTrace) {
        AppLogger.error('Device token removal failed', error: error, stackTrace: stackTrace);
      }
    }
    try {
      await _fcm.deleteToken(); // next account gets a fresh token
    } catch (_) {}
  }

  Future<String?> _safeToken() async {
    try {
      return await _fcm.getToken();
    } catch (_) {
      return null;
    }
  }

  // ---- incoming ------------------------------------------------------------

  Future<void> _onForeground(RemoteMessage m) async {
    final data = Map<String, dynamic>.from(m.data);
    _events.add(data);
    if (suppressBanner?.call(data) == true) return;
    final title = m.notification?.title ?? '${data['title'] ?? ''}';
    final body = m.notification?.body ?? '${data['body'] ?? data['message'] ?? ''}';
    if (title.isEmpty && body.isEmpty) return;
    await _local.show(
      m.hashCode & 0x7fffffff,
      title.isEmpty ? 'eCoach Pro' : title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      ),
      payload: jsonEncode(<String, dynamic>{...data, 'title': title, 'body': body}),
    );
  }

  void _onTap(Map<String, dynamic> data) {
    _pendingTap = data;
    flushPending();
  }

  /// Opens the screen of a tapped notification once the app is past the
  /// splash / sign-in screens (also called by the splash after start-up).
  void flushPending() {
    final data = _pendingTap;
    if (data == null || !_session.isLoggedIn.value) return;
    const blocked = <String>{AppRoutes.splash, AppRoutes.onboarding, AppRoutes.signIn};
    if (blocked.contains(Get.currentRoute)) return;
    _pendingTap = null;
    final route = _routeFor(data);
    if (route != null && Get.currentRoute != route) Get.toNamed<void>(route);
  }

  String? _routeFor(Map<String, dynamic> data) {
    final type = '${data['redirect_type'] ?? data['type'] ?? data['click_action'] ?? ''}';
    final text = '${data['title'] ?? ''} ${data['body'] ?? data['message'] ?? ''}';
    return NotificationRoute.resolve(redirectType: type, text: text);
  }

  @override
  void onClose() {
    _events.close();
    super.onClose();
  }
}
