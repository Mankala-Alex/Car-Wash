// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';

// import 'app/config/environment.dart';
// import 'app/helpers/shared_preferences.dart';
// import 'app/routes/app_pages.dart';
// import 'app/theme/app_theme.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);

//   await SharedPrefsHelper.init();

//   // System UI Overlay Style for both Android and iOS
//   SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//     systemNavigationBarColor: Colors.white,
//     systemNavigationBarIconBrightness: Brightness.dark,
//     statusBarColor: Colors.white,
//     statusBarIconBrightness: Brightness.dark,
//     statusBarBrightness: Brightness.light,
//   ));

//   // iOS-specific status bar style
//   if (Platform.isIOS) {
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//   }

//   String languageCode = await SharedPrefsHelper.getString(
//     SharedPrefsHelper.languageCode,
//     defaultValue: 'en',
//   );
//   if (languageCode.isEmpty) languageCode = 'en';

//   String countryCode = await SharedPrefsHelper.getString(
//     SharedPrefsHelper.countryCode,
//     defaultValue: 'US',
//   );
//   if (countryCode.isEmpty) countryCode = 'US';

//   runApp(MyApp(initialLocale: Locale(languageCode, countryCode)));
// }

// class MyApp extends StatelessWidget {
//   final Locale initialLocale;

//   const MyApp({super.key, required this.initialLocale});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: Environment.appName,
//       locale: initialLocale,
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.lightTheme,
//       initialRoute: AppPages.initialPage,
//       getPages: AppPages.routes,
//       builder: (context, child) {
//         return MediaQuery(
//           data: MediaQuery.of(context)
//               .copyWith(textScaler: const TextScaler.linear(1.0)),
//           child: child!,
//         );
//       },
//     );
//   }
// }

//after adding the firebase for push notification, the main.dart file is changed to this:

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:car_wash_customer_app/app/localization/localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'app/config/environment.dart';
import 'app/helpers/shared_preferences.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/api_service.dart';
import 'app/services/notification_service.dart';
import 'app/services/socket_service.dart';
import 'app/services/support_chat_presence.dart';
import 'app/theme/app_theme.dart';

import 'firebase_options.dart';

/// All banners are rendered by [NotificationService] so the iOS (Darwin)
/// details are never missing — see `app/services/notification_service.dart`.

/// commented for ios run
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print("Background message: ${message.messageId}");
// }

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Firebase
  /// commented for ios run
  //await Firebase.initializeApp();
  //added for ios run
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// Background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SharedPrefsHelper.init();

  // System UI Overlay Style for both Android and iOS
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // iOS-specific status bar style
  if (Platform.isIOS) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  String languageCode = await SharedPrefsHelper.getString(
    SharedPrefsHelper.languageCode,
    defaultValue: 'en',
  );
  if (languageCode.isEmpty) languageCode = 'en';

  String countryCode = await SharedPrefsHelper.getString(
    SharedPrefsHelper.countryCode,
    defaultValue: 'US',
  );
  if (countryCode.isEmpty) countryCode = 'US';

  runApp(MyApp(initialLocale: Locale(languageCode, countryCode)));
}

class MyApp extends StatefulWidget {
  final Locale initialLocale;

  const MyApp({super.key, required this.initialLocale});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    /// commented for ios run
    // setupFCM();
    //added for ios run
    setupFCMSafely();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// While the app is in the background the customer is not reading the chat,
  /// so the socket room is left and the backend sends the push notification.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!Get.isRegistered<SocketService>()) return;

    final socketService = Get.find<SocketService>();

    if (state == AppLifecycleState.paused) {
      socketService.pauseSupportRoom();
    } else if (state == AppLifecycleState.resumed) {
      socketService.resumeSupportRoom();
    }
  }

  //added for ios run
  Future<void> setupFCMSafely() async {
    try {
      await setupFCM();
    } catch (e, stackTrace) {
      debugPrint('FCM setup failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  String? fcmToken;

  /// Opens the support chat when the customer taps a "support replied"
  /// notification (foreground banner, background tap or cold start).
  void openSupportChatFromData(Map<String, dynamic> data) {
    if (data['type']?.toString() != 'SUPPORT_REPLY') return;

    final conversationId = data['conversation_id']?.toString() ??
        data['conversationId']?.toString() ??
        '';
    final bookingId = data['booking_id']?.toString() ?? '';

    if (conversationId.isEmpty && bookingId.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.key.currentState == null) return;

      Get.toNamed(
        Routes.supportChat,
        arguments: {
          if (conversationId.isNotEmpty) 'conversation_id': conversationId,
          if (bookingId.isNotEmpty) 'booking_id': bookingId,
        },
      );
    });
  }

  /// Maps a local-notification payload (JSON encoded FCM data) back to a screen.
  void handleNotificationPayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) return;

    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        openSupportChatFromData(Map<String, dynamic>.from(decoded));
      }
    } catch (e) {
      debugPrint('[FCM] could not read the notification payload: $e');
    }
  }

  /// Saves a (refreshed) device token for the signed-in customer.
  /// Never throws — push setup must not break the app.
  Future<void> _sendFcmTokenToBackend(String token) async {
    try {
      await ApiService.put(
          "customers/fcm-token",
          {
            "fcmToken": token,
          },
          requireAuthToken: true);
      debugPrint("FCM token refreshed and sent to backend");
    } catch (e) {
      debugPrint("Could not send the refreshed FCM token: $e");
    }
  }

  Future<void> setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission();

    print("Permission: ${settings.authorizationStatus}");

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("NOTIFICATION PERMISSION GRANTED");
    } else {
      print("NOTIFICATION PERMISSION DENIED");
    }

    // The plugin, its channels, the iOS permission prompt and the tap handler
    // all live in NotificationService (shared with the socket-driven alerts).
    await NotificationService.instance.init(
      onTap: handleNotificationPayload,
    );

    /// 🔥 GET TOKEN
    ///
    /// Done in the background: on iOS the FCM token only exists once APNs has
    /// registered the device (a few seconds), and on the iOS Simulator it never
    /// exists. Retrieving it must not block the listeners below — the old code
    /// returned here when APNs was missing, which meant the foreground handlers
    /// below were NEVER registered and no in-app notification ever appeared.
    unawaited(_resolveFcmToken(messaging));

    /// 🔁 TOKEN REFRESH
    /// A refreshed token MUST be re-sent to the backend, otherwise the server
    /// keeps pushing to a dead token and the customer silently gets nothing.
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print("NEW TOKEN: $newToken");
      fcmToken = newToken;
      await _sendFcmTokenToBackend(newToken);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint("[FCM] foreground message type=${message.data['type']}");

      final notification = message.notification;
      final title = notification?.title ?? message.data['title']?.toString();
      final body = notification?.body ?? message.data['body']?.toString();

      if (title == null && body == null) return;

      // The customer is already reading this exact conversation: no banner.
      final supportConversationId = message.data['conversation_id']?.toString();
      final isChatOnScreen = Get.currentRoute == Routes.supportChat &&
          SupportChatPresence.isViewing(supportConversationId);

      if (isChatOnScreen) {
        debugPrint('[FCM] support chat is open, notification suppressed');
        return;
      }

      try {
        // NotificationService always sends the iOS (Darwin) details too, so the
        // banner also appears while the app is in the foreground.
        await NotificationService.instance.show(
          title: title ?? '',
          body: body ?? '',
          payload: jsonEncode(message.data),
          dedupeKey: 'fcm:${message.messageId ?? message.data.hashCode}',
        );
      } catch (e) {
        debugPrint('[FCM] could not show the notification: $e');
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] notification opened: ${message.data}');
      openSupportChatFromData(message.data);
    });

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('App opened from terminated notification');
      openSupportChatFromData(initialMessage.data);
    }
  }

  /// Fetches the FCM token in the background and keeps it fresh.
  ///
  /// On iOS the token only exists once APNs has registered the device, so this
  /// polls a few times. The iOS Simulator never gets an APNs token at all —
  /// that only disables *remote* push, the local notifications keep working.
  Future<void> _resolveFcmToken(FirebaseMessaging messaging) async {
    try {
      if (Platform.isIOS) {
        String? apnsToken;

        for (int i = 0; i < 10; i++) {
          apnsToken = await messaging.getAPNSToken();
          if (apnsToken != null) break;
          await Future.delayed(const Duration(seconds: 1));
        }

        if (apnsToken == null) {
          debugPrint(
            'APNs token unavailable (iOS Simulator?) — remote push disabled, '
            'local notifications still enabled.',
          );
          return;
        }
      }

      fcmToken = await messaging.getToken();
      debugPrint('FCM TOKEN: $fcmToken');

      // The backend can only push to this device once it knows the token, so
      // register it right away (login also does it, but the token can become
      // available later than the login call).
      if (fcmToken != null && fcmToken!.isNotEmpty) {
        await _sendFcmTokenToBackend(fcmToken!);
      }
    } catch (e, stackTrace) {
      debugPrint('Unable to retrieve FCM token: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: Environment.appName,
      translations: Localization(),
      locale: widget.initialLocale,
      fallbackLocale: Localization.fallbackLocale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: Localization.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.initialPage,
      getPages: AppPages.routes,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}
