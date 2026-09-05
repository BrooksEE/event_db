library db;

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:klaviyo_flutter_sdk/klaviyo_flutter_sdk.dart';
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
  String? _klaviyoApiKey;
  String _androidNotificationIcon = "@mipmap/ic_launcher";
  StreamSubscription<String>? _refreshSub;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Whether this device currently accepts Bulk-category push, per the
  /// server's own record for this (device_id, host) -- not assumed locally.
  /// Seeded from every register() response (which already returns the full
  /// PushToken row, allow_bulk included) rather than needing a separate
  /// "get current preference" call. A settings screen can read `.value`
  /// directly or listen for changes to build a live toggle.
  final ValueNotifier<bool> allowBulk = ValueNotifier<bool>(true);

  /// Whether the OS notification permission is currently granted. Starts
  /// optimistic (true) since most users accept it; flips to false the
  /// moment we learn otherwise. A denied device never gets a token, so the
  /// allowBulk preference is meaningless until this is true again -- UI
  /// should show an "enable push" prompt instead of the toggle while false.
  final ValueNotifier<bool> permissionGranted = ValueNotifier<bool>(true);

  /// Call once at app startup with the app's host key (appVersion). Safe to
  /// call before or after login state is known -- registration re-runs
  /// automatically once both a token and a user id (or explicit logout) are
  /// available, whichever settles last.
  ///
  /// [klaviyoApiKey] is a brand's Klaviyo Public API Key (never the Private
  /// key). Pass null for every brand that doesn't use Klaviyo -- this is
  /// additive to our own push, never a replacement, and a brand with no key
  /// set skips it entirely.
  ///
  /// [androidNotificationIcon] must name a real drawable/mipmap resource
  /// already compiled into the *consuming app's* Android project --
  /// flutter_local_notifications needs a native Android resource id here,
  /// not a Flutter asset, so this package can't ship one of its own to
  /// fall back to. Defaults to "@mipmap/ic_launcher", which every Flutter
  /// Android app already has -- guaranteed to resolve with zero setup, at
  /// the cost of Android's status-bar icon masking rendering it as a plain
  /// white silhouette of the launcher icon's shape rather than something
  /// purpose-drawn. Pass a dedicated notification icon for a sharper look.
  Future<void> init(String hostKey, {String? klaviyoApiKey, String? androidNotificationIcon}) async {
    _hostKey = hostKey;
    _klaviyoApiKey = klaviyoApiKey;
    if (androidNotificationIcon != null) {
      _androidNotificationIcon = androidNotificationIcon;
    }
    try {
      await _doInit();
    } catch (e) {
      // Push is additive to the app, never load-bearing -- a failure here
      // (permission plumbing, plugin quirks on a given device, etc.) must
      // never affect anything else in the app.
      print("PushNotifications: init failed: $e");
    }
  }

  /// Re-checks current OS permission status without prompting (unlike
  /// init()/_doInit(), which can trigger the native permission dialog).
  /// Call this whenever the UI wants a fresh read -- e.g. a settings screen
  /// re-opening after the user may have visited the OS app-settings page.
  /// If permission went from denied to granted, finishes the setup that
  /// _doInit() bailed out of early (channels, listeners, token, register)
  /// rather than just flipping the flag.
  Future<void> refreshPermissionStatus() async {
    try {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      final wasGranted = permissionGranted.value;
      final nowGranted = settings.authorizationStatus != AuthorizationStatus.denied;
      permissionGranted.value = nowGranted;
      if (nowGranted && !wasGranted && _token == null) {
        await _doInit();
      }
    } catch (e) {
      print("PushNotifications: refreshPermissionStatus failed: $e");
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
      // Denied looks identical whether a real user tapped "Don't allow" or
      // the OS silently refused because this app's AndroidManifest.xml never
      // declared android.permission.POST_NOTIFICATIONS (required on Android
      // 13+) -- there's no API that tells them apart. This hint costs
      // nothing and is aimed at whoever's integrating push into a new app
      // and wondering why nothing happens, not at a real user's decline.
      print("PushNotifications: permission denied. If unexpected, check that "
          "this app's AndroidManifest.xml declares "
          "android.permission.POST_NOTIFICATIONS (required on Android 13+).");
      permissionGranted.value = false;
      return;
    }
    permissionGranted.value = true;

    if (_klaviyoApiKey != null) {
      try {
        await KlaviyoSDK().initialize(apiKey: _klaviyoApiKey!);
      } catch (e) {
        // Klaviyo is additive on top of our own push, same as our own push is
        // additive to the app -- a failure here must never block our own
        // registration below.
        print("PushNotifications: Klaviyo init failed: $e");
      }
    }

    if (Platform.isAndroid) {
      await _localNotifications.initialize(
        InitializationSettings(
          android: AndroidInitializationSettings(_androidNotificationIcon),
        ),
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _reportOpened(response.payload);
        },
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
          payload: message.data["message_id"] as String?,
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Push (tapped, was backgrounded): ${message.messageId} ${message.data}");
      // TODO(push-phase1-followup): route via message.data once the
      // notification-type -> app-route table exists.
      _reportOpened(message.data["message_id"] as String?);
    });

    _token = await messaging.getToken();
    if (_token != null) {
      await _register();
      _forwardTokenToKlaviyo(_token!);
    }

    await _refreshSub?.cancel();
    _refreshSub = messaging.onTokenRefresh.listen((newToken) {
      _token = newToken;
      _register();
      _forwardTokenToKlaviyo(newToken);
    });
  }

  /// Klaviyo needs the same token we already captured for our own
  /// registration -- this is the whole "manual integration" on Klaviyo's
  /// side, no native service registration required.
  void _forwardTokenToKlaviyo(String token) {
    if (_klaviyoApiKey == null) return;
    try {
      KlaviyoSDK().setPushToken(token);
    } catch (e) {
      print("PushNotifications: Klaviyo setPushToken failed: $e");
    }
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
      final result = await RPC().rpc(
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
      if (result["allow_bulk"] is bool) {
        allowBulk.value = result["allow_bulk"];
      }
    } catch (e) {
      print("PushNotifications: register failed: $e");
    }
  }

  /// Call from a settings/preferences screen when the user flips a "marketing
  /// notifications" toggle. Per-device, not per-user, by design -- see Phase
  /// 5 in docs/push_notifications_rpc_plan.md for why. Never writes to any
  /// message log: there's no message this action is a response to, unlike an
  /// email unsubscribe link.
  Future<void> setAllowBulk(bool allow) async {
    if (_deviceId == null || _hostKey == null) return;
    final previous = allowBulk.value;
    allowBulk.value = allow; // optimistic; reverted below on failure
    try {
      await RPC().rpc(
        "email_list",
        "PushToken",
        "setAllowBulk",
        {"device_id": _deviceId, "host_key": _hostKey, "allow_bulk": allow},
        null,
        forceLogin: false,
        retryLogin: false,
      );
    } catch (e) {
      print("PushNotifications: setAllowBulk failed: $e");
      allowBulk.value = previous;
    }
  }

  /// Reports a tap on a push notification back to the server for open/tap
  /// tracking (Phase 6). Shared by both tap paths -- a backgrounded/killed
  /// notification tapped via the OS (onMessageOpenedApp) and one we drew
  /// ourselves while foregrounded (flutter_local_notifications' own tap
  /// callback). Silently does nothing with no message_id: test sends and
  /// Klaviyo-originated pushes never carry our message_id, and that's the
  /// correct behavior for both, not an error case.
  Future<void> _reportOpened(String? messageId) async {
    if (messageId == null || _deviceId == null || _hostKey == null) return;
    try {
      await RPC().rpc(
        "email_list",
        "PushToken",
        "opened",
        {"device_id": _deviceId, "host_key": _hostKey, "message_id": messageId},
        null,
        forceLogin: false,
        retryLogin: false,
      );
    } catch (e) {
      print("PushNotifications: opened report failed: $e");
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
