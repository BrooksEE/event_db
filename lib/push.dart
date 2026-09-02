library db;

import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'RPC.dart';

/// Two urgency tiers, not one per notification "type" -- Android locks sound
/// and heads-up behavior to the channel, so this is what lets an urgent
/// message look different from a routine one without inventing per-topic
/// channels the OS would expose as separate user-facing mute switches.
const _alertsChannel = AndroidNotificationChannel(
  "alerts",
  "Alerts",
  description: "Time-sensitive notifications",
  importance: Importance.high,
);
const _updatesChannel = AndroidNotificationChannel(
  "updates",
  "Updates",
  description: "Routine notifications",
  importance: Importance.defaultImportance,
);

/// Background messages can arrive with the Dart isolate not yet running --
/// this must stay a top-level (or static) function per firebase_messaging's
/// contract, not a method on PushNotifications.
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Push (background): ${message.messageId} ${message.data}");
}

/// Owns the device's push token end to end: requesting permission, capturing
/// the token, keeping it attached to whichever user is currently logged in
/// (or nobody, if logged out), and re-registering on refresh. Token rows are
/// keyed server-side by (device_id, host), never by user -- a device can be
/// logged out or switch users, so `onUserChanged` is what keeps the
/// attribution correct, independent of whether a token exists yet.
class PushNotifications {
  static final PushNotifications _instance = PushNotifications._internal();
  factory PushNotifications() => _instance;
  PushNotifications._internal();

  // Named _hostKey (not _host) to avoid confusion with RPC.dart's own
  // server/host getter, which refers to the RPC API endpoint's hostname --
  // this is the app's host/brand identifier (matches Cart.setHostKey), an
  // unrelated concept that happens to share the word "host".
  String? _hostKey;
  String? _deviceId;
  String? _token;
  int? _userId;
  StreamSubscription<String>? _refreshSub;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Call once at app startup with the app's host key (appVersion). Safe to
  /// call before or after login state is known -- registration re-runs
  /// automatically once both a token and a user id (or explicit logout) are
  /// available, whichever settles last.
  Future<void> init(String hostKey) async {
    _hostKey = hostKey;
    try {
      await _doInit();
    } catch (e) {
      // Push is additive to the app, never load-bearing -- a failure here
      // (permission plumbing, plugin quirks on a given device, etc.) must
      // never affect anything else in the app.
      print("PushNotifications: init failed: $e");
    }
  }

  Future<void> _doInit() async {
    try {
      _deviceId = await FlutterUdid.udid;
    } catch (e) {
      print("PushNotifications: flutter_udid failed: $e");
      return; // no stable device id, nothing we can register against
    }

    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print("PushNotifications: permission denied");
      return;
    }

    if (Platform.isAndroid) {
      await _localNotifications.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings("@drawable/notification"),
        ),
      );
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_alertsChannel);
      await androidPlugin?.createNotificationChannel(_updatesChannel);
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Push (foreground): ${message.messageId} ${message.data}");
      // OS never auto-displays while the app is foregrounded -- Android
      // only, for now (iOS foreground presentation is Phase 2, alongside
      // the delivery-path spike).
      final notification = message.notification;
      if (Platform.isAndroid && notification != null) {
        final channel =
            message.data["channel"] == "alerts" ? _alertsChannel : _updatesChannel;
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: channel.importance,
              priority: channel.importance == Importance.high
                  ? Priority.high
                  : Priority.defaultPriority,
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Push (tapped, was backgrounded): ${message.messageId} ${message.data}");
      // TODO(push-phase1-followup): route via message.data once the
      // notification-type -> app-route table exists.
    });

    _token = await messaging.getToken();
    if (_token != null) {
      await _register();
    }

    await _refreshSub?.cancel();
    _refreshSub = messaging.onTokenRefresh.listen((newToken) {
      _token = newToken;
      _register();
    });
  }

  /// Call this from every place the logged-in identity changes: after a
  /// successful login, after restoring a cached/whoami session, on logout,
  /// and when the session is invalidated server-side without an explicit
  /// logout. Pass null to attribute the device to nobody -- this must clear
  /// eagerly on logout, not lazily, so a device handed to someone else
  /// doesn't keep receiving the previous person's personalized push.
  Future<void> onUserChanged(int? userId) async {
    _userId = userId;
    await _register();
  }

  Future<void> _register() async {
    if (_token == null || _hostKey == null || _deviceId == null) return;
    try {
      await RPC().rpc(
        "email_list",
        "PushToken",
        "register",
        {
          "device_id": _deviceId,
          "host_key": _hostKey,
          "token": _token,
          "platform": Platform.isIOS ? "ios" : "android",
          "user_id": _userId,
        },
        null,
        forceLogin: false,
        retryLogin: false,
      );
    } catch (e) {
      print("PushNotifications: register failed: $e");
    }
  }

  /// Called when the user explicitly wants push off on this device (distinct
  /// from a plain logout, which still keeps the token registered under
  /// user_id=null so Bulk-category pushes can still reach it).
  Future<void> unregister() async {
    if (_deviceId == null || _hostKey == null) return;
    try {
      await RPC().rpc(
        "email_list",
        "PushToken",
        "unregister",
        {"device_id": _deviceId, "host_key": _hostKey},
        null,
        forceLogin: false,
        retryLogin: false,
      );
    } catch (e) {
      print("PushNotifications: unregister failed: $e");
    }
  }
}
